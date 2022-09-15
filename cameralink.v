`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/28 10:22:34
// Design Name: 
// Module Name: stream_clink
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cameralink #(
    parameter  integer   ROW   = 1024 ,
    parameter  integer   COL   = 1280 ,
	parameter  integer   pixel = 24   
)
(
  input   wire                  ACLK       ,    // 50M
  input   wire                  ARESETn    ,

  output  wire                  TX_1_P       ,
  output  wire                  TX_2_P       ,
  output  wire                  TX_3_P       ,
  output  wire                  TX_4_P       ,

  output  wire                  TX_1_N       ,
  output  wire                  TX_2_N       ,
  output  wire                  TX_3_N       ,
  output  wire                  TX_4_N       ,
  
  output  wire                  XCLK_P       ,
  output  wire                  XCLK_N       


);

/*ce shi */
wire                  TVALID   ;
wire                  TREADY   ;
wire [23 : 0]         TDATA    ;
wire                  TLAST    ;
wire                  TUSER    ;

reg  [20 : 0]  data_cnt;
wire           data_en   ;
reg  [10 : 0]  row_cnt_o_ceshi   ;
reg  [10 : 0]  col_cnt_o_ceshi   ;
reg  [7  : 0]  data_temp         ;


assign   TVALID  =  'd1  ; 
assign TDATA  = ( data_en == 1 ) ?  {data_temp[7 : 0],data_temp[7 : 0],data_temp[7 : 0]} : 24'd0 ;
//assign  TDATA = 'd16777215 ;
assign data_en   =   TVALID && TREADY ;
assign  TLAST  =  ( col_cnt_o_ceshi == COL - 1'd1)  ?  'd1  :  'd0   ;

 always @(posedge ACLK)
 begin
     if (!ARESETn)
     begin
         data_cnt <= 'b0;
     //    video_out_tdata <= 'd0  ;
     end
     else if  ( data_en )
     begin
         if (data_cnt >= COL * ROW - 1'd1 )
             data_cnt <= 'b0;
         else
             data_cnt <= data_cnt + 'b1;        
     end
     else
        data_cnt  <=  data_cnt  ;
 end

always @(*)
 begin

    if (col_cnt_o_ceshi  <=  639)   
        data_temp  =  'd20  ;  
    else if (col_cnt_o_ceshi  <=  1279) 
        data_temp  =  'd255  ;
 
 end


  always @(posedge ACLK)
 begin
    if (!ARESETn) begin
        row_cnt_o_ceshi  <=  'd0  ;
        col_cnt_o_ceshi  <=  'd0  ; 
    end 
    else if (data_en) begin
        if ((row_cnt_o_ceshi >= ROW - 1'd1) && (col_cnt_o_ceshi >= COL - 1'd1))  begin
            row_cnt_o_ceshi   <=  'd0  ;
            col_cnt_o_ceshi   <=  'd0  ;
        end
        else  begin
            if (col_cnt_o_ceshi >= COL - 1'd1 ) begin
                col_cnt_o_ceshi  <=  'd0 ;
                row_cnt_o_ceshi  <=  row_cnt_o_ceshi + 1'd1  ;
            end
            else begin
                col_cnt_o_ceshi  <=  col_cnt_o_ceshi + 1'd1  ;
                row_cnt_o_ceshi  <=  row_cnt_o_ceshi    ;   
            end    
        end
    end
    else begin
        if ( row_cnt_o_ceshi == ROW && col_cnt_o_ceshi == COL ) begin
            row_cnt_o_ceshi  <=  'd0  ;
            col_cnt_o_ceshi  <=  'd0  ;
        end
        else begin
            row_cnt_o_ceshi  <=  row_cnt_o_ceshi  ;
            col_cnt_o_ceshi  <=  col_cnt_o_ceshi  ;
        end
    end
 end

/*.........................................*/
      
reg    [10 : 0]    row_cnt_o     ;
reg    [10 : 0]    col_cnt_o     ;
reg    [9  : 0]    line_deep_cnt ;
reg    [15  : 0]    frame_deep_cnt ;


reg    [23 : 0]    tdata_1       ;
reg                pixel_en_1    ;
reg                ARESETn_1     ;
wire               process_clk   ;

wire               pixel_en      ; 
reg    [10 : 0]    row_cnt_i     ;
reg    [10 : 0]    col_cnt_i     ;

wire   [7 : 0]     porta         ;
wire   [7 : 0]     portb         ;
wire   [7 : 0]     portc         ; 

wire   [6 : 0]     shift_tx1     ;     // R0 - R5 、G0      
wire   [6 : 0]     shift_tx2     ;     // G1 - G5 、B0 - B1
wire   [6 : 0]     shift_tx3     ;     // B2 - B5 、H 、V 、D
wire   [6 : 0]     shift_tx4     ;     // R6 - R7 、G6 - G7 、B6 - B7 、space

wire               tx1           ;
wire               tx2           ;
wire               tx3           ;
wire               tx4           ;
wire               cml_clk       ;

reg                vsync         ;
reg                hsync         ;
reg                dvalue        ;
wire               space         ;

reg                vsync_1         ;
reg                hsync_1         ;
reg                dvalue_1        ;
reg                rd_en_1          ;
reg                prog_full_1        ;

reg    [3 : 0]     bit_cnt       ;
reg    [3 : 0]     cml_bit_cnt   ;
reg    [6 : 0]     cml_clk_reg   ;

wire               rd_en         ;
wire               wr_en         ;
wire               prog_full          ;
wire               full          ;
wire               empty         ;
wire   [23 : 0]    fifo_data_o   ;
reg    [23 : 0]    fifo_data_o_1 ;
wire               bin_clk       ;
wire               almost_empty  ;
wire               almost_full   ;

assign   pixel_en    = TVALID && TREADY         ;

     
assign   porta       =   fifo_data_o_1[7  : 0 ]       ;
assign   portb       =   fifo_data_o_1[15 : 8 ]       ;
assign   portc       =   fifo_data_o_1[23 : 16]       ;

assign   shift_tx1   = {portb[0]       ,  porta[5 : 0]}                        ;
assign   shift_tx2   = {portc[1 : 0]   ,  portb[5 : 1]}                        ;
assign   shift_tx3   = {dvalue_1 , vsync_1 , hsync_1 , portc[5 : 2]}                 ;
assign   shift_tx4   = {space , portc[7 : 6] , portb[7 : 6] , porta[7 : 6]}    ;

assign   tx1         =    shift_tx1[6 - cml_bit_cnt]    ;
assign   tx2         =    shift_tx2[6 - cml_bit_cnt]    ;
assign   tx3         =    shift_tx3[6 - cml_bit_cnt]    ;
assign   tx4         =    shift_tx4[6 - cml_bit_cnt]    ;
assign   cml_clk     =    cml_clk_reg[cml_bit_cnt] ;




/*打拍*/
always @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
        tdata_1      <=  'd0           ;
        cml_clk_reg  <=  7'b11_000_11  ;
        prog_full_1   <=  'd0               ;
        pixel_en_1   <= 'd0            ;
    end
    else begin
        tdata_1      <=  TDATA         ;     //给数据做是时钟同步处理，在上升沿采样数据   
        prog_full_1      <=    prog_full           ;
        pixel_en_1   <=  pixel_en      ;  
    end 
end

always @(posedge bin_clk or negedge ARESETn) begin
    if(!ARESETn) begin
        ARESETn_1    <=  'd0           ;
        fifo_data_o_1  <=   'd0        ;
        vsync_1     <=   'd0           ;
        hsync_1     <=   'd0           ;
        dvalue_1    <=   'd0           ;  
        rd_en_1     <=      'd0         ;      
    end
    else begin   
        ARESETn_1    <=  ARESETn       ;
        fifo_data_o_1  <=  fifo_data_o  ;
        vsync_1      <=   vsync        ;
        hsync_1      <=   hsync         ;
        dvalue_1     <=   dvalue        ;
        rd_en_1     <=    rd_en        ;
    end 
end

/*ji shu*/

always @(posedge ACLK or negedge ARESETn ) begin   //row:0 - (row-1)  col : 1 - col
    if (!ARESETn) begin
        row_cnt_i  <=  'd0  ;
        col_cnt_i  <=  'd0  ; 
    end 
    else if (pixel_en) begin
        if ((row_cnt_i >= ROW - 1'd1) && (col_cnt_i >= COL))  begin
            row_cnt_i   <=  'd0  ;
            col_cnt_i   <=  'd1  ;
        end
        else  begin
            if (col_cnt_i >= COL ) begin
                col_cnt_i  <=  'd1               ;
                row_cnt_i  <=  row_cnt_i + 1'd1  ;
            end
            else begin
                col_cnt_i  <=  col_cnt_i + 1'd1  ;
                row_cnt_i  <=  row_cnt_i         ;   
            end    
        end
    end
    else begin
        if ( row_cnt_i == ROW && col_cnt_i == COL ) begin
            row_cnt_i  <=  'd0  ;
            col_cnt_i  <=  'd0  ;
        end
        else begin
            row_cnt_i  <=  row_cnt_i  ;
            col_cnt_i  <=  col_cnt_i  ;
        end
    end
end

always @(posedge process_clk or negedge ARESETn ) begin
    if ( !ARESETn )  begin
        bit_cnt   <=  'd0  ;
    end
    else  begin
        if ( bit_cnt == 4'd6 ) 
            bit_cnt  <=  'd0   ;
        else
            bit_cnt  <=  bit_cnt + 'd1  ; 
    end
end

always @(posedge process_clk or negedge ARESETn ) begin
    if ( !ARESETn )  begin
        cml_bit_cnt   <=  'd0  ;
    end
    else begin
        if ( ARESETn_1 ) begin
            if ( cml_bit_cnt == 4'd6 ) 
                cml_bit_cnt  <=  'd0   ;
            else
                cml_bit_cnt  <=  cml_bit_cnt + 'd1  ; 
        end 
    end

end

/*shu ru*/



/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

localparam integer hsync_a   =    10    ;      
localparam integer hsync_b   =    30    ;    //112 + 248 = 360
localparam integer hsync_c   =    1310   ;    //360 + 1280 =    1640 
localparam integer hsync_d   =    1320   ;    //1640 + 48 = 1688

localparam integer vsync_o   =     3     ;      
localparam integer vsync_p   =     20    ;  //3 + 38 = 41    
localparam integer vsync_q   =     1044  ;  //41 + 1024 = 1065
localparam integer vsync_r   =     1045  ;  //1065 + 1 = 1066




reg    [10 : 0]    hsync_cnt      ;
reg    [10 : 0]    vsync_cnt      ;  
assign   space       =      'd0          ;

assign   rd_en   =   dvalue && ~empty ;
assign   wr_en   =   pixel_en_1  && ~prog_full_1  ; 

assign   TREADY      =   ~prog_full_1     ;

wire   [10 : 0]   wr_water_level  ;
assign   prog_full  = (wr_water_level   >=  'd2000) ;



always @(posedge bin_clk  or negedge ARESETn ) begin
    if ( !ARESETn ) 
        hsync_cnt <= 'd0  ;
    else if ( !empty ) begin
        if ( hsync_cnt  >=  hsync_d - 'd1 )
            hsync_cnt   <=  'd0  ;
        else  
            hsync_cnt <= hsync_cnt + 'd1  ;
    end
    else
        hsync_cnt  <=  hsync_cnt  ;
end

always @(posedge bin_clk  or negedge ARESETn ) begin
    if ( !ARESETn ) 
        vsync_cnt <= 'd0  ;
    else if ( !empty ) begin
        if ( (vsync_cnt  >=  vsync_r - 'd1) && (hsync_cnt ==  hsync_d - 1'd1) )
            vsync_cnt   <=  'd0  ;
        else if ( hsync_cnt ==  hsync_d - 1'd1) 
            vsync_cnt <= vsync_cnt + 'd1  ;
        else 
            vsync_cnt  <=  vsync_cnt  ;
    end
    else
        vsync_cnt  <=  vsync_cnt  ;
end


always @( * ) begin
    if ( vsync_cnt <= vsync_o - 1'd1 )
        vsync  = 'd0  ;
    else if ( vsync_cnt <= vsync_r - 1'd1 )
        vsync  =  'd1  ;
    else 
        vsync  =  'd0  ;
end
  
always @( * ) begin
    if ( hsync_cnt <= hsync_a - 'd1)
        hsync  = 'd0  ;
    else if ( hsync_cnt <= hsync_d - 1'd1 )
        hsync  =  'd1  ;
    else 
        hsync  =  'd0  ;
end

always @( * ) begin
     if ( vsync_cnt >= vsync_o && vsync_cnt <= vsync_q - 'd1 ) begin
         if  ( hsync_cnt >= hsync_b && hsync_cnt <= hsync_c - 'd1 )
              dvalue  =  'd1  ;
         else
              dvalue  = 'd0 ;
     end
     else
        dvalue   =  'd0  ;    
 end


fifo_1 u_fifo (
  .wr_data(tdata_1),              // input [23:0]
  .wr_en(pixel_en_1),                  // input
  .wr_clk(ACLK),                // input
  .full(full),                    // output
  .wr_rst(!ARESETn),                // input
  .almost_full(almost_full),      // output
  .wr_water_level(wr_water_level),    // output [10:0]
  .rd_data(fifo_data_o),              // output [23:0]
  .rd_en(rd_en),                  // input
  .rd_clk(bin_clk),                // input
  .empty(empty),                  // output
  .rd_rst(!ARESETn),                // input
  .almost_empty(almost_empty)     // output
);




pll u_clk (
  .clkin1(ACLK),        // input
  .pll_lock(),    // output
  .clkout0(bin_clk),      // output 40
  .clkout1(process_clk)       // output
);


GTP_OUTBUFDS#(
 .IOSTANDARD ("LVDS")
)
u_tx1 (
.I (tx1),
.OB(TX_1_N ),
.O (TX_1_P) 
);


GTP_OUTBUFDS#(
 .IOSTANDARD ("LVDS")
)
u_tx2 (
.I (tx2),
.OB(TX_2_N ),
.O (TX_2_P) 
);

GTP_OUTBUFDS#(
 .IOSTANDARD ("LVDS")
)
u_tx3 (
.I (tx3),
.OB(TX_3_N ),
.O (TX_3_P) 
);

GTP_OUTBUFDS#(
 .IOSTANDARD ("LVDS")
)
u_tx4 (
.I (tx4),
.OB(TX_4_N ),
.O (TX_4_P) 
);

GTP_OUTBUFDS#(
 .IOSTANDARD ("LVDS")
)
u_xclk (
.I (cml_clk),
.OB(XCLK_N ),
.O (XCLK_P) 
);

endmodule