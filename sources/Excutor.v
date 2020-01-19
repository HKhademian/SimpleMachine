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
	reg [2:0] Timer = 0; // supports 2^3 Timing Steps
	
	always @(negedge ResetN, posedge Clock)
		if(!ResetN) begin Timer=0; Done=0; end
		else begin
			Timer <= Timer+1;
			case(OpCode[19:16])
				default: begin end
			endcase
		end

endmodule
