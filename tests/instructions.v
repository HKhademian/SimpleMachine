`timescale 1ns / 100ps

module instructions #(
	localparam N=8, M=2, COUNT=2**M, FREQ_T=5
);
	
	reg ResetN=0;
	reg Clock=0;
	reg [19:0] OpCode = 0;
	wire [1:0] MemorySelect;
	wire MemoryRW;
	wire Done;
	wire [N-1:0] MemoryData;
	wire [2*N-1:0] Output;
	wire SignFlag, ZeroFlag;
	integer i = 3'b0;
		reg [19:0] opCodes [23:0];

	Memory #(N, M) memu (
		.ResetN(ResetN),
		.Clock(Clock),
		.Select(MemorySelect),
		.DataBus(MemoryData),
		.RW(MemoryRW)
	);

	Excutor #(N, M) uut (
		.ResetN(ResetN), 
		.Clock(Clock), 
		.MemorySelect(MemorySelect), 
		.MemoryData(MemoryData), 
		.MemoryRW(MemoryRW), 
		.OpCode(OpCode), 
		.Output(Output), 
		.SignFlag(SignFlag), 
		.ZeroFlag(ZeroFlag), 
		.Done(Done)
	);

	always #FREQ_T Clock = ~Clock; // Clock generator
	
	initial begin: init
		$readmemb("instructions.txt", opCodes); // read all instructions

		ResetN = 0;
		#10; //wait for reset
		ResetN = 1;
		wait(Clock);

		for(i=0; i<24;) begin
			$display("Load Next Instruction");
			wait(Done & !Clock);// wait for exec done
			 i=i+1; // nicer view in signal diagram
			 OpCode = opCodes[i-1]; // load inst.
			wait(Clock); // wait to start exec
		end
		$finish;
		
	end
      
endmodule

