module Bridge #(
	parameter N = 8
) (
	inout LHS, RHS, input On	
);

	wire off;
	not(off, On);
	cmos tg1(LHS,RHS,On,off);

endmodule
