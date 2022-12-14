`timescale 1ns / 1ps

module Accumulator_Subtractor (input_FC,clk,start_FC,R);

parameter DATA_WIDTH = 32;

input [DATA_WIDTH-1:0]  input_FC;
input clk, start_FC;
output reg [31:0] R;

//integer countFinished;

//output reg finished;

//variables used in an always block
//are declared as registers
reg [7:0] e_A, e_R;
reg [23:0] fract_a, fract_r,fract_c;//frac = 1 . mantissa 
reg [7:0] shift_cnt;
reg cout;
reg [DATA_WIDTH-1:0] Input_tmp;
reg [DATA_WIDTH-1:0] Temp;
reg dummy;
integer i;

always @(posedge clk)
begin

	if(start_FC == 1)
        begin
            R = 32'b0;
            dummy = 1;
            //countFinished = NoOfInputs;
        end
    else
        begin
            if(dummy == 1)
            begin
                Input_tmp = input_FC;
                dummy = 0;
            end
            Temp = input_FC;
            //Input_tmp = input_FC;  
            //Input_tmp = InputArr>>DATA_WIDTH;                

    if (input_FC[30:0] == 0 ) begin

                    R = R;
        end
        else begin

		e_A      = Temp [30:23];
		e_R      = R [30:23];
		fract_a  = {1'b1,Temp [22:0]};
		fract_r  = {1'b1,R [22:0]};
		//align fractions
		if (e_A < e_R)
		begin
			shift_cnt  = e_R - e_A;
			fract_a   = fract_a >> shift_cnt;
			e_A       = e_A + shift_cnt;  
		end else if (e_R < e_A)
		begin
			shift_cnt  = e_A - e_R;
			fract_r  = fract_r >> shift_cnt;
			e_R  = e_R + shift_cnt;
		end 

		//add fractions
		if(Temp [31] == R[31])
		begin
			{cout, fract_c}  = fract_a + fract_r;
		//normalize result
			if (cout == 1)
			begin
				{cout, fract_c}  = {cout, fract_c} >> 1;
				e_R  = e_R + 1;
			end
			//R[31]  = sign_a;
			R[30:23]  = e_R;
			R[22:0]  = fract_c[22:0];
		end else 
		begin
			if(fract_a >= fract_r)
			begin
				fract_c = fract_a - fract_r;
				R[31]  = Temp[31];
			end else
			begin
				fract_c = fract_r - fract_a;
				//R[31]  = sign_b;
			end
			if(fract_c != 0)
			begin
				R[30:23] = e_A;
				for(i = 0; i < 23; i=i+1)
				begin
					if(!fract_c[23])
					begin
						fract_c = fract_c << 1;
						R[30:23] = R[30:23] - 1;
					end
				end
				R[22:0]  = fract_c[22:0]; 
			end else
			begin
				R[31]  = 0;
				R[30:23]  = 0;
				R[22:0]  = fract_c[22:0]; 
			end
		end 
	end
end
end
endmodule