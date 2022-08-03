`timescale 1ns / 1ps

module exp_v3_tb();

parameter DATA_WIDTH = 32;

reg clk, reset;
reg [DATA_WIDTH-1:0] x;
wire [DATA_WIDTH-1:0] result, coef_in;
wire [3:0] state;
wire [3:0] count;
exp_v3 exponential_v3 (.clk(clk),.reset(reset),.data_in(x),.data_out(result));

localparam PERIOD = 10;

initial begin
 clk = 1;
 forever #(PERIOD/2) clk = ~clk;
end


initial begin


   		
   	$monitor ("timeStep:%g reset=%b result = %b"
   	,$time,reset,result);
   	
   	//exp(3)
    reset = 1'b1;
    //x = 32'h40400000; //3
    x = 32'hC0400000; //-3
    //x = 32'h40E00000;
   	#(5*PERIOD/2) reset = 1'b0;

    //exp(3)
    #(10*PERIOD)
    reset = 1'b1;
    x = 32'h40E00000; //7     
    #(PERIOD/2) reset = 1'b0;

    
    #(1000*PERIOD)
    $stop;

end

endmodule
