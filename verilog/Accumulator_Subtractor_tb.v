`timescale 1ns / 1ps

module Accumulator_Subtractor_tb();

reg clk, reset;
reg [31:0] inp;
wire [31:0] result;

Accumulator_Subtractor acc_sub (inp,clk,reset,result);

localparam PERIOD = 10;
initial begin
 clk = 1;
 forever #(PERIOD/2) clk = ~clk;
end

initial begin

    $monitor("timestep: %g  reset=%b  result=%h",$time,reset,result);
    
    reset = 1'b1;
    inp = 32'h3F800000;
    #(PERIOD/2) reset = 1'b0;
    
    #(120)
    $stop;




end


endmodule
