`timescale 1ns / 100ps

module testOneHotEncoder;
	reg [2:0] Input;
	wire [7:0] Output;

	OneHotEncoder uut (
		.Input(Input), 
		.Output(Output)
	);

	initial begin
		#50;
		for(Input=0; Input< 10; Input=Input+1)
			#50;
	end
      
endmodule

