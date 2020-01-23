module Floater(
	input ResetN,
	input Clock,
	input [7:0] A,
	input [7:0] B,
	output [15:0] Output
);
	reg sign;
	reg [7:0] exponent;
	reg [6:0] mantis = 'bx;
	assign Output = {sign, exponent, mantis};
	
	integer i, power, res, bb;
	reg [7:0] mant, aa;
	always @(negedge ResetN, posedge Clock)
		if(!ResetN) begin
			sign = 0;
			exponent = 0;
			mantis = 0;
		end else begin:calc
			sign = A[7];
			aa = sign? -A: A;
			 
			mantis = 'bx;
			i='bx;
			power='bx;
			res='bx;
			bb='bx;
			
			bb = B;
			for(i=0; i<8; i=i+1) begin: tobin
				res = bb * 2;
				mant[7-i] = res>=10;
				bb = res % 10;
			end

			if(aa!=0) begin
				for(i=0; i<8; i=i+1)
					if(aa[i])
						power=i; // find last 1 occured
				exponent = 127 + power;
				
				for(i=0; i<7; i=i+1)
					mantis[6-i] = i<power? aa[power-i-1] : mant[7+power-i];
			end else begin
				for(i=0; i<7; i=i+1)
					if(mant[7-i])
						power=7-i; // find last 1 occured
				exponent = 127 - power;
				
				for(i=0; i<7; i=i+1)
					mantis[6-i] = i<7-power?mant[7-power-i]:0;
			end
		
	end:calc

endmodule
