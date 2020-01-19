// Memory module with 2^M cells of N-bit Registers
module Memory #(
	parameter N = 8,
	parameter M = 2
) (
	ResetN, Clock, Bus, Select, RW
);
	localparam COUNT = 2**M;

	input ResetN, Clock, RW;
	input [M-1:0] Select;
	inout [N-1:0] Bus;
	
	reg [M-1:0] Address;
	wire [N-1:0] data;
	assign Bus = RW==1 ? 'bz : !ResetN? 0: data;

	always @(negedge ResetN, posedge Clock)
		Address=Select;

	genvar k;
	for(k=0; k<COUNT; k=k+1) begin: registers
		reg [N-1:0] value = 1<<k;
		
		assign data = (RW || Address!=k)? 'bz : value;
		
		always @(negedge ResetN, posedge Clock)
			value <= !ResetN? 0: (RW && Address==k)? Bus: value;

	end

endmodule
