// Memory module with 2^M cells of N-bit Registers
module Memory #(
	parameter N = 8, // N is each register size
	parameter M = 2 // M is selector bus size (max cell count is 2^M)
) (
	input ResetN, // async Reset
	input Clock, // posedge clock
	input [M-1:0] Select, // select cell bus
	inout [N-1:0] DataBus, // data i/o bus
	input RW // R=0/W=1 mode selector
);
	
	reg [M-1:0] Address; // holds address of last clock
	wire [N-1:0] data; // local data bus ready to write in bus (if in Read mode)
	assign DataBus = RW==1 ? 'bz : !ResetN? 0: data; // writes data to DataBus if in read mode else high-impedance to allow reads

	always @(negedge ResetN, posedge Clock)
		Address=!ResetN?0:Select;

	genvar k; // generative aproach, we can have as many registers as we want (choose by M param)
	localparam COUNT = 2**M;
	for(k=0; k<COUNT; k=k+1) begin: registers
		reg [N-1:0] value = 0;
		
		assign data = (RW || Address!=k)? 'bz : value; // writes to local data-bus if current register is selected
		
		always @(negedge ResetN, posedge Clock)
			value <= !ResetN? 0: (RW && Address==k)? DataBus: value; // write 0 on resets else if in read mode data remains unchanged else replaces by value presents on DataBus
	end

endmodule
