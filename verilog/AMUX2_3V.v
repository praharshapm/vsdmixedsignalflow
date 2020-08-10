// Analog 2-input, 1-output multiplexer
// with 1.8V digital select.
//
// NOTE:  This is a simple functional model only and captures
// none of the internal workings of the multiplexer, such
// as double-gating each input and connecting the middle node
// to VSSA on the unselected input.

module AMUX2_3V (
   input VDD, 
   input VSS,
   input I0,
   input I1,
   output out,
   input select
);
   wire VDD,VSS;
   wire I0, I1;
   wire out;
   wire select;
   wire NaN;

   initial begin
      NaN = 0.0 / 0.0;
   end

   assign out = (select == 1'b1) ? I1:
		 (select == 1'b0) ? I0 :
		 NaN;

endmodule
