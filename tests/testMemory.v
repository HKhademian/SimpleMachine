`timescale 1ns / 100ps

module testMemory;
	localparam N = 8, M = 3, COUNT=2**M;

	reg [7:0] value = 8'b10101010;
	
	reg ResetN=1;
	reg Clock=0;
	reg RW=0;
	reg [M-1:0] Select=0;
	wire [7:0] Bus;
	
	Memory #(
		.N(N),
		.M(M)
	) uut (
		.ResetN(ResetN), 
		.Clock(Clock), 
		.Select(Select), 
		.RW(RW), 
		.Bus(Bus)
	);

	assign Bus = RW? value: 'bz;
	always #13 Clock = ~Clock;

	integer i;
	initial begin
		RW=0;
		for(i=0; i<COUNT; i=i+1) begin
			Select=i;
			#50;
		end
		
		ResetN =0;
		#50;
		ResetN =1;
		#50;

		RW=0;
		for(i=0; i<COUNT; i=i+1) begin
			Select=i;
			#50;
		end
		
		Select=0;
		value = 74;
		RW=1;
		#50;
		
		RW=0;
		while(1)
		for(i=0; i<COUNT; i=i+1) begin
			Select=i;
			#50;
		end
		
	end
	
      
endmodule

