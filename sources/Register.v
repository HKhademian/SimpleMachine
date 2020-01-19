// N-bit register with
// * async reset (ResetN=0)
// * parallel load (Mode=Load)
// * shift left (Mode=SHL)
// * shift right (Mode=SHR)
module Register (
	ResetN, Clock, Mode, CIn, COut, Input, Output
);
	parameter ModeKeep = 2'b00;
	parameter ModeLoad = 2'b01;
	parameter ModeSHL = 2'b10;
	parameter ModeSHR = 2'b11;
	parameter N = 8;

	input ResetN, Clock, CIn;
	input [1:0] Mode;
	input [N-1:0] Input;
	
	output reg COut;
	output reg [N-1:0] Output;
	
	integer i;

	always @(negedge ResetN, posedge Clock) begin
		if(ResetN==0) begin
			Output <= 0;
			COut <= 0;
		end
		else case(Mode)
			ModeKeep: begin
				COut <= 0;
			end
			ModeLoad: begin
				COut <= 0;
				Output <= Input;
			end
			ModeSHL: begin
				COut <= Output[N-1];
				for(i=N-1; i>0; i=i-1)
					Output[i] <= Output[i-1];
				Output[0] <= CIn;
			end
			ModeSHR: begin
				COut <= Output[0];
				for(i=0; i<N-1; i=i+1)
					Output[i] <= Output[i+1];
				Output[N-1] <= CIn;
			end
		endcase
	end
endmodule
