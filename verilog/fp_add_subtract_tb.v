`timescale 1ns / 1ps

module fp_add_subtract_tb();

parameter DATA_WIDTH = 32;

reg [DATA_WIDTH-1:0] A,B;
wire [DATA_WIDTH-1:0] result;


wire signA,signB;
fp_add_subtract add_subtract (A,B,result);

initial begin

    $monitor("timestep: %g  result = %b",$time,result);
    A = 32'h00000000;
         B = 32'h00000000;
         //C = 32'h00000000;
        #5
    
         A = 32'h40000000;
         //B = 0;
         B = 32'h40400000;

         #5
         //$display("timestep: %g   result = %b",$time,result);
        //A = 32'h40000000;
        //B = 32'h40400000;
        A = 0;
        B = 0;
        //A = 32'b10111101111000010110101000001101;
        //B = 32'b00111101100101110111101100001100;
        #(20)
        $stop;   

end


endmodule
