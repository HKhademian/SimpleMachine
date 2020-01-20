`timescale 1ns / 100ps

module testFloater;
	reg [7:0] A;
	reg [7:0] B;
	wire [15:0] Output;

	Floater uut (
		.A(A), 
		.B(B), 
		.Output(Output)
	);

	initial begin
		//A = 1;
		//B = 7;
		//#25;

		A = 2;
		B = 5;
		#25;

		A = 1;
		B = 2;
		#25;

		A = 9;
		B = 4;
		#25;

		A = 0;
		B = 3;
		#25;

		A = 18;
		B = 0;
		#25;

	end
      
endmodule

