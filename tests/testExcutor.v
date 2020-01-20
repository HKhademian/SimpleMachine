`timescale 1ns / 100ps
module testExcutor;

	reg ResetN = 1;
	reg Clock = 0;
	reg [19:0] OpCode = 0;
	wire [1:0] MemorySelect;
	wire MemoryRW;
	wire Done;
	wire [7:0] MemoryData;

	Memory #(8, 2) memu (
		.ResetN(ResetN),
		.Clock(Clock),
		.Select(MemorySelect),
		.DataBus(MemoryData),
		.RW(MemoryRW)
	);

	Excutor uut (
		.ResetN(ResetN), 
		.Clock(Clock), 
		.MemorySelect(MemorySelect), 
		.MemoryData(MemoryData), 
		.MemoryRW(MemoryRW), 
		.OpCode(OpCode), 
		.Done(Done)
	);

	always #17 Clock = ~Clock;
	
	initial begin
		ResetN=0;
		#25;
		ResetN=1;
		
		wait(!Clock);
		OpCode = 20'b0001_00000010_10101010;
		#25;
		wait(Done);
		OpCode = 0;
		#25;
		
		wait(!Clock);
		OpCode = 20'b0001_00000001_00000000;
		OpCode[7:0] = 74;
		#25;
		wait(Done);
		OpCode = 0;
		#25;
		
		wait(!Clock);
		OpCode = 20'b0010_00000001_00000010;
		wait(Done);
		OpCode = 0;
		#25;
		
		wait(!Clock);
		OpCode = 20'b0011_00000001_00000001;
		#25;
		wait(Done);
		OpCode = 0;
		#25;
		
		wait(!Clock);
		OpCode = 20'b0011_00000001_00000001;
		#25;
		wait(Done);
		OpCode = 0;
		#25;
		
		
		
		
		wait(!Clock);
		OpCode = 20'b0001_00000001_00000000; // R0=0
		#25;
		wait(Done);
		OpCode = 0;
		#25;

		
		wait(!Clock);
		OpCode = 20'b0011_00000001_00000111; // R0+=7
		#25;
		wait(Done);
		OpCode = 0;
		#25;
		
		wait(!Clock);
		OpCode = 20'b0011_00000001_00000111; // R0+=7
		#25;
		wait(Done);
		OpCode = 0;
		#25;

		wait(!Clock);
		OpCode = 20'b0101_00000001_00000011; // R0-=3
		#25;
		wait(Done);
		OpCode = 0;
		#25;

		wait(!Clock);
		OpCode = 20'b0101_00000001_00000001; // R0-=1
		#25;
		wait(Done);
		OpCode = 0;
		#25;

	end
      
endmodule

