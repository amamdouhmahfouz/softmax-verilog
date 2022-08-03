`timescale 1ns / 1ps

// Floating Point Division
// A: numerator,  B; denominator ---> A / B

/*
    Number of clock cycles = 28 clock cycles ( dividing the mantissas(24 cycles) + moving from s_idle to s_convert(2 cycles) +  normalization(1 cycle) + resetting(1 cycle))
W'll be using the integer division algorithm for dividing the mantissas, exponents are subtracted, and signs are XORed
The procedure for dividing the mantissas is as follows, we will always be assigning a variable with the difference of mantissas(mantissaA - mantissaB) --> manA_diff_manB
Then w'll check MSB (manA_diff_manB[24]), if it is equal 1 then this means that mantissaA < mantissaB for this clock cycle and w'll shift the mantissaResult to the left
one place and append 0, else append 1 (which means that the difference is positive)

There is a fsm that controls in which state we are in (states: division,normalization,convert,idle), the following will explain the use of each state:
    idle: it will remain at this state until start_division signal equal 1 and will move to next state s_convert
    s_convert: will check if the divisor equals zero which will trigger divide by zero flag(s_flag) else will move to division state(s_div)
    s_div: this state takes 24 cycles to complete as it passes through the length of mantissa+1(1.M) and last bit is the check for normalization(s_normalise)
    s_normalize: if the MSB of the mantissaResult is 0, then w'll subtract one from the exponent

There is a counter present to keep track when the s_div state finishes

*/


module fp_div_v3(clk,reset,A,B,start_division,result,finished_division);

parameter DATA_WIDTH = 32;

input clk, reset;
input [DATA_WIDTH-1:0] A, B; 
input start_division; // when start_division equals 1, the process will start
output [DATA_WIDTH-1:0] result;
output finished_division;

reg[24:0] mantissaA; //the numerator
wire[24:0] mantissaB; //the denominator 
 reg[24:0] mantissaResult; //acts as the quotient, and every time we shift to the left with either 1 appended or 0 appended
reg[8:0] exp;


reg[4:0] count; //a counter till division operation finishes
reg val; //when division finishes, it becomes 1 else stays 0
wire [24:0] manA_diff_manB; //mantissA - mantissaB

assign result = {A[31]^B[31],exp[7:0],mantissaResult[22:0]}; //final result
assign finished_division = val; //when division finishes it will be 1

//the subtraction of mantissas, think of it the same way u do long division in binary
//there is always a part where a part of the dividend minus the divisor
assign manA_diff_manB = mantissaA - mantissaB; 

//******************** divisor *********************
//Here there is much to do with the divisor, except of course if dividing by zero
//manissaB shall not be changed as it is the divisor
assign mantissaB = (reset) || (((state == s_idle) && start_division)) || (B[30:0] == 31'd0) ? 25'd0: {1'b0,1'b1,B[22:0]};
                        

//states
localparam s_idle = 4'b0000,
           s_convert = 4'b0001,
           s_div = 4'b0010,
           s_normalise = 4'b0011,
           s_flag = 4'b0100; //zero flag

 reg [3:0] state; //current state
 reg [3:0] n_state; //next state



//state update fsm
always @(*) begin

    case (state)
        s_idle: begin
            if (start_division) begin
                n_state = s_convert;
            end
            else begin
                n_state = s_idle;
            end
        end
        s_convert: begin
            //if dividing by zero
            if (mantissaB == 24'd0) begin
                n_state = s_flag;
            end
            else begin
                n_state = s_div;
            end
        end
        s_div: begin
            if (count < 5'd24) begin //i.e from 0 to 23 inclusive
                n_state = s_div;
            end
            else begin
                n_state = s_normalise;
            end
        end
        default: begin
            n_state = s_idle;
        end
    endcase

end

//counter for the division process and each cycle update the state with the next state assigned from the states fsm
// also it updates the finished_division signal
// when division is done val will be 1, else it will always be 0
always @(posedge clk) begin

    if (reset) begin
        count <= 5'd0;
        state <= s_idle;
        val <= 1'b0;
    end
    else begin
        state <= n_state;
        if (state == s_normalise) begin
            val <= 1'b1;
        end
        else begin
            val <= 1'b0;
        end
        if (state == s_convert) begin
            count <= 5'd0;
        end
        else begin
            if (state == s_div) begin
                count <= count + 5'd1;
            end
            else begin 
                count <= count;
            end
        end
    end  
end

// Block of mantissas (divisor,dividend,result mantissa)
// Division procedure happens here  
always @(posedge clk) begin

    if (reset) begin
        mantissaA <= 25'd0;
        mantissaResult <= 25'd0;
    end
    else begin

       //******************* dividend/or the numerator *********************
        if (start_division && (state == s_idle)) begin
            if (A[30:0] == 0) begin
                mantissaA <= 25'd0;
            end 
            else begin
                mantissaA <= {1'b0,1'b1,A[22:0]};
            end
        end
        else begin
        // if we are in division state, mantissaA will be either the difference of part of dividend - divisor if the divedend is greater than the divisor
        // or will be the same 
        // notice that in both cases we shift left by 1 (refer to the algorithm at top of code), which means appending 0 to the right each time
            if (state == s_div) begin
                if (!manA_diff_manB[24]) begin //if there is no carry(borrow in this case) then difference is positive i.e the mantissaA is greater than mantissaB for this clock cycle
                    mantissaA <= {manA_diff_manB[23:0],1'b0};
                end
                else begin
                    mantissaA <= {mantissaA[23:0],1'b0};
                end
            end
         
        end
        
     
        //***************** resulting mantissa **************
        if (start_division && (state == s_idle)) begin
             mantissaResult <= 25'd0;
        end
        else begin
        //this procedure is exactly the same as calculating the quotient by hand,
        //we will see if the dividend is greater than divisor, then we will put 1 up else put 0
        if (state == s_div) begin //divsion mode 
             if (!manA_diff_manB[24]) begin //if difference is +ve or if manA is greater than manB
                 mantissaResult <= {mantissaResult[23:0],1'b1};
             end
             else begin
                  mantissaResult <= {mantissaResult[23:0], 1'b0};
             end
             end
         else begin
                 if (state == s_normalise) begin
                    if (mantissaResult[24]) begin
                         mantissaResult <= {1'b0,mantissaResult[24:1]};
                    end
                    else begin
                         mantissaResult <= mantissaResult;
                    end
                 end
                 else begin //no change
                      mantissaResult <= mantissaResult; //latch it 
                 end
             end
         end
           
    end

end


// Block of exponent
// 
always @ (posedge clk) begin

    if (reset) begin
        exp <= 9'd0;
    end
    else begin
        if (start_division && (state == s_idle)) begin
            //when dividing by zero, it will give infinity(NaN), which is represented in ieee floating point format by the exponent = 8'd255
            if (B[30:0] == 31'd0) begin
                exp <= 9'b011111111;
            end
            else begin
                exp <= {1'b0,A[30:23]} - {1'b0,B[30:23]} + 9'd127;
            end
        end
        else begin
            if (state == s_normalise) begin
                if (!mantissaResult[24]) begin 
                    exp <= exp  - 9'd1;
                end
                else begin
                    exp <= exp;
                end
            end
        end
    end

end


endmodule
