`timescale 1ns / 1ps
module main( input A, input B, input S, output C );
	Bridge bridgeA(
		.LHS(A),
		.RHS(C),
		.On(S)
	);
	Bridge bridgeB(
		.LHS(B),
		.RHS(C),
		.On(~S)
	);

endmodule
