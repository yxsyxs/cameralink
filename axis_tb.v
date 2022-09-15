`timescale 1 ns/ 1 ps
module cameralink_tb;
    
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


//assign video_out_tvalid = (data_cnt <= COLUMN * LINE - 'd1 && reset_n) ? 1'b1 : 1'b0;
//assign video_out_tdata  = DDE_date[COLUMN * LINE * PIXEL_RESOLUTION - 1 -: PIXEL_RESOLUTION];
//assign   video_out_tvalid  =   ((data_cnt <=10000 || data_cnt >= 11000) &&  row_cnt_o <= 383  )  ? 1'b1 : 1'b0  ; 
// assign   video_out_tvalid  =  'd1  ; 
// assign video_out_tdata  = ( data_en == 1 ) ?  DDE_date[COLUMN * LINE * PIXEL_RESOLUTION - 1 - data_cnt * PIXEL_RESOLUTION -: PIXEL_RESOLUTION] : 8'd0 ;
// assign data_en   =   video_out_tvalid && video_in_tready ;
// assign  video_line_last  =  ( col_cnt_o == COLUMN - 1'd1)  ?  'd1  :  'd0   ; 

 initial
 begin
     reset_n = 1'b0;
     #7
     video_clk = 1'b0;
     cml_clk   =  1'd0  ;
     #1000;
     reset_n = 1'b1;
     video_out_first = 'd0 ;
 end

 //always #20 video_clk =( clk_div == 1) ? ~video_clk : video_clk     ;   //25M
 always #10 video_clk = ~video_clk ; 


//  always @(posedge video_clk)
//  begin
//      if (!reset_n)
//      begin
//          data_cnt <= 17'b0;
//      //    video_out_tdata <= 'd0  ;
//      end
//      else if  ( data_en )
//      begin
//          if (data_cnt >= COLUMN * LINE - 1'd1 )
//              data_cnt <= 17'b0;
//          else
//              data_cnt <= data_cnt + 17'b1;        
//      end
//      else
//         data_cnt  <=  data_cnt  ;
//  end

//  always @(posedge video_clk)
//  begin
//     if (!reset_n) begin
//         row_cnt_o  <=  'd0  ;
//         col_cnt_o  <=  'd0  ; 
//     end 
//     else if (data_en) begin
//         if ((row_cnt_o >= LINE - 1'd1) && (col_cnt_o >= COLUMN - 1'd1))  begin
//             row_cnt_o   <=  'd0  ;
//             col_cnt_o   <=  'd0  ;
//         end
//         else  begin
//             if (col_cnt_o >= COLUMN - 1'd1 ) begin
//                 col_cnt_o  <=  'd0 ;
//                 row_cnt_o  <=  row_cnt_o + 1'd1  ;
//             end
//             else begin
//                 col_cnt_o  <=  col_cnt_o + 1'd1  ;
//                 row_cnt_o  <=  row_cnt_o    ;   
//             end    
//         end
//     end
//     else begin
//         if ( row_cnt_o == LINE && col_cnt_o == COLUMN ) begin
//             row_cnt_o  <=  'd0  ;
//             col_cnt_o  <=  'd0  ;
//         end
//         else begin
//             row_cnt_o  <=  row_cnt_o  ;
//             col_cnt_o  <=  col_cnt_o  ;
//         end
//     end
//  end

//GTP_GRS GRS_INST
//(
//.GRS_N(1'b1)
//);

 cameralink cameralink_tb(
  .ACLK         (  video_clk         )    ,
  .ARESETn      (  reset_n           )    
//   .TVALID       (  video_out_tvalid  )    ,
//   .TREADY       (  video_in_tready   )    ,
//   .TDATA        (  video_out_tdata   )    ,
//   .TLAST        (  video_line_last  )    ,
//   .TUSER        (  video_out_first  )      
);
                                              
endmodule