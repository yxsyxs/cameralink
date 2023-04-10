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
// Filename: GTP_OUTBUFDS.v
//
// Functional description: Differential Signaling Output Buffer
//
// Parameter description:
//      
//
// Port description:
//
// Revision:
//    06/18/14 - Initial version.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_OUTBUFDS #(
    parameter IOSTANDARD = "DEFAULT"
)(
    output O,
    output OB,
    input I
) /* synthesis syn_black_box */ ;
  
  initial begin
    case (IOSTANDARD)
    "LVDS", "MINI-LVDS", "SUB-LVDS","TMDS", "PPDS", "RSDS", "LVDS_18", "DEFAULT" :;
    default : begin
           $display("Attribute Syntax Error : The attribute IOSTANDARD on GTP_OUTBUFDS instance %m is set to %s.", IOSTANDARD);
           $finish;
              end
    endcase
    end

    buf (O, I);
    not (OB, I);

endmodule

