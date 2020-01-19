`timescale 1ns / 100ps

module testOneHotDecoder;
	reg [7:0] Input;
	wire [2:0] Output;

	OneHotDecoder uut (
		.Input(Input), 
		.Output(Output)
	);

	initial begin
		#50;

		for(Input=1; 1 ; Input=Input<<1)
			#50;
	end
      
endmodule

