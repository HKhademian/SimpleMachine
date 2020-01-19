module OneHotDecoder #(
	parameter N = 3,
	localparam COUNT = 2**N
) (
	input [COUNT-1:0] Input,
	output [N-1:0] Output
);
	reg [N-1:0] value;
	assign Output = value;
	
	integer i;
	always @* begin
		value=0;
		for(i=0; i<COUNT; i=i+1)
			if(Input[i])
				value=i;
	end
endmodule
