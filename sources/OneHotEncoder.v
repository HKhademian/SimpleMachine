module OneHotEncoder #(
	parameter N = 3, Level= 1'b1
) (
	Input, Output
);
	localparam COUNT = 2**N;

	input [N-1:0] Input;
	output [COUNT-1:0] Output;

	assign Output = 2**Input;
endmodule
