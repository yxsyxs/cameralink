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
// Filename: GTP_ISERDES.v
//
// Functional description:
//
// Parameter description:
//
// Port description:
//
// Revision:
//   2016/10/18: Remove ISERDES_MODE parameter value "NONE"
//   2018/08/17: change IGDES4/7/8 to IDES4/7/8
//               change IGDDR to IDDR
//               by xxma
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_ISERDES #(
parameter ISERDES_MODE = "IDDR",   //"IDDR","IMDDR","IDES4","IMDES4","IDES7","IDES8","IMDES8"
parameter GRS_EN = "TRUE",          //"TRUE"; "FALSE"
parameter LRS_EN = "TRUE"           //"TRUE"; "FALSE"
)(
input        DI,
input        ICLK,
input        DESCLK,
input        RCLK,
input  [2:0] WADDR,
input  [2:0] RADDR,
input        RST,
output [7:0] DO
)/* synthesis syn_black_box */;

//synthesis translate_off

reg        DI_P_reg;
reg        DI_N_reg;
reg  [7:0] DI_P_mem;
reg  [7:0] DI_N_mem;
reg  [7:0] DO_reg;
reg  [7:0] shift_reg;
reg  [7:0] capture_reg;
wire       capture_en0;
wire       capture_en1;
wire       cnt_rst;
reg  [2:0] cnt;
reg        rstn_dly;
reg  [7:0] out_en;
reg        imem_mode;
reg  [3:0] idata_width;

wire [7:0] DO_int;
wire       RCLK_buf;
wire       ICLK_buf;
wire       DESCLK_buf;
wire       DI_buf;
wire [2:0] WADDR_buf;
wire [2:0] RADDR_buf;

initial begin
    if(GRS_EN != "TRUE" && GRS_EN != "FALSE")
    begin
      $display("GTP_ISERDES Error: Illegal setting of GRS_EN %s",GRS_EN);
      $finish;
    end
    if(LRS_EN != "TRUE" && LRS_EN != "FALSE")
    begin
      $display("GTP_ISERDES Error: Illegal setting of LRS_EN %s",LRS_EN);
      $finish;
    end
    case(ISERDES_MODE)
        "IDDR":   begin
                     imem_mode = 0;
                     idata_width = 2;
                     out_en = 8'b1100_0000;
                   end
        "IMDDR":   begin
                     imem_mode = 1;
                     idata_width = 2;
                     out_en = 8'b1100_0000;
                   end
        "IDES4":  begin
                     imem_mode = 0;
                     idata_width = 4;
                     out_en = 8'b1111_0000;
                   end
        "IMDES4":  begin
                     imem_mode = 1;
                     idata_width = 4;
                     out_en = 8'b1111_0000;
                   end
        "IDES7":  begin
                     imem_mode = 0;
                     idata_width = 7;
                     out_en = 8'b1111_1110;
                   end
        "IDES8":  begin
                     imem_mode = 0;
                     idata_width = 8;
                     out_en = 8'b1111_1111;
                   end
        "IMDES8":  begin
                     imem_mode = 1;
                     idata_width = 8;
                     out_en = 8'b1111_1111;
                   end
        default:   begin
                     $display("GTP_ISERDES Error: Illegal setting of ISERDES_MODE %s",ISERDES_MODE);
                     $finish;
                   end
    endcase
end
///////////////////////////////////////////////////////////////////////////
assign DI_buf = DI;
assign WADDR_buf = WADDR;
assign RADDR_buf = RADDR;
assign ICLK_buf =  (imem_mode) ? ICLK : ((idata_width == 2) ? RCLK : DESCLK);
assign DESCLK_buf = (idata_width == 2) ? RCLK : DESCLK;
assign RCLK_buf = RCLK;
assign DO = DO_int;
///////////////////////////////////////////////////////////////////////////
assign global_rstn = (GRS_EN == "TRUE") ? GRS_INST.GRSNET : 1'b1;
assign lrs_rstn = (LRS_EN == "TRUE") ? (~RST) : 1'b1;
///////////////////////////////////////////////////////////////////////////
//for input dule data rate
always @(posedge ICLK_buf or negedge global_rstn or negedge lrs_rstn) 
begin
   if (!global_rstn)
      DI_P_reg <= 0;
   else if (!lrs_rstn)
      DI_P_reg <= 0;
   else
      DI_P_reg <= DI_buf;
end
always @(negedge ICLK_buf or negedge global_rstn or negedge lrs_rstn) 
begin
   if (!global_rstn)
      DI_N_reg <= 0;
   else if (!lrs_rstn)
      DI_N_reg <= 0;
   else
      DI_N_reg <= DI_buf;
end
///////////////////////////////////////////////////////////////////////////
//for input dule data rate in mem mode
always @(negedge ICLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      DI_P_mem <= 0;
   else if (!lrs_rstn)
      DI_P_mem <= 0;
   else
      DI_P_mem[WADDR_buf] <= DI_P_reg;
end
always @(negedge ICLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      DI_N_mem <= 0;
   else if (!lrs_rstn)
      DI_N_mem <= 0;
   else
      DI_N_mem[WADDR_buf] <= DI_buf; 
end
///////////////////////////////////////////////////////////////////////////
wire q_pos,q_neg;
assign q_pos=DI_P_mem[RADDR_buf];
assign q_neg=DI_N_mem[RADDR_buf];

always @(posedge DESCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      shift_reg <= 0;
   else if (!lrs_rstn)
      shift_reg <= 0;
   else
   begin
      if(imem_mode)
          shift_reg <= {DI_N_mem[RADDR_buf], DI_P_mem[RADDR_buf], shift_reg[7:2]};
      else
          shift_reg <= {DI_N_reg, DI_P_reg, shift_reg[7:2]};
   end
end
///////////////////////////////////////////////////////////////////////////
always @(posedge DESCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      rstn_dly <= 0;
   else if (!lrs_rstn)
      rstn_dly <= 0;
   else
      rstn_dly <= 1'b1;
end
///////////////////////////////////////////////////////////////////////////
always @(posedge DESCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      cnt <= 0;
   else if (!lrs_rstn || cnt_rst)
      cnt <= 0;
   else if (rstn_dly)
      cnt <= cnt + 1;
end

assign cnt_rst = (idata_width == 4) ? (cnt == 1) :
                 ((idata_width == 8) ? (cnt == 3) :
                 ((idata_width == 7) ? (cnt == 6) : 1'b0));
assign capture_en0 = (idata_width == 4) ? (cnt == 1) :
                    ((idata_width == 8) ? (cnt == 3) :
                    ((idata_width == 7) ? (cnt == 2) : 1'b0));
assign capture_en1 = cnt == 5;
///////////////////////////////////////////////////////////////////////////
always @(posedge DESCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      capture_reg <= 0;
   else if (!lrs_rstn)
      capture_reg <= 0;
   else if (capture_en0)
      capture_reg <= shift_reg;
   else if (capture_en1 && (idata_width == 7))
      capture_reg <= {DI_P_reg, shift_reg[7:1]};
end
///////////////////////////////////////////////////////////////////////////
always @(posedge RCLK_buf or negedge global_rstn or negedge lrs_rstn)
begin
   if (!global_rstn)
      DO_reg <= 0;
   else if (!lrs_rstn)
      DO_reg <= 0;
   else
      DO_reg <= capture_reg;      
end
assign DO_int = out_en & ((idata_width == 2) ? shift_reg : DO_reg);

//synthesis translate_on

endmodule
