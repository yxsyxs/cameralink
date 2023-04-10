module fifo_drm_async_fwft #(
           parameter  integer WR_DEPTH_WIDTH = 9,
           parameter  integer WR_DATA_WIDTH = 8,
           parameter  integer RD_DEPTH_WIDTH = 9,
           parameter  integer RD_DATA_WIDTH = 8,
           parameter  integer ALMOST_FULL_NUM = 255,
           parameter  integer ALMOST_EMPTY_NUM = 4,
           parameter  RESET_TYPE = "ASYNC"  // @IPC enum Sync_Internally,SYNC,ASYNC
       )
       (
           input  wire  wr_clk  ,
           input  wire  wr_rst  ,

           input  wire wr_en,
           input  wire [WR_DATA_WIDTH - 1 : 0]wr_data,
           output wire wr_full,
           output wire [WR_DEPTH_WIDTH : 0] wr_water_level  ,

           input  wire  rd_clk  ,
           input  wire  rd_rst  ,

           input  wire rd_en,
           output wire [RD_DATA_WIDTH - 1 : 0]rd_data,
           
           output wire almost_full,
           output wire  rd_empty,

           output wire almost_empty
       ); 



wire fifo_rd_en;
wire fifo_empty;
reg  dout_valid;

assign fifo_rd_en = !fifo_empty && (!dout_valid || rd_en);
assign rd_empty = !dout_valid;

always @(posedge rd_clk)
    if (rd_rst)
        dout_valid <= 0;
    else
    begin
        if (fifo_rd_en)
            dout_valid <= 1;
        else if (rd_en)
            dout_valid <= 0;
    end


// orig_fifo is just a normal non-FWFT synchronous or asynchronous FIFO
fifo #
    (
        .WR_DEPTH_WIDTH (WR_DEPTH_WIDTH),
        .WR_DATA_WIDTH (WR_DATA_WIDTH),
        .RD_DEPTH_WIDTH (RD_DEPTH_WIDTH),
        .RD_DATA_WIDTH (RD_DATA_WIDTH),
        .ALMOST_FULL_NUM (ALMOST_FULL_NUM),
        .ALMOST_EMPTY_NUM (ALMOST_EMPTY_NUM),
        .RESET_TYPE (RESET_TYPE)
    ) u_dde_drm_async_fifo
    (
        .wr_clk   ( wr_clk )       ,
        .wr_rst   ( wr_rst )       ,

        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_full(wr_full),
        .wr_water_level(wr_water_level) ,
        
        .rd_clk  ( rd_clk )  ,
        .rd_rst  ( rd_rst )  ,

        .rd_en(fifo_rd_en),
        .rd_data(rd_data),

        .almost_full(almost_full),
        .rd_empty(fifo_empty),

        .almost_empty(almost_empty)
    );

endmodule