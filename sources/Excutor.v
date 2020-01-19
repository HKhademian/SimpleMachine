module Excutor(
	ResetN, Clock, OpCode, Done 
);
	input ResetN, Clock;
	input [19:0] OpCode;
	output reg Done ;
	
	wire bus, select, mode;
	Memory #(.N(8), .M(2)) mem (
		.ResetN(ResetN),
		.Clock(ResetN),
		.Select(select),
		.Mode(mode),
		.Bus(bus)
	);
	
	reg [2:0] T = 0;
	
	always @(negedge ResetN, posedge Clock)
		if(!ResetN) begin T=0; Done=0; end
		else begin
			T <= T+1;
			case(OpCode[19:16])
				default: begin end
			endcase
		end

endmodule
