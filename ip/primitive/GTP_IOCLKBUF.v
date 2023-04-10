//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS RESERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename: GTP_IOCLKBUF.v
//
// Functional description:
//
// Parameter description:
//
// Port description:
//
// Revision:
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_IOCLKBUF
#(
    parameter GATE_EN = "FALSE"   //FALSE; TRUE
) 
(
output CLKOUT,
input CLKIN,
input DI
);       //synthesis syn_black_box 

reg reg1, reg2,reg3;

initial 
begin
  reg1 = 1'b0;
  reg2 = 1'b0;
end


initial 
begin
  if(GATE_EN=="FALSE")
    reg3 =1'b1;
  else
    if(GATE_EN=="TRUE")
       reg3 = 1'b0;
    else 
       $display ("GTP_IOCLKBUF error : illegal setting for GATE_EN");
end



always @(negedge CLKIN) begin
   if(reg3 == 1'b0) 
      begin
         reg2 <= reg1;
         reg1 <= DI;
      end
   else
      begin
        reg2 <= 1'b0;
        reg1 <= 1'b0;
      end
end

assign CLKOUT = (reg2 | reg3) & CLKIN;

endmodule




