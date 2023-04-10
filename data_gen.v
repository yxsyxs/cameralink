module data_gen #(
    parameter  COL  =  256  ,
    parameter  ROW  =  256  ,
    parameter  PIXEL_WIDTH  =  8 
)(
           input  wire aresetn,
           input  wire clk,
           input  wire video_clk  ,

           output wire axis_tvalid,
           input  wire axis_tready,
           output wire axis_tlast,
           output wire [15 : 0] axis_tkeep,
           output reg  [127 : 0]axis_tdata
       );

function integer clogb2 (input integer bit_depth);   
begin
   for (clogb2 = 0; bit_depth > 0; clogb2 = clogb2 + 1)
     bit_depth = bit_depth >> 1;
end
endfunction

localparam integer  COL_WIDTH  =  clogb2(COL)  ;
localparam integer  ROW_WIDTH  =  clogb2(ROW)  ;

/****************video_in********************/

reg  [PIXEL_WIDTH - 1 : 0]  pixel  ;
reg                         dvalue  ;
wire                        dready  ;  //可以街道上级 当坐输入的ready信号，用来反压上一级

localparam integer hsync_a   =    10    ;      
localparam integer hsync_b   =    hsync_a + 20    ;    //112 + 248 = 360
localparam integer hsync_c   =    hsync_b + COL   ;    //360 + 1280 =    1640 
localparam integer hsync_d   =    hsync_c + 10   ;    //1640 + 48 = 1688

localparam integer vsync_o   =     1     ;      
localparam integer vsync_p   =     vsync_o + 1    ;  //3 + 38 = 41    
localparam integer vsync_q   =     vsync_p + ROW  ;  //41 + 1024 = 1065
localparam integer vsync_r   =     vsync_q + 1  ;  //1065 + 1 = 1066

reg    [COL_WIDTH - 1 : 0]    hsync_cnt      ;
reg    [COL_WIDTH - 1 : 0]    vsync_cnt      ; 
reg    [7 : 0]                frame_cnt      ;
reg                           hsync  ;
reg                           vsync  ;

always @(posedge video_clk or negedge aresetn ) begin
    if ( !aresetn ) 
        hsync_cnt <= 'd0  ;
    else if ( dready ) begin
        if ( hsync_cnt  >=  hsync_d - 'd1 )
            hsync_cnt   <=  'd0  ;
        else  
            hsync_cnt <= hsync_cnt + 'd1  ;
    end
    else  
        hsync_cnt <= hsync_cnt + 'd1  ;
end

always @(posedge video_clk or negedge aresetn ) begin
    if ( !aresetn ) 
        vsync_cnt <= 'd0  ;
    else begin
        if ( (vsync_cnt  >=  vsync_r - 'd1) && (hsync_cnt ==  hsync_d - 1'd1) )
            vsync_cnt   <=  'd0  ;
        else if ( (hsync_cnt ==  hsync_d - 1'd1)) 
            vsync_cnt <= vsync_cnt + 'd1  ;
        else 
            vsync_cnt  <=  vsync_cnt  ;
    end
    // else 
    //     vsync_cnt  <=  vsync_cnt  ;
end

always @(posedge video_clk or negedge aresetn ) begin
    if ( !aresetn ) 
        frame_cnt <= 'd0  ;
    else begin
        if ( (vsync_cnt  >=  vsync_r - 'd1) && (hsync_cnt ==  hsync_d - 1'd1) )
            frame_cnt   <=  frame_cnt + 'd1  ;
        else  
            frame_cnt <= frame_cnt  ;
    end
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
        if  ( hsync_cnt >= hsync_b && hsync_cnt <= hsync_c - 'd1 ) begin
            dvalue  =  'd1  ;
            // pixel  =  pixel + 'd1  ; //可能是这里有问题
        end             
        else begin
            dvalue  = 'd0 ;
            // pixel  =  frame_cnt  ;
        end
    end
    else begin
        dvalue   =  'd0  ;
        // pixel  =  'd0  ;
    end
end

always @(posedge video_clk or negedge aresetn ) begin
    if ( !aresetn ) 
        pixel <= 'd0  ;
    else if (  vsync_cnt >= vsync_o && vsync_cnt <= vsync_q - 'd1  ) begin
        if ( hsync_cnt >= hsync_b && hsync_cnt <= hsync_c - 'd1 ) 
            pixel  <=  pixel + 'd1  ; //可能是这里有问题             
        else 
            pixel  <=  frame_cnt  ;
    end
    else 
        pixel  <=  'd0  ;
end

/*********************************************/
reg  [COL_WIDTH - 1 : 0]  col_cnt_i  ;
reg  [ROW_WIDTH - 1 : 0]  row_cnt_i  ;
reg  [COL_WIDTH - 1 : 0]  col_cnt_o  ;
reg  [ROW_WIDTH - 1 : 0]  row_cnt_o  ;
reg  [7 : 0]   tlast_cnt ;

assign axis_tkeep = 16'hFFFF;

always @(posedge video_clk or negedge aresetn) begin
    if ( !aresetn ) begin
        row_cnt_i  <=  'd0  ;
        col_cnt_i  <=  'd0  ;
    end 
    else if ( dvalue ) begin
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

        wire  [11 : 0]               wr_water_level  ;

        assign  wr_en  =  row_cnt_i[0] == gen_i ? (dvalue ? 'd1 : 'd0) : 'd0  ;
        assign  fifo_din  =  row_cnt_i[0] == gen_i ? pixel : 'd0  ;
        assign  rd_en  =  rd_flag && axis_tready  ;
        assign  prog_full  =  ( wr_water_level  >=  'd1279  ) ? 'd1  :  'd0   ;

        always @( posedge clk or negedge aresetn) begin
            if ( !aresetn ) begin
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

        always @( posedge clk or negedge aresetn) begin
            if ( !aresetn ) begin
                rd_flag  <=  'd0  ;
            end
            else begin  
                if (gen_i == 0) begin
                    if ( prog_full && (BLOCK1[1].rd_en == 0) )
                        rd_flag  <= 'd1  ;
                    else if ( empty )
                        rd_flag  <=  'd0  ;
                    else 
                        rd_flag  <=  rd_flag  ;                    
                end
                else begin 
                    if ( prog_full && (BLOCK1[0].rd_en == 0) )
                        rd_flag  <= 'd1  ;
                    else if ( empty )
                        rd_flag  <=  'd0  ;
                    else 
                        rd_flag  <=  rd_flag  ;  
                end
            end
        end

        GTP_GRS GRS_INST(
           .GRS_N(1'b1)
        ) ;
        fifo_drm_async_fwft #(
           .WR_DEPTH_WIDTH   (11  ) ,
           .WR_DATA_WIDTH    (8  ) ,
           .RD_DEPTH_WIDTH   (11 ) ,
           .RD_DATA_WIDTH    (8  ) ,
           .ALMOST_FULL_NUM  (1279) ,
           .ALMOST_EMPTY_NUM (4  ) ,
           .RESET_TYPE       ("ASYNC")  // @IPC enum Sync_Internally,SYNC,ASYNC
       )fifo_u
       (
           .wr_clk          ( video_clk ),
           .wr_rst          ( !aresetn ),
           .wr_en           ( wr_en ),
           .wr_data         ( fifo_din ),
           .wr_full         (  ), 
           .wr_water_level  ( wr_water_level ),
           .rd_clk          ( clk ),
           .rd_rst          ( !aresetn ),
           .rd_en           ( rd_en ),
           .rd_data         ( fifo_dout ),
           .almost_full     (  ),
           .rd_empty        ( empty ),
           .almost_empty    (  )
       ); 

    end
endgenerate
        //    output wire axis_tlast,

always @(posedge clk or negedge aresetn) begin
    if ( !aresetn ) begin
        row_cnt_o  <=  'd0  ;
        col_cnt_o  <=  'd0  ;
    end 
    else if ( axis_tvalid && axis_tready ) begin
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


assign  axis_tvalid  =  (BLOCK1[0].rd_flag && ~BLOCK1[0].empty ) || (BLOCK1[1].rd_flag && ~BLOCK1[1].empty )  ;
assign  axis_tlast  =  col_cnt_o == COL - 1  ;
assign  dready  =  (BLOCK1[0].empty ) || (BLOCK1[1].empty )  ;

always @( * ) begin
    if ( BLOCK1[0].rd_flag )
        axis_tdata  =  BLOCK1[0].fifo_dout  ;
    else if ( BLOCK1[1].rd_flag )
        axis_tdata  =  BLOCK1[1].fifo_dout  ;
    else 
        axis_tdata  =  'd0  ;
end

endmodule
