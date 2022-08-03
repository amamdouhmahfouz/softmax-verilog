`timescale 1ns / 1ps

/*
    This module will calculate the first 10 real values of taylor series to calculate e^x

    Number of clock cyles = 10
    
    instead of computing 1 + x/1! + x^2/2! + x^3/3! + .....
    we will compute 1 + (x/1)( .....(1+ (x/6)(1 + (x/7)(1 + (x/8)(1 + x/9))))  which is the same as the expression above

    Here, we will need 2 multipliers to multiply three numbers for example the term:  data_in * (1/8) * (previous calculation)
    the three numbers are data_in(the input as e^x), the reciprocal: ex. (1/8), and the result of another term
    The adder is needed to add 1 to the result of multiplying the three numbers
    and this process is repeated 10 times to calculate the 10 real values

*/


module exp_v3(clk,reset,data_in,data_out);

parameter DATA_WIDTH = 32;

input clk, reset;
input [DATA_WIDTH-1:0] data_in;
output wire [DATA_WIDTH-1:0] data_out;

//reciprocals of 1,2,3,4,5,6,7,8,9
localparam coef_9 = 32'b00111101111000111000111000111001,
           coef_8 = 32'b00111110000000000000000000000000,
           coef_7 = 32'b00111110000100100100100100100101,
           coef_6 = 32'b00111110001010101010101010101011,
           coef_5 = 32'b00111110010011001100110011001101,
           coef_4 = 32'b00111110100000000000000000000000,
           coef_3 = 32'b00111110101010101010101010101011,
           coef_2 = 32'b00111111000000000000000000000000,
           coef_1 = 32'b00111111100000000000000000000000;

localparam idle = 4'b0000;

           
//array of reciprocals which are used as the coefficients
localparam [9*DATA_WIDTH-1:0] coef_arr = {coef_1,coef_2,coef_3,coef_4,coef_5,coef_6,coef_7,coef_8,coef_9};

reg [3:0] state = 4'b0;

reg[DATA_WIDTH-1:0] coef_in = 32'h3F800000;
reg [DATA_WIDTH-1:0] y_in = 32'h3F800000;

wire[DATA_WIDTH-1:0] adder_result;
reg[DATA_WIDTH-1:0] x = 32'h3F800000;

assign data_out = (count < 4'd9) ? 32'd0 : adder_result; //do net let dataout till after 10 clock cycles at which the exp finishes

wire [DATA_WIDTH-1:0] res_tmp;
wire [DATA_WIDTH-1:0] mult_result;

//output reg enable;
reg [DATA_WIDTH-1:0] first_operand_adder = 32'd0;
//assign first_operand_adder = (state == idle) ? 32'd0 : 32'd1;

fp_mul mul1 (.A(coef_in), .B(x), .result(res_tmp));
fp_mul mul2 (.A(res_tmp), .B(y_in), .result(mult_result));

//fp_add adder (.A_FP(first_operand_adder), .B_FP(mult_result), .result(adder_result));
fp_add_subtract adder (.A(first_operand_adder), .B(mult_result), .R(adder_result));
 reg[3:0] count;
always @ (posedge clk or posedge reset) begin
    if (reset) begin
        count <= 4'd0;
    end
    else begin
        if (count >= 4'd9) begin
            count <= count;
        end
        else begin
            count <= count + 4'd1;
        end
    end
end


always @ (posedge clk or posedge reset) begin

    if (reset) begin
		first_operand_adder <= 32'd0;
		coef_in <= 32'h3F800000;
		x <= 32'h3F800000;
		y_in <= 32'h3F800000;
        state <= idle;
    end
    else begin
        if (state < 4'b1001) begin
		first_operand_adder <= 32'h3F800000;
		x <= data_in;
		y_in <= adder_result;
		coef_in <= coef_arr[state*DATA_WIDTH+:DATA_WIDTH];
		state <= state+4'b1;
		end 	   
    end
end


endmodule
