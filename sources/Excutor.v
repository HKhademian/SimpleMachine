module Excutor #(
	parameter N = 8, // memory each cell size (bits)
	parameter M = 2, // memory number of select bus wires (so max cell count is 2^M)
	localparam OP_LOAD_CONST = 4'b0001, // Load R1, C    ==> R1 = C
	localparam OP_LOAD_REG   = 4'b0010, // Load R1, R2   ==> R1 = R2
	localparam OP_ADD_CONST  = 4'b0011, // Add R1, C     ==> R1 = R1 + C
	localparam OP_ADD_REG    = 4'b0100, // Add R1, R2    ==> R1 = R1 + R2
	localparam OP_SUB_CONST  = 4'b0101, // Sub R1, C     ==> R1 = R1 - C
	localparam OP_SUB_REG    = 4'b0110, // Sub R1, R2    ==> R1 = R1 - R2
	localparam OP_MUL_CONST  = 4'b0111, // Mul R1, C     ==> [RD:RA] = R1*C
	localparam OP_MUL_REG    = 4'b1000, // Mul R1, R2    ==> [RD:RA] = R1*R2
	localparam OP_DIV_CONST  = 4'b1001, // Div R1, C     ==> R1 = R1 / C
	localparam OP_DIV_REG    = 4'b1010, // Div R1, R2    ==> R1 = R1 / R2
	localparam OP_SHL_CONST  = 4'b1011, // Shl R1, C     ==> R1 = R1 << C
	localparam OP_SHR_CONST  = 4'b1100, // Shr R1, C     ==> R1 = R1 >> C
	//localparam OP_SHL_REG    = 4'b1110, // Shl R1, C     ==> R1 = R1 << R2
	//localparam OP_SHR_REG    = 4'b1111, // Shr R1, C     ==> R1 = R1 >> R2
	localparam OP_FLOAT      = 4'b1101, //  Output = float of (C1.C2)
	localparam REG_A         = 0, // RegisterA address
	localparam REG_B         = 1, // RegisterB address
	localparam REG_C         = 2, // RegisterC address
	localparam REG_D         = 3 // RegisterD address
) (
	input ResetN, // async reset
	input Clock, // posedge Clock pulse
	output reg [M-1:0] MemorySelect, // Memory select bus
	inout [N-1:0] MemoryData, // Memory data bus
	output reg MemoryRW, // Memory choose R=0/W=1 mode
	input [19:0] OpCode, // operation to excute
	output reg Done, // Done signal
	
	output reg [2*N-1:0] Output,
	output reg SignFlag,
	output reg ZeroFlag
);	
	
	reg [3-1:0] Timer = 0; // supports 2^3 Timing Steps
	reg [N-1:0] memValue = 0;
	assign MemoryData = MemoryRW? memValue: {N{1'bz}};
	
	wire [  3:0] Part0 = OpCode[19:16];
	wire [N-1:0] Part1 = OpCode[15: 8];
	wire [N-1:0] Part2 = OpCode[ 7: 0];

	wire [2:0] R1Address, R2Address;
	OneHotDecoder #(3) r1decode ( Part1, R1Address );
	OneHotDecoder #(3) r2decode ( Part2, R2Address );
	
	always @(negedge ResetN, posedge Clock)
		if(!ResetN) begin
			SignFlag = 0;
			ZeroFlag = 0;
			Output = 0;
			memValue = 0;
			MemorySelect = 0;
			MemoryRW = 0;
			Timer = 0;
			Done = 1;
		end else begin
			case(Part0)
				default: begin // if no implemented op is detected signal DONE to get next
					MemorySelect =0;
					SignFlag = 0;
					ZeroFlag = 0;
					Output = 0;
					MemoryRW = 0;
					Timer = 0;
					Done = 1;
				end
				
				OP_LOAD_CONST: begin:OpLoadConst
					case(Timer)
						0: begin:step0 // Write CONST to R1
							MemoryRW = 1;
							MemorySelect = R1Address;
							Output[15:8] = 0;
							Output[7:0] = Part2;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // Signal DONE
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step1
					endcase
				end:OpLoadConst
				
				OP_LOAD_REG: begin:OpLoadReg
					case(Timer)
						0: begin:step0 // Read R2
							MemoryRW = 0;
							MemorySelect = R2Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // Write readed value to R1
							Output[15:8] = 0;
							Output[7:0] = MemoryData;
							memValue = Output[7:0];
							MemorySelect = R1Address;
							MemoryRW = 1;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // signal DONE
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpLoadReg
				
				OP_ADD_CONST: begin:OpAddConst
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // write R1+CONST to R1
							Output[15:8] = 0;
							Output[7:0] = MemoryData + Part2;
							memValue = Output[7:0];
							MemoryRW = 1;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpAddConst
				
				OP_ADD_REG: begin:OpAddReg
					case(Timer)
						0: begin:step0 // read R2
							MemoryRW = 0;
							MemorySelect = R2Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // save R2 value and read R1
							memValue = MemoryData;
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // write R1+R2 to R1
							Output[15:8] = 0;
							Output[7:0] = memValue + MemoryData;
							memValue = Output[7:0];
							MemoryRW = 1;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step2
						3: begin:step3 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step3
					endcase
				end:OpAddReg
				
				OP_SUB_CONST: begin:OpSubConst
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // write R1-CONST to R1
							MemorySelect = R1Address;
							MemoryRW = 1;
							Output[15:8] = 0;
							Output[7:0] = MemoryData - Part2;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpSubConst
				
				OP_SUB_REG: begin:OpSubReg
					case(Timer)
						0: begin:step0 // read R2
							MemorySelect = R2Address;
							MemoryRW = 0;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // save R2 value and read R1
							memValue = MemoryData;
							MemorySelect = R1Address;
							MemoryRW = 0;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // write R1-R2 to R1
							Output[15:8] = 0;
							Output[7:0] = MemoryData - memValue;
							MemorySelect = R1Address;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step2
						3: begin:step3 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step3
					endcase
				end:OpSubReg
				
				
				OP_MUL_CONST: begin:OpMulConst
					case(Timer)
						0: begin:step0 // read R1
							MemorySelect = R1Address;
							MemoryRW = 0;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // write lower byte to RegA and save upper
							Output = MemoryData * Part2;
							MemorySelect = REG_A;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // write upper byte to RegD
							MemorySelect = REG_D;
							MemoryRW = 1;
							memValue = Output[15:8];
							Timer = Timer+1;
							Done = 0;
						end:step2
						3: begin:step3 // signal DONE
							SignFlag = Output[15];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step3
					endcase
				end:OpMulConst
				
				OP_MUL_REG: begin:OpMulReg
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // save R1 value and read R2
							MemoryRW = 0;
							MemorySelect = R2Address;
							memValue = MemoryData;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // write lower byte to RegA and save upper
							Output = MemoryData * memValue;
							MemoryRW = 0;
							MemorySelect = REG_A;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step2
						3: begin:step3 // write upper byte to RegD
							MemoryRW = 0;
							MemorySelect = REG_D;
							MemoryRW = 1;
							memValue = Output[15:8];
							Timer = Timer+1;
							Done = 0;
						end:step3
						4: begin:step4 // signal DONE
							SignFlag = Output[15];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step4
					endcase
				end:OpMulReg
				
				OP_DIV_CONST: begin:OpDivConst
					case(Timer)
						0: begin:step0 // read R1
							MemorySelect = R1Address;
							MemoryRW = 0;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // write R1/CONST to R1
							Output[15:8] = 0;
							Output[7:0] = MemoryData / Part2;
							MemorySelect = R1Address;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpDivConst
				
				OP_DIV_REG: begin:OpDivReg
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // save R1 value and read R2
							MemorySelect = R2Address;
							MemoryRW = 0;
							memValue = MemoryData;
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // write R1/R2 to R1
							Output[15:8] = 0;
							Output[7:0] = memValue / MemoryData;
							MemorySelect = R1Address;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step2
						3: begin:step3 // signal DONE
							SignFlag = Output[7];
							ZeroFlag = Output == 0;
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step3
					endcase
				end:OpDivReg
				
				OP_SHL_CONST: begin:OpShiftLeftConst
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // Write R1<<CONST to R1
							Output[15:8] = 0;
							Output[7:0] = (MemoryData<<Part2);
							MemoryRW = 0;
							MemorySelect = R1Address;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // Signal DONE
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpShiftLeftConst
				
				OP_SHR_CONST: begin:OpShiftRightConst
					case(Timer)
						0: begin:step0 // read R1
							MemoryRW = 0;
							MemorySelect = R1Address;
							Timer = Timer+1;
							Done = 0;
						end:step0
						1: begin:step1 // Write R1>>CONST to R1
							Output[15:8] = 0;
							Output[7:0] = (MemoryData>>Part2);
							MemoryRW = 0;
							MemorySelect = R1Address;
							MemoryRW = 1;
							memValue = Output[7:0];
							Timer = Timer+1;
							Done = 0;
						end:step1
						2: begin:step2 // Signal DONE
							MemoryRW = 0;
							Timer = 0;
							Done = 1;
						end:step2
					endcase
				end:OpShiftRightConst

			endcase
		end

endmodule
