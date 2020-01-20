module Floater(
	input [7:0] A,
	input [7:0] B,
	output [15:0] Output
);
	reg sign = 0;
	reg [7:0] exponent = 0;
	reg [6:0] mantis = 'bx;
	assign Output = {sign, exponent, mantis};
	
	
	integer i, power, res, bb;
	reg [7:0] mant;
	always @* begin:calc
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

		if(A!=0) begin
			for(i=0; i<8; i=i+1)
				if(A[i])
					power=i; // find last 1 occured
			exponent = 127 + power;
			
			for(i=0; i<7; i=i+1)
				mantis[6-i] = i<power? A[power-i-1] : mant[7+power-i];
		end else begin
			for(i=0; i<7; i=i+1)
				if(mant[7-i])
					power=7-i; // find last 1 occured
			exponent = 127 - power;
			
			for(i=0; i<7; i=i+1)
				mantis[6-i] = i<7-power?mant[7-power-i]:0;
		end
		
	end

endmodule
