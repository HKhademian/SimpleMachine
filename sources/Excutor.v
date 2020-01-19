module Excutor#(
	parameter N = 8, // memory each cell size (bits)
	parameter M = 2 // memory number of select bus wires (so max cell count is 2^M)
) (
	input ResetN, // async reset
	input Clock, // posedge Clock pulse
	output reg [M-1:0] MemorySelect, // Memory select bus
	inout [N-1:0] MemoryData, // Memory data bus
	output reg MemoryRW, // Memory choose R=0/W=1 mode
	input [19:0] OpCode, // operation to excute
	output reg Done // Done signal
);	
	localparam OP_LOAD_CONST = 4'b0001; // Load R1, C    ==> R1 = C
	localparam OP_LOAD_REG   = 4'b0010; // Load R1, R2   ==> R1 = R2
	localparam OP_ADD_CONST  = 4'b0011; // Add R1, C     ==> R1 = R1 + C
	localparam OP_ADD_REG    = 4'b0100; // Add R1, R2    ==> R1 = R1 + R2
	localparam OP_SUB_CONST  = 4'b0101; // Sub R1, C     ==> R1 = R1 - C
	localparam OP_SUB_REG    = 4'b0110; // Sub R1, R2    ==> R1 = R1 - R2
	localparam OP_DIV_CONST  = 4'b1001; // Div R1, C     ==> R1 = R1 / C
	localparam OP_DIV_REG    = 4'b1010; // Div R1, R2    ==> R1 = R1 / R2
	localparam OP_SHL_CONST  = 4'b1011; // Shl R1, C     ==> R1 = R1 << C
	localparam OP_SHR_CONST  = 4'b1100; // Shr R1, C     ==> R1 = R1 >> C
	localparam OP_SHL_REG    = 4'b1101; // Shl R1, C     ==> R1 = R1 << R2
	localparam OP_SHR_REG    = 4'b1110; // Shr R1, C     ==> R1 = R1 >> R2
	localparam OP_MUL_CONST  = 4'b0111; // Mul R1, C     ==> [RD:RA] = R1*C
	localparam OP_MUL_REG    = 4'b1000; // Mul R1, R2    ==> [RD:RA] = R1*R2
	
	reg [2:0] Timer = 0; // supports 2^3 Timing Steps
	reg [N-1:0] memValue = 0;
	reg [N-1:0] memTemp = 0;
	assign MemoryData = MemoryRW? memValue: 'bz;
	
	wire [  3:0] Part0 = OpCode[19:16];
	wire [N-1:0] Part1 = OpCode[15: 8];
	wire [N-1:0] Part2 = OpCode[ 7: 0];

	wire [2:0] R1Address, R2Address;
	OneHotDecoder #(3) r1decode ( Part1, R1Address );
	OneHotDecoder #(3) r2decode ( Part2, R2Address );
	
	always @(negedge ResetN, posedge Clock)
		if(!ResetN) begin Timer=0; Done=0; end
		else begin
			Timer = Timer+1;
			MemoryRW = 0;
			MemorySelect = 0;
			Done = 0;
			
			case(Part0)
				default: begin Timer=0; Done=1; end
				
				OP_LOAD_CONST: begin:OpLoadConst
					case(Timer)
						1: begin:step1
							MemoryRW = 1;
							MemorySelect = R1Address;
							memValue = Part2;
							Done = 1;
						end:step1
					endcase
				end:OpLoadConst
				
				OP_LOAD_REG: begin:OpLoadReg
					case(Timer)
						1: begin:step1
							MemoryRW = 0;
							MemorySelect = R2Address;
							memValue = MemoryData;
						end:step1
						2: begin:step2
							MemoryRW = 1;
							MemorySelect = R1Address;
							Done = 1;
						end:step2
					endcase
				end:OpLoadReg
				
				
			endcase
		end

endmodule
