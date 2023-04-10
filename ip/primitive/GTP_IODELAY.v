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
// Library: General technology primitive
// Filename: GTP_IODELAY.v
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

module GTP_IODELAY #(
parameter [6:0] DELAY_STEP = 7'h00,
parameter integer DELAY_DEPTH = 7 
)(
output DO,
output DELAY_OB,
input  DI,
input  LOAD_N,
input  MOVE,
input  DIRECTION
) /* synthesis syn_black_box */ ;

//synthesis translate_off
reg [DELAY_DEPTH-1:0] DELAY_UNIT;

localparam integer DELAY_UB = 2**DELAY_DEPTH-1;

initial begin
   if(DELAY_DEPTH != 7 && DELAY_DEPTH != 4)
   begin
     $display("GTP_IODELAY Error: Illegal setting of DELAY_DEPTH %s, ONLY 7 or 4 supported",DELAY_DEPTH);
     $finish;
   end
   if(DELAY_STEP > DELAY_UB || DELAY_STEP < 0)
   begin
     $display("GTP_IODELAY Error: Illegal range of DELAY_STEP %s", DELAY_STEP);
     $finish;
   end
   DELAY_UNIT = 0;
end

always @(DELAY_STEP or LOAD_N) 
begin
   if (!LOAD_N)
      DELAY_UNIT <= DELAY_STEP;
end

always @(negedge MOVE)
begin
   if (!LOAD_N)
      DELAY_UNIT <= DELAY_STEP;
   else if (DIRECTION && (DELAY_UNIT != 0))
      DELAY_UNIT <= DELAY_UNIT - 1;
   else if ((~DIRECTION) && (DELAY_UNIT != DELAY_UB))
      DELAY_UNIT <= DELAY_UNIT + 1;
end

assign DELAY_OB = (DIRECTION && (DELAY_UNIT == 0)) || ((~DIRECTION) && (DELAY_UNIT == DELAY_UB));

wire [DELAY_UB:0] delay_chain;
assign delay_chain[0] = DI;
genvar gen_i;
generate  
   for(gen_i=1;gen_i< DELAY_UB + 1;gen_i=gen_i+1) 
   begin
      assign #0.025 delay_chain[gen_i] =  delay_chain[gen_i-1];
   end
endgenerate

assign DO = delay_chain[DELAY_UNIT];

//synthesis translate_on

endmodule
