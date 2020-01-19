module Computer(ResetN, Clock);
	localparam N = 8, M = 2, COUNT = 2**M, OP_LEN=20;
	
	wire [M-1:0] memSelect;
	wire [N-1:0] memData;
	wire memRW;
	wire done;
	wire [OP_LEN-1:0] opCode;
	
	Memory #(.N(N), .M(M)) mem (
		.ResetN(ResetN),
		.Clock(Clock),
		.Select(memSelect),
		.Data(memData),
		.RW(memRW)
	);
	
	Excutor #(.N(N), .M(M)) exec (
		.ResetN(ResetN),
		.Clock(Clock),
		.MemorySelect(memSelect),
		.MemoryData(memData),
		.MemoryRW(memRW),
		.OpCode(opCode),
		.Done(done)
	);

	
endmodule
