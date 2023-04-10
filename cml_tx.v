`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/28 10:22:34
// Design Name: zhufu
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


module  cml_tx#(
    parameter  integer   ROW   = 1024 ,
    parameter  integer   COL   = 1280 ,
	parameter  integer   PIXEL_WIDTH = 24   
)
(
  input   wire                  clk_div     ,
  input   wire                  clk_user       ,   
  input   wire                  rst_n       ,

  input   wire   [23 : 0]       din         ,
  input   wire                  din_val     ,          
  output  wire                  din_rd      ,

  output  wire                  clkout_p    ,
  output  wire                  clkout_n    ,
  output  wire   [3 : 0]        dout_p      ,
  output  wire   [3 : 0]        dout_n         
);

reg    [23 : 0]    din_pipe        ;
reg                din_val_pipe    ;
reg                rst_n_1         ;
wire               vsync_1         ;
wire               hsync_1         ;
wire               dvalue_1        ;
reg                rd_en_1         ;
reg    [23 : 0]    fifo_data_o_1   ;
wire               bin_clk       ;
wire               pixel_en      ; 
wire   [7 : 0]     porta         ;
wire   [7 : 0]     portb         ;
wire   [7 : 0]     portc         ; 
wire   [6 : 0]     shift_tx  [0 : 3]    ;
wire               space         ;
wire               cml_data_val  ;

assign   pixel_en    =   din_val_pipe         ;
assign   porta       =   fifo_data_o_1[7  : 0 ]       ;
assign   portb       =   fifo_data_o_1[15 : 8 ]       ;
assign   portc       =   fifo_data_o_1[23 : 16]       ;

assign   shift_tx [0]   = {porta[0] , porta[1] ,porta[2] ,porta[3] ,porta[4] ,  porta[5]  ,portb[0]} ;
assign   shift_tx [1]   = {portb[1] , portb[2] , portb[3] , portb[4] , portb[5] , portc[0] , portc[1]} ;
assign   shift_tx [2]   = {portc[2] , portc[3] , portc[4] , portc[5] , hsync_1 , vsync_1 , dvalue_1} ;
assign   shift_tx [3]   = {porta[6] , porta[7] , portb[6] , portb[7] , portc[6] , portc[7] , space } ;

assign   space       =      'd0          ;
assign   din_rd      =   'd0    ;
/*输入计数*/

wire                      tx_clk    ; // TODO
wire [3:0]                dout_o    ;
wire                      clkout_o  ;    

reg  [COL - 1 : 0]  col_cnt_i  ;
reg  [ROW - 1 : 0]  row_cnt_i  ;
reg  [COL - 1 : 0]  col_cnt_o  ;
reg  [ROW - 1 : 0]  row_cnt_o  ; 

always @(posedge clk_user or negedge rst_n) begin
    if ( !rst_n ) begin
        row_cnt_i  <=  'd0  ;
        col_cnt_i  <=  'd0  ;
    end 
    else if ( pixel_en ) begin
        if ( row_cnt_i == ROW - 1 && col_cnt_i == COL - 1) begin
            col_cnt_i  <=  'd0  ;
            row_cnt_i  <=  'd0  ;
        end
        else begin
            if ( col_cnt_i == COL - 1 ) begin
                col_cnt_i  <=  'd0   ;
                row_cnt_i  <=  row_cnt_i + 1  ;
            end 
            else begin
                col_cnt_i  <=  col_cnt_i + 1  ;
            end
        end
    end
    else begin
            col_cnt_i  <=  col_cnt_i  ;
            row_cnt_i  <=  row_cnt_i  ;        
    end
end
 
/*打拍*/
always @(posedge clk_user or negedge rst_n) begin
    if(!rst_n) begin
        din_pipe      <=  'd0           ;
        din_val_pipe  <=  'd0  ;
    end
    else begin
        din_pipe      <=  din         ;     //给数据做是时钟同步处理，在上升沿采样数据   
        din_val_pipe  <=  din_val  ;  
    end 
end

always @(posedge bin_clk or negedge rst_n) begin
    if(!rst_n) begin
        rst_n_1    <=  'd0           ; 
        rd_en_1     <=      'd0         ;      
    end
    else begin   
        rst_n_1    <=  rst_n       ;
    end 
end

localparam integer TIME_10S   =    500_000_000    ; 

reg  [28 : 0]  time_cnt  ; 

always @(posedge clk_div or negedge rst_n ) begin
    if ( !rst_n )  begin
        time_cnt   <=  'd0  ;
    end
    else begin
        if ( time_cnt == TIME_10S - 1 ) 
            time_cnt  <=  time_cnt   ;
        else
            time_cnt  <=  time_cnt + 'd1  ; 
    end
end

/***************fifo stage*******************/

reg     state  ;

parameter  WAIT  =  1'b0  ;
parameter  ENABLE  =  1'b1  ;

genvar gen_i  ;
generate
    for (gen_i = 0 ; gen_i < 2 ; gen_i = gen_i + 'd1) begin : BLOCK1
        
        wire  [PIXEL_WIDTH - 1 : 0]  fifo_din  ;
        wire                         wr_en  ;
        wire                         rd_en  ;
        wire  [PIXEL_WIDTH - 1 : 0]  fifo_dout  ;
        wire                         prog_full  ;
        wire                         empty     ;
        reg                          rd_flag  ;

        reg   [PIXEL_WIDTH - 1 : 0]  fifo_dout_pipe  ;
        reg                          rd_en_pipe  ;
        reg                          empty_pipe  ;
    
        wire   [11 : 0]    wr_water_level ;

        assign  wr_en  =  row_cnt_i[0] == gen_i ? (pixel_en ? 'd1 : 'd0) : 'd0  ;
        assign  fifo_din  =  row_cnt_i[0] == gen_i ? din_pipe : 'd0  ;
        assign  rd_en  =  rd_flag && !empty  ;
        assign  prog_full  =   ( wr_water_level  >=  'd1279 ) ? 'd1  :  'd0  ;

        always @( posedge bin_clk or negedge rst_n) begin
            if ( !rst_n ) begin
                fifo_dout_pipe  <=  'd0  ;
                rd_en_pipe  <=  'd0  ;
                empty_pipe  <=  'd0  ;
            end
            else begin  
                fifo_dout_pipe  <=  fifo_dout  ;
                rd_en_pipe  <=  rd_en  ;
                empty_pipe  <=  empty  ;
            end
        end

        always @( posedge bin_clk or negedge rst_n) begin
            if ( !rst_n ) begin
                rd_flag  <=  'd0  ;
            end
            else begin  
                if ( prog_full )
                    rd_flag  <= 'd1  ;
                else if ( empty )
                    rd_flag  <=  'd0  ;
                else 
                    rd_flag  <=  rd_flag  ;
            end
        end

        GTP_GRS GRS_INST(
            .GRS_N(1'b1)
            ) ;
        
        fifo_drm_async_fwft #(
           .WR_DEPTH_WIDTH   (11  ) ,
           .WR_DATA_WIDTH    (24  ) ,
           .RD_DEPTH_WIDTH   (11 ) ,
           .RD_DATA_WIDTH    (24  ) ,
           .ALMOST_FULL_NUM  (1280 ) ,
           .ALMOST_EMPTY_NUM (4  ) ,
           .RESET_TYPE       ("ASYNC")  // @IPC enum Sync_Internally,SYNC,ASYNC
        )u_fifo
        (
           .wr_clk          ( clk_user ),
           .wr_rst          ( !rst_n_1 ),
           .wr_en           ( wr_en ),
           .wr_data         ( fifo_din ),
           .wr_full         ( full ), 
           .wr_water_level  ( wr_water_level ),
           .rd_clk          ( bin_clk ),
           .rd_rst          ( !rst_n_1 ),
           .rd_en           ( rd_en ),
           .rd_data         ( fifo_dout ),
           .almost_full     (  ),
           .rd_empty        ( empty ),
           .almost_empty    (  )
        ); 

    end
endgenerate


assign  cml_data_val  =  (BLOCK1[0].rd_en_pipe ) || (BLOCK1[1].rd_en_pipe )  ;
assign  vsync_1   =  state  ; //state
// assign  hsync_1   =  (time_cnt == TIME_10S - 1) ? 'd0 : cml_data_val ;
assign  hsync_1   =  cml_data_val ;
assign  dvalue_1  =  cml_data_val  ;

always @(posedge bin_clk or negedge rst_n) begin
    if ( !rst_n ) begin
        state  <=  'd0  ;
    end
    else begin
       case (state)
        WAIT    :  begin
            if ( BLOCK1[0].wr_en )
                state  <=  ENABLE  ;
            else  
                state  <=  state  ;
        end
        ENABLE  :  begin
            if ( row_cnt_o == ROW - 1 && col_cnt_o == COL - 1  )
               state  <=  WAIT  ;
            else  
               state  <=  state  ;
        end
        default: state  <=  WAIT  ;
       endcase
    end
end

always @( * ) begin
    if ( BLOCK1[0].rd_en_pipe )
        fifo_data_o_1  =  BLOCK1[0].fifo_dout_pipe  ;
    else if ( BLOCK1[1].rd_en_pipe )
        fifo_data_o_1  =  BLOCK1[1].fifo_dout_pipe  ;
    else 
        fifo_data_o_1  =  'd0  ;
end

always @(posedge bin_clk or negedge rst_n) begin
    if ( !rst_n ) begin
        row_cnt_o  <=  'd0  ;
        col_cnt_o  <=  'd0  ;
    end 
    else if ( cml_data_val ) begin
        if ( row_cnt_o == ROW - 1 && col_cnt_o == COL - 1) begin
            col_cnt_o  <=  'd0  ;
            row_cnt_o  <=  'd0  ;
        end
        else begin
            if ( col_cnt_o == COL - 1 ) begin
                col_cnt_o  <=  'd0   ;
                row_cnt_o  <=  row_cnt_o + 1  ;
            end 
            else begin
                col_cnt_o  <=  col_cnt_o + 1  ;
            end
        end
    end
    else begin
            col_cnt_o  <=  col_cnt_o  ;
            row_cnt_o  <=  row_cnt_o  ;        
    end
end

/********************************************/

pll u_clk (
  .clkin1(clk_div),        // input
  .pll_lock(),    // output
  .clkout0(tx_clk)     // output 175
);


GTP_GRS GRS_INST(
    .GRS_N(1'b1)
    ) ;

GTP_IOCLKDIV #(
    .GRS_EN     ("TRUE"),
    .DIV_FACTOR ("3.5")
) u_GTP_CLKDIV_0(
    .CLKIN      (tx_clk   ),
    .RST_N      (rst_n      ),
    .CLKDIVOUT  (bin_clk     )
);

genvar i;
generate
for (i=0; i<4; i=i+1) begin : dout
    GTP_OSERDES #(
        .OSERDES_MODE ("OSER7"  ),
        .WL_EXTEND    ("FALSE"  ),
        .GRS_EN       ("TRUE"   ),
        .LRS_EN       ("TRUE"   ),
        .TSDDR_INIT   (1'b0     )
    ) u_GTP_OSERDES_0
    (
        .DI     (shift_tx[i] ),
        .TI     (4'h0            ),
        .RCLK   (bin_clk          ),
        .SERCLK (tx_clk        ),
        .OCLK   (1'b0            ),
        .RST    (~rst_n          ),
        .TQ     (                ),
        .DO     (dout_o[i]       )
    );

    GTP_OUTBUFDS #(
        .IOSTANDARD ("DEFAULT")
    ) u_GTP_OUTBUFDS_0
    (
        .O  (dout_p[i]     ),
        .OB (dout_n[i]     ),
        .I  (dout_o[i]     )
    );
end
endgenerate

GTP_OSERDES #(
    .OSERDES_MODE ("OSER7"  ),
    .WL_EXTEND    ("FALSE"  ),
    .GRS_EN       ("TRUE"   ),
    .LRS_EN       ("TRUE"   ),
    .TSDDR_INIT   (1'b0     )
 ) u_GTP_OSERDES_1
 (
   .DI     (7'b1100011   ),
   .TI     (4'h0         ),
   .RCLK   (bin_clk       ),
   .SERCLK (tx_clk     ),
   .OCLK   (1'b0         ),
   .RST    (~rst_n       ),
   .TQ     (             ),
   .DO     (clkout_o     )
);

GTP_OUTBUFDS #(
    .IOSTANDARD ("DEFAULT")
) u_GTP_OUTBUFDS_1
(
    .O (clkout_p),
    .OB(clkout_n),
    .I (clkout_o)
);


endmodule
