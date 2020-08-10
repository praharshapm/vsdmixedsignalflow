

module AMUX2_3V_top (
   	input VDD, 
   	input VSS,
   	input I0,
   	input I1,
   	output out,
   	input select
);
   AMUX2_3V AMUX2_3V (
		.VDD (VDD),
		.VSS (VSS),
		.I0 (IO),
		.I1 (I1),
		.out (out),
		.select (select)
	);

endmodule
