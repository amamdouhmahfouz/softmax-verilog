`timescale 1ns / 1ps


/*

    This testbench test inputs to softmax inputs = {1,2,3,4,5,6,7,8,9,10}
   
    To run this testbench: run simulation >> press Run All (F3)
    and the output will be seen in the TCL window down

*/


module softmax_tb();

parameter DATA_WIDTH = 32;

reg clk, reset;//, do_div;
//wire[31:0] result;
//reg[31:0] A, B;

//wire [31:0] divisor;

reg [10*DATA_WIDTH-1:0] inputs;
wire [10*DATA_WIDTH-1:0] outputs;
softmax smax (clk,reset,inputs,outputs);

localparam PERIOD = 10;
initial begin
 clk = 1;
 forever #(PERIOD/2) clk = ~clk;
end

integer i,k=10;
initial begin

   // $monitor("timestep: %g  divisor = %b",$time,divisor);

    reset = 1'b1;
    //inputs = {1,2,3,4,5,6,7,8,9,10}, then exp of each element will be calculated
    //then it will be divided by the summation of all the exponents
    inputs = {32'h3F800000,32'h40000000,32'h40400000,32'h40800000,32'h40A00000,32'h40C00000,32'h40E00000,32'h41000000,32'h41100000,32'h41200000};

   	#(PERIOD/2) reset = 1'b0;
   	
    //#1450
    #1550
    for (i = 0; i <= 9; i=i+1) begin
        $display("input to softmax with value %d: output=%b",k,outputs[i*DATA_WIDTH+:DATA_WIDTH]);
        k = k-1;
    end
   	
   	
   	
   	#(2000*PERIOD)
   	$stop;

end

endmodule
