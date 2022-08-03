`timescale 1ns / 1ps

/*
    Number of clock cycles: 140 <--- (10(for exp of each input) * num of inputs(10)) + 10(accumulation) + 25(division) + 5(reset and stuff)
    This module contains 1 "exp" module, 1 "Accumulator" module, 10 "division" modules
    
    Takes as input the whole the 10 numbers from the previous layer
    
    Process: 
    It first starts by computing the exponential of inputs one after the other(to reduce utilization)
    then we feed these results of exp to the accumulator one after the other
    then we divide the exp of each input by the result of accumulation
*/


module softmax(clk,reset,data_in,data_out);

parameter DATA_WIDTH = 32;
parameter num = 10; //number of inputs to softmax

input clk, reset;
input [num*DATA_WIDTH-1:0] data_in;
output [num*DATA_WIDTH-1:0] data_out;

reg reset_exp; //input to the reset of the exponent

reg reset_accumulator; //input to the reset of the accumulator

reg [7:0] global_counter;

//fp_div_v2 related signals
wire [num-1:0] done_division;
reg[DATA_WIDTH-1:0] div_reg; 
wire [DATA_WIDTH-1:0] divisor; //the denomonator, i.e the result of accumulation
wire finished_div;

//input to the exp module
wire [31:0] exp_in;
assign exp_in = (global_counter == 8'd0) ? data_in[DATA_WIDTH-1:0] :
                (global_counter == 8'd11) ? data_in[2*DATA_WIDTH-1:DATA_WIDTH] :
                (global_counter == 8'd22) ? data_in[3*DATA_WIDTH-1:2*DATA_WIDTH] :
                (global_counter == 8'd33) ? data_in[4*DATA_WIDTH-1:3*DATA_WIDTH] :
                (global_counter == 8'd44) ? data_in[5*DATA_WIDTH-1:4*DATA_WIDTH] :
                (global_counter == 8'd55) ? data_in[6*DATA_WIDTH-1:5*DATA_WIDTH] :
                (global_counter == 8'd66) ? data_in[7*DATA_WIDTH-1:6*DATA_WIDTH] :
                (global_counter == 8'd77) ? data_in[8*DATA_WIDTH-1:7*DATA_WIDTH] :
                (global_counter == 8'd88) ? data_in[9*DATA_WIDTH-1:8*DATA_WIDTH] :
                (global_counter == 8'd99) ? data_in[10*DATA_WIDTH-1:9*DATA_WIDTH] : exp_in;

wire [DATA_WIDTH-1:0] exp_out; //output from exp_v3

//exp_results will hold the results of the exponent of each input (10 exp_results)
wire [num*DATA_WIDTH-1:0] exp_results; //the results of each exp
assign exp_results[DATA_WIDTH-1:0] = (global_counter == 8'd10) ? exp_out : exp_results[DATA_WIDTH-1:0];
assign exp_results[2*DATA_WIDTH-1:1*DATA_WIDTH] = (global_counter == 8'd21) ? exp_out : exp_results[2*DATA_WIDTH-1:1*DATA_WIDTH];
assign exp_results[3*DATA_WIDTH-1:2*DATA_WIDTH] = (global_counter == 8'd32) ? exp_out : exp_results[3*DATA_WIDTH-1:2*DATA_WIDTH];
assign exp_results[4*DATA_WIDTH-1:3*DATA_WIDTH] = (global_counter == 8'd43) ? exp_out : exp_results[4*DATA_WIDTH-1:3*DATA_WIDTH];
assign exp_results[5*DATA_WIDTH-1:4*DATA_WIDTH] = (global_counter == 8'd54) ? exp_out : exp_results[5*DATA_WIDTH-1:4*DATA_WIDTH];
assign exp_results[6*DATA_WIDTH-1:5*DATA_WIDTH] = (global_counter == 8'd65) ? exp_out : exp_results[6*DATA_WIDTH-1:5*DATA_WIDTH];
assign exp_results[7*DATA_WIDTH-1:6*DATA_WIDTH] = (global_counter == 8'd76) ? exp_out : exp_results[7*DATA_WIDTH-1:6*DATA_WIDTH];
assign exp_results[8*DATA_WIDTH-1:7*DATA_WIDTH] = (global_counter == 8'd87) ? exp_out : exp_results[8*DATA_WIDTH-1:7*DATA_WIDTH];
assign exp_results[9*DATA_WIDTH-1:8*DATA_WIDTH] = (global_counter == 8'd98) ? exp_out : exp_results[9*DATA_WIDTH-1:8*DATA_WIDTH];
assign exp_results[10*DATA_WIDTH-1:9*DATA_WIDTH] = (global_counter == 8'd109) ? exp_out : exp_results[10*DATA_WIDTH-1:9*DATA_WIDTH];

wire  start_division;
assign start_division = (global_counter == 8'd111) ? 1'b1 : 1'b0; //start division when accumulation finishes

wire [num*DATA_WIDTH-1:0] div_results; //result from division which is the last stage in this module

assign data_out[DATA_WIDTH-1:0] = (global_counter == 8'd140) ? div_results[DATA_WIDTH-1:0] : 32'd0;
assign data_out[2*DATA_WIDTH-1:1*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[2*DATA_WIDTH-1:1*DATA_WIDTH] : 32'd0;
assign data_out[3*DATA_WIDTH-1:2*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[3*DATA_WIDTH-1:2*DATA_WIDTH] : 32'd0;
assign data_out[4*DATA_WIDTH-1:3*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[4*DATA_WIDTH-1:3*DATA_WIDTH] : 32'd0;
assign data_out[5*DATA_WIDTH-1:4*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[5*DATA_WIDTH-1:4*DATA_WIDTH] : 32'd0;
assign data_out[6*DATA_WIDTH-1:5*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[6*DATA_WIDTH-1:5*DATA_WIDTH] : 32'd0;
assign data_out[7*DATA_WIDTH-1:6*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[7*DATA_WIDTH-1:6*DATA_WIDTH] : 32'd0;
assign data_out[8*DATA_WIDTH-1:7*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[8*DATA_WIDTH-1:7*DATA_WIDTH] : 32'd0;
assign data_out[9*DATA_WIDTH-1:8*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[9*DATA_WIDTH-1:8*DATA_WIDTH] : 32'd0;
assign data_out[10*DATA_WIDTH-1:9*DATA_WIDTH] = (global_counter == 8'd140) ? div_results[10*DATA_WIDTH-1:9*DATA_WIDTH] : 32'd0;


wire [DATA_WIDTH-1:0] accumulator_in;
assign accumulator_in = (global_counter == 8'd100) ? exp_results[1*DATA_WIDTH-1:0*DATA_WIDTH] :
                        (global_counter == 8'd101) ? exp_results[2*DATA_WIDTH-1:1*DATA_WIDTH] :
                        (global_counter == 8'd102) ? exp_results[3*DATA_WIDTH-1:2*DATA_WIDTH] :
                        (global_counter == 8'd103) ? exp_results[4*DATA_WIDTH-1:3*DATA_WIDTH] :
                        (global_counter == 8'd104) ? exp_results[5*DATA_WIDTH-1:4*DATA_WIDTH] :
                        (global_counter == 8'd105) ? exp_results[6*DATA_WIDTH-1:5*DATA_WIDTH] :
                        (global_counter == 8'd106) ? exp_results[7*DATA_WIDTH-1:6*DATA_WIDTH] :
                        (global_counter == 8'd107) ? exp_results[8*DATA_WIDTH-1:7*DATA_WIDTH] :
                        (global_counter == 8'd108) ? exp_results[9*DATA_WIDTH-1:8*DATA_WIDTH] :
                        (global_counter == 8'd109) ? exp_results[10*DATA_WIDTH-1:9*DATA_WIDTH] : 32'd0;


reg [3:0] count_exp;

// Block to control the global_counter, which controls the timings of reset of each component 
// and synchronizes the start of each component
always @ (posedge clk) begin

    if (reset) begin
        reset_exp = 1'b1;
        global_counter = 8'd0;
        count_exp = 4'd0;
        reset_accumulator = 1'b1;
    end
    else begin
//        global_counter = global_counter + 8'd1;
        if (global_counter > 8'd139)
            global_counter = global_counter;
        else
            global_counter = global_counter + 8'd1;           
        if (global_counter == 8'd1) 
                reset_exp = 1'b0;
            else if (global_counter == 8'd11) begin
                reset_exp = 1'b1;
                reset_accumulator = 1'b0;
                end
            else if (global_counter == 8'd12)
                reset_exp = 1'b0;
            else if (global_counter == 8'd22)
                reset_exp = 1'b1;
            else if (global_counter == 8'd23)
                reset_exp = 1'b0;
            else if (global_counter == 8'd33)
                reset_exp = 1'b1;
            else if (global_counter == 8'd34)
                reset_exp = 1'b0;
            else if (global_counter == 8'd44)
                reset_exp = 1'b1; 
            else if (global_counter == 8'd45)
                reset_exp = 1'b0;
            else if (global_counter == 8'd55)
                reset_exp = 1'b1;
            else if (global_counter == 8'd56)
                reset_exp = 1'b0;
            else if (global_counter == 8'd66)
                reset_exp = 1'b1;
            else if (global_counter == 8'd67)
                reset_exp = 1'b0;
            else if (global_counter == 8'd77)
                reset_exp = 1'b1;
            else if (global_counter == 8'd78)
                reset_exp = 1'b0;
            else if (global_counter == 8'd88)
                reset_exp = 1'b1;
            else if (global_counter == 8'd89)
                reset_exp = 1'b0;
            else if (global_counter == 8'd99)
                reset_exp = 1'b1;
            else if (global_counter == 8'd100)
                reset_exp = 1'b0;
            else if (global_counter == 8'd110) begin
                reset_exp = 1'b1;
                end
            else if (global_counter == 8'd111) begin
                div_reg = divisor; 
                reset_exp = 1'b1;
              end
                  
    end 

end

//********************************** first get the exponent of each input ************************************
exp_v3 exponent_numerator (.clk(clk), .reset(reset_exp), .data_in(exp_in), .data_out(exp_out));

//************** then accumulate all these exponents to get the denomonator(or the divisor) ******************
//Accumulator_Subtractor accum_exp_denomenator (.clk(clk),.start_FC(reset_accumulator),.input_FC(exp_out),.R(divisor));
Accumulator_Subtractor accum_exp_denomenator (.clk(clk),.start_FC(reset_accumulator),.input_FC(accumulator_in),.R(divisor));

//**************************** then divide each output from exp_results by the divisor ***********************
genvar i;
generate
    for (i = 0; i <= 9; i=i+1) begin
        //fp_div division (.clk(clk),.reset(reset),.start_division(start_division),.A(exp_results[i*DATA_WIDTH+:DATA_WIDTH]),.B(div_reg),.result(div_results[i*DATA_WIDTH+:DATA_WIDTH]),.finished_division(done_division[i]));
         fp_div_v3 division (.clk(clk),.reset(reset),.start_division(start_division),.A(exp_results[i*DATA_WIDTH+:DATA_WIDTH]),.B(div_reg),.result(div_results[i*DATA_WIDTH+:DATA_WIDTH]),.finished_division(done_division[i]));
    end
endgenerate

endmodule
