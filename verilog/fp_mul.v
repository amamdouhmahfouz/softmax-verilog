`timescale 1ns / 1ps

/*
At first {1'b1,manA) is multiplied to {1'b1,manB) -> man_r
the minimum value of both values is 100000000000000000000000
so the minimum value of there mutipliction will be
010000000000000000000000000000000000000000000000
so the mantisa will be shifted once at most
and if man_r[47:0] (man_r MSB) equals 1
then man_final = man_r[46+:23] & exp_final = (({1'b0,expA} + {1'b0,expB}) - 127 + 1)
but if man_r[47:0] (man_r MSB) equals 0
then man_final = man_r[45+:23] & exp_final = (({1'b0,expA} + {1'b0,expB}) - 127 )

and if A or B is equal to 0(or -0) the result 0(or -0)
*/


module fp_mul(
	input [31:0] A,
	input [31:0] B,
	output reg [31:0] result
    );

	reg [7:0] expA,expB;
	reg [22:0] manA,manB;
	reg [47:0] man_r;
	
	
	always @ (*) begin
		expA = A[30:23];
		expB = B[30:23];
		manA = A[22:0];
		manB = B[22:0];
		man_r[47:0] = ({1'b1, manA[22:0]} * {1'b1, manB[22:0]});

		if((|A[30:0])&(|B[30:0])) begin
		
	      //exponent
		  result[30:23] = (man_r[47])? (({1'b0,expA} + {1'b0,expB}) - 9'd126) :
		  (({1'b0,expA} + {1'b0,expB}) - 9'd127); 
		  //mantissa
		  result[22:0] = (man_r[47])? man_r[46-:23] : man_r[45-:23] ;
		  
		end
		else begin 
		  result[30:0] = 31'b0;
		end
		
		//sign
		result[31] = A[31] ^ B[31];
		
	end

endmodule