`timescale 1ns / 1ps


module fp_div_tb();

reg clk, reset, do_div;
wire[31:0] result;
wire finished_division;
reg[31:0] A, B;
wire [24:0] mantissaResult;
wire [4:0] count;
wire [3:0] state,n_state;

//fp_div div (clk,reset,A,B,do_div,result,valid);
//fp_div_v2 div (clk,reset,A,B,do_div,result,valid);
fp_div_v3 div (clk,reset,A,B,do_div,result,finished_division);

localparam PERIOD = 10;
initial begin
 clk = 1;
 forever #(PERIOD/2) clk = ~clk;
end

initial begin

    $monitor("timestep: %g finished_division=%b  result=%b",$time,finished_division,result);

    reset = 1'b1;
    do_div = 1'b0;
   	#(PERIOD/2) reset = 1'b0;
   	
   	#(PERIOD) do_div = 1'b1;
   	// -13 / 5 = -2.6
   	A = 32'hC1500000;
   	B = 32'h40A00000;
   	//expected result = 01000000001001100110011001100110
   	#300 do_div=1'b0;
   	
   	// 3.5 / 2.5 = 1.4
   	reset = 1'b1;
   	#PERIOD reset = 1'b0;
   	do_div = 1'b1;
   	A = 32'h40600000;
   	B = 32'h40200000;
   	//expected result = 00111111101100110011001100110011
   	
   	#280 do_div = 1'b0; 
   	
   	// 0.2 / -0.5 = -0.4
   	reset = 1'b1;
   	#PERIOD reset = 1'b0;
   	do_div = 1'b1;
   	A = 32'h3E4CCCCD;
   	B = 32'hBF000000;
   	#200 do_div = 1'b0;
   	
   	#(250*PERIOD)
   	$stop;

end

endmodule
