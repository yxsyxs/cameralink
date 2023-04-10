`timescale 1 ns/ 1 ps
module cml_tb;
    
 //`include "DDE_date.vh"
    
reg            reset_n;
reg            video_clk;
reg            process_clk ;
reg            cml_clk     ;
wire            video_out_tvalid;    
wire  [23:0]     video_out_tdata;                                         
wire             video_line_last  ;
reg            video_out_first   ;

wire           video_in_tready;
reg  [20 : 0]  data_cnt;
wire           data_en   ;
reg  [10 : 0]  row_cnt_o   ;
reg  [10 : 0]  col_cnt_o   ;

 initial
 begin
     reset_n = 1'b0;
     #7
     video_clk = 1'b0;
     cml_clk   =  1'd0  ;
     #10000;
     reset_n = 1'b1;
     video_out_first = 'd0 ;
 end
 //always #20 video_clk =( clk_div == 1) ? ~video_clk : video_clk     ;   //25M
always #10 video_clk = ~video_clk ; 

cml_top #(
  .ROW          (1024) ,
  .COL          (1280) ,
	.PIXEL_WIDTH  (8   ) 
) u_cml_top
(
    .clk_50M    ( video_clk )  ,

    .clkout_p   (  )  ,
    .clkout_n   (  )  ,
    .dout_p     (  )  ,
    .dout_n     (  )  
);
                                              
endmodule