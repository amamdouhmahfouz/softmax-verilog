`timescale 1ns / 1ps


module fp_mul_tb();

parameter DATA_WIDTH = 32;

reg [DATA_WIDTH-1:0] A,B,C;
wire [DATA_WIDTH-1:0] result, result_tmp;
wire[47:0] man_r;

fp_mul multiplier (A,B,result);

initial begin

    $monitor("timestep: %g   result = %b",$time,result);

     A = 32'h00000000;
     B = 32'h00000000;
     //C = 32'h00000000;
    #5

     A = 32'h40000000;
     B = 32'h40400000;

     #5
     //$display("timestep: %g   result = %b",$time,result);
//     A = 32'h40000000;
//          B = 32'h40400000;
        A = 32'd0;
        B = 32'd0;
         // C = 32'h40A00000;
    #(20)
    $stop;    

end


endmodule
