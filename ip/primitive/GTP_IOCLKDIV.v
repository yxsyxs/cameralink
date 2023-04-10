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
// Filename: GTP_IOCLKDIV.v
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

module GTP_IOCLKDIV #(
parameter DIV_FACTOR = "2", //"2"; "3.5"; "4"; "5"; 
parameter GRS_EN = "TRUE" //"TRUE"; "FALSE"
)(
output CLKDIVOUT,
input CLKIN,
input RST_N
);                        // synthesis syn_black_box

//synthesis translate_off
assign global_rstn = ((GRS_EN == "TRUE" )? GRS_INST.GRSNET : 1'b1);

reg rstn_dly;
reg [3:0] cnt;
reg CLKI_div2;
reg CLKI_DIV_reg;
reg CLKI_DIV_reg_neg;


initial begin
// parameter check
if ((DIV_FACTOR == "2") || (DIV_FACTOR == "3.5") ||  (DIV_FACTOR == "4") || (DIV_FACTOR == "5")) begin
end
else
   $display (" GTP_IOCLKDIV error: illegal setting for DIV_FACTOR");

if ((GRS_EN == "TRUE")  || (GRS_EN == "FALSE")) begin
end
else
   $display (" GTP_IOCLKDIV error: illegal setting for GRS_EN");

rstn_dly          = 0;
cnt               = 0;
CLKI_div2         = 0;
CLKI_DIV_reg      = 0;
CLKI_DIV_reg_neg  = 0;
end


always @(posedge CLKIN or negedge global_rstn or negedge RST_N)
   if (!global_rstn)
      rstn_dly <= 1'b0;
   else if (!RST_N)   
      rstn_dly <= 1'b0;
   else
      rstn_dly <= 1'b1;

always @(posedge CLKIN or negedge rstn_dly)
   if (!rstn_dly)
      CLKI_div2 <= 0;
   else
      CLKI_div2 <= ~ CLKI_div2;

always @(posedge CLKIN or negedge global_rstn or negedge RST_N)
   if (!global_rstn)
      cnt <= 0;
   else if (!RST_N)
      cnt <= 0;
   else if ((DIV_FACTOR == "3.5") && (cnt == 6))
      cnt <= 0;
   else if ((DIV_FACTOR == "4") && (cnt == 7))
      cnt <= 0;
   else if ((DIV_FACTOR == "5") && (cnt == 9))
      cnt <= 0;
   else   
      cnt <= cnt + 1;

always @(posedge CLKIN or negedge global_rstn or negedge RST_N)
   if (!global_rstn)
      CLKI_DIV_reg <= 1'b0;
   else if (!RST_N)
      CLKI_DIV_reg <= 1'b0;
   else if (DIV_FACTOR == "3.5") begin
      if (cnt == 1)
         CLKI_DIV_reg <= 1'b1;
      else if (cnt == 3)   
         CLKI_DIV_reg <= 1'b0;
   end      
   else if (DIV_FACTOR == "4") begin
      if (cnt == 1)
         CLKI_DIV_reg <= 1'b1;
      else if (cnt == 3)   
         CLKI_DIV_reg <= 1'b0;
      else if (cnt == 5)   
         CLKI_DIV_reg <= 1'b1;
      else if (cnt == 7)
         CLKI_DIV_reg <= 1'b0;      
   end
   else if (DIV_FACTOR == "5") begin
      if (cnt == 1)
         CLKI_DIV_reg <= 1'b1;
      else if (cnt == 4)   
         CLKI_DIV_reg <= 1'b0;
      else if (cnt == 6)   
         CLKI_DIV_reg <= 1'b1;
      else if (cnt == 9)
         CLKI_DIV_reg <= 1'b0;          
   end        

always @(negedge CLKIN or negedge global_rstn or negedge RST_N)
   if (!global_rstn)
      CLKI_DIV_reg_neg <= 1'b0;
   else if (!RST_N)
      CLKI_DIV_reg_neg <= 1'b0;     
   else if (DIV_FACTOR == "3.5") begin
      if (cnt == 5)
         CLKI_DIV_reg_neg <= 1'b1;
      else if (cnt == 0)   
         CLKI_DIV_reg_neg <= 1'b0;
   end
      
assign CLKDIVOUT = ((DIV_FACTOR == "2") ? CLKI_div2 : (CLKI_DIV_reg_neg | CLKI_DIV_reg));       
//synthesis translate_on


endmodule
