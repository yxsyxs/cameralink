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
// Filename: GTP_OSERDES.v
//
// Functional description:
//
// Parameter description:
//
// Port description:
//
// Revision:
//   2016/10/18: Remove OSERDES_MODE parameter value "NONE"
//   2018/03/14: ADD DYNAMIC MIPI SELECT
//   2018/03/29: delete MIPI_sel and MIPI_sel ctrl for DO
//   2018/08/17: change OGSER4/7/8 to OSER4/7/8
//               change OGDDR to ODDR 
//               by xxma
////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_OSERDES #(
parameter OSERDES_MODE = "ODDR",  //"ODDR","OMDDR","OSER4","OMSER4","OSER7","OSER8",OMSER8"
parameter WL_EXTEND = "FALSE",     //"TRUE"; "FALSE"
parameter GRS_EN = "TRUE",         //"TRUE"; "FALSE"
parameter LRS_EN = "TRUE",          //"TRUE"; "FALSE"
parameter TSDDR_INIT = 1'b0         //1'b0;1'b1
)(
output      DO,
output      TQ,
input [7:0] DI,
input [3:0] TI,
input       RCLK,
input       SERCLK,
input       OCLK,
input       RST
);  // synthesis syn_black_box

//synthesis translate_off
///////////////////////////////////////////////////////////////////////////
reg  [7:0] d_rclk;
reg  [3:0] t_rclk;
reg  [7:0] capture_d_reg;
reg  [3:0] capture_t_reg;
reg  [7:0] shift_d_reg;
reg  [3:0] shift_t_reg;
reg        DO_POS;
reg        TO_reg;
reg        DO_NEG;
wire       shift_en_oclk;
reg  [2:0] cnt;
reg  [1:0] cnt_oclk;
wire       cnt_rst;
wire       capture_en0;
wire       capture_en1;
reg        shift_en_oclk_d;

reg        rstn_dly;
reg        rstn_dly_oclk;
reg  [7:0] in_en;
wire [3:0] int_en;
reg        omem_mode;
reg  [3:0] odata_width;
wire       RCLK_buf;
wire       SERCLK_buf;
wire       OCLK_buf;
wire       DO_buf;
wire       TO_buf;
wire [7:0] DI_buf;
wire [3:0] TI_buf;
///////////////////////////////////////////////////////////////////////////
initial begin
    if(GRS_EN != "TRUE" && GRS_EN != "FALSE")
    begin
      $display("GTP_OSERDES Error: Illegal setting of GRS_EN %s",GRS_EN);
      $finish;
    end
    if(LRS_EN != "TRUE" && LRS_EN != "FALSE")
    begin
      $display("GTP_OSERDES Error: Illegal setting of LRS_EN %s",LRS_EN);
      $finish;
    end
    case(OSERDES_MODE)
        "ODDR":   begin
                     omem_mode = 0;
                     odata_width = 2;
                     in_en = 8'b0000_0011;
                   end
        "OMDDR":   begin
                     omem_mode = 1;
                     odata_width = 2;
                     in_en = 8'b0000_0011;
                   end
        "OSER4":  begin
                     omem_mode = 0;
                     odata_width = 4;
                     in_en = 8'b0000_1111;
                   end
        "OMSER4":  begin
                     omem_mode = 1;
                     odata_width = 4;
                     in_en = 8'b0000_1111;
                   end
        "OSER7":  begin
                     omem_mode = 0;
                     odata_width = 7;
                     in_en = 8'b0111_1111;
                   end
        "OSER8":  begin
                     omem_mode = 0;
                     odata_width = 8;
                     in_en = 8'b1111_1111;
                   end
        "OMSER8":  begin
                     omem_mode = 1;
                     odata_width = 8;
                     in_en = 8'b1111_1111;
                   end
        default:   begin
                     $display("GTP_OSERDES Error: Illegal setting of OSERDES_MODE %s",OSERDES_MODE);
                     $finish;
                   end
    endcase
end

initial begin
d_rclk           = 0;
t_rclk           = 0;
capture_d_reg    = 0;
capture_t_reg    = 0;
shift_d_reg      = 0;
shift_t_reg      = 0;
DO_POS         = 0;
TO_reg         = 0;
DO_NEG         = 0;
cnt              = 0;
cnt_oclk         = 0;
shift_en_oclk_d  = 0;
end

///////////////////////////////////////////////////////////////////////////
assign DI_buf = in_en & DI;
assign TI_buf = {in_en[6],in_en[4],in_en[2],in_en[0]} & TI;
assign RCLK_buf = RCLK;
assign SERCLK_buf = (odata_width == 2) ? ((omem_mode) ? OCLK : RCLK) : SERCLK;
assign OCLK_buf =  (omem_mode) ? OCLK : ((odata_width == 2) ? RCLK : SERCLK);
assign DO = DO_buf;
assign TQ = TO_buf;

assign init = (TSDDR_INIT == 1'b0) ? 1'b0 : 1'b1;
///////////////////////////////////////////////////////////////////////////
assign global_rstn = (GRS_EN == "TRUE") ? GRS_INST.GRSNET : 1'b1;
assign lrs_rstn = (LRS_EN == "TRUE") ? (~RST) : 1'b1;
///////////////////////////////////////////////////////////////////////////
always @(posedge RCLK_buf or negedge global_rstn or negedge lrs_rstn) begin
   if (!global_rstn) begin
      d_rclk <= 0;
      t_rclk <= {4{init}};
   end
   else if (!lrs_rstn) begin
      d_rclk <= 0;
      t_rclk <= {4{init}};
   end
   else begin
      d_rclk <= DI_buf;
      t_rclk <= TI_buf;
   end
end
///////////////////////////////////////////////////////////////////////////
always @(posedge SERCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      rstn_dly <= 0;
   else if (!lrs_rstn)
      rstn_dly <= 0;
   else
      rstn_dly <= 1'b1;
end
always @(posedge SERCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      cnt <= 0;
   else if (!lrs_rstn || cnt_rst)
      cnt <= 0;
   else if (rstn_dly)
      cnt <= cnt + 1;
end

assign cnt_rst = (odata_width == 4) ? (cnt == 1) :
                ((odata_width == 8) ? (cnt == 3) :
                ((odata_width == 7) ? (cnt == 6) : 1'b1));
assign capture_en0 = (odata_width == 4) ? (cnt == 1) :
                    ((odata_width == 8) ? (cnt == 2) :
                    ((odata_width == 7) ? (cnt == 2) : 1'b1));
assign capture_en1 = cnt == 5;

always @(posedge SERCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
   begin
      capture_d_reg <= 0;
      capture_t_reg <= {4{init}};
   end else if (!lrs_rstn)
   begin
      capture_d_reg <= 0;
      capture_t_reg <= {4{init}};
   end else
   begin
      if (capture_en0)
      begin
         capture_d_reg <= d_rclk;
         capture_t_reg <= t_rclk;
      end else if (capture_en1 && (odata_width == 7))
         capture_d_reg <= {d_rclk[6:0], capture_d_reg[6]};
   end
end
///////////////////////////////////////////////////////////////////////////
wire cnt_rst_oclk;
wire shift_en;
reg  shift_en_v;

always @(posedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      rstn_dly_oclk <= 0;
   else if (!lrs_rstn)
      rstn_dly_oclk <= 0;
   else
      rstn_dly_oclk <= 1'b1;
end

always @(posedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      cnt_oclk <= 0;
   else if (!lrs_rstn)
      cnt_oclk <= 0;
   else if (rstn_dly_oclk)
      cnt_oclk <= cnt_oclk + 1;
end

assign shift_en_oclk = (odata_width == 4) ? (cnt_oclk == 2 | cnt_oclk == 0 & rstn_dly_oclk) :
                      ((odata_width == 8) ? (cnt_oclk == 1) :
                      ((odata_width == 7) ? shift_en_v : 1'b0));

always @(posedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
   begin
      shift_en_v <= 0;
      shift_en_oclk_d <= 0;
   end else if (!lrs_rstn)
   begin
      shift_en_v <= 0;
      shift_en_oclk_d <= 0;
   end else begin
      shift_en_v <= capture_en0 | capture_en1;
      shift_en_oclk_d <= shift_en_oclk;
   end
end

assign shift_en = (WL_EXTEND == "FALSE") ? shift_en_oclk : shift_en_oclk_d;

always @(posedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
   if (!global_rstn) begin
      shift_d_reg <= 0;
      shift_t_reg <= {4{init}};
   end
   else if (!lrs_rstn) begin
      shift_d_reg <= 0;
      shift_t_reg <= {4{init}};
   end
   else if (shift_en) begin
      shift_d_reg <= capture_d_reg;
      shift_t_reg <= capture_t_reg;
   end
   else begin
      shift_d_reg <= {2'd0, shift_d_reg[7:2]};
      shift_t_reg <= {init, shift_t_reg[3:1]};
   end
///////////////////////////////////////////////////////////////////////////
always @(posedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn) begin
      DO_POS <= 0;
      TO_reg <= init;
   end else if (!lrs_rstn) begin
      DO_POS <= 0;
      TO_reg <= init;
   end else if(odata_width == 2)
   begin
      DO_POS <= capture_d_reg[1];
      TO_reg <= capture_t_reg[0];
   end else
   begin
      DO_POS <= shift_d_reg[1];
      TO_reg <= shift_t_reg[0];
   end
end

always @(negedge OCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn) begin
      DO_NEG <= 0;
   end else if (!lrs_rstn) begin
      DO_NEG <= 0;
   end else if(odata_width == 2)
      DO_NEG <= capture_d_reg[0];
   else
      DO_NEG <= shift_d_reg[0];
end

assign DO_buf = OCLK_buf ? DO_NEG : DO_POS;
assign TO_buf = TO_reg;

//synthesis translate_on

endmodule
