`timescale 1ns / 1ps

module fp_add_subtract(A,B,R);

parameter DATA_WIDTH = 32;

input [DATA_WIDTH-1:0] A, B;
output reg [DATA_WIDTH-1:0] R;


reg [7:0] e_A, e_R;
reg [23:0] fract_a, fract_r,fract_c;//frac = 1 . mantissa 
reg [7:0] shift_cnt;
reg cout;
reg [DATA_WIDTH-1:0] Input_tmp;
reg [DATA_WIDTH-1:0] Temp;
reg dummy = 1'b1;
reg signA;
reg signB;
integer i;

always @(A or B)
begin
            
        signA = A[31];
        signB = B[31];
		e_A      = A[30:23];
		e_R      = B[30:23];
		fract_a  = {1'b1,A[22:0]};
		fract_r  = {1'b1,B[22:0]};
		

     if (A[30:0] == 0 && B[30:0] == 0) begin
		  R = 0;
      end
      else begin
        
		if (e_A > e_R) begin
            R[31] = signA;		
		end
		else begin
		  if (e_A < e_R) begin
		      R[31] = signB;
		  end
		  else begin
		      if (e_A == e_R) begin
		          if (fract_a >= fract_r) begin
		              R[31] = signA;
		          end
		          else begin
		              R[31] = signB;
		          end
		      end
		  end
		end
		
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
		if(signA == signB)
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
				//R[31]  = A[31];
				//R[31] = signA;
			end else
			begin
				fract_c = fract_r - fract_a;
				//R[31]  = signB;
				//R[31] = B[31];
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


endmodule
