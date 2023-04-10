`timescale 1 ns / 10 ps

module cml_top #(
    parameter  integer   ROW   = 1024 ,
    parameter  integer   COL   = 1280 ,
	parameter  integer   PIXEL_WIDTH = 8  
)
(
    input   wire  clk_50M,

    output  wire             clkout_p   ,
    output  wire             clkout_n   ,
    output  wire   [3 : 0]   dout_p     ,
    output  wire   [3 : 0]   dout_n     
);

wire  reset_n  ;
wire  hsst_user_clk  ;
wire  delay_clk_200m  ;

wire s_axi_tx_tvalid;
wire  s_axi_tx_tready  ;
wire s_axi_tx_tlast;
wire [15 : 0]s_axi_tx_tkeep;
wire [127 : 0]s_axi_tx_tdata;

assign  s_axi_tx_tready  =  'd1  ;


pll_1 u_clk_1 (
  .clkin1(clk_50M),        // input
  .pll_lock(reset_n),    // output
  .clkout0(hsst_user_clk),     // output 55m
  .clkout1(delay_clk_200m)
);

data_gen  #(
    .COL             (COL)  ,
    .ROW             (ROW ) ,
    .PIXEL_WIDTH     (PIXEL_WIDTH  ) 
)u_data_gen
(
    .aresetn(reset_n),
    .clk(hsst_user_clk),
    .video_clk ( clk_50M ) ,
    .axis_tvalid(s_axi_tx_tvalid),
    .axis_tready(s_axi_tx_tready),
    .axis_tlast(s_axi_tx_tlast),
    .axis_tkeep(s_axi_tx_tkeep),
    .axis_tdata(s_axi_tx_tdata)
);

cml_tx #(
    .ROW    (ROW) ,
    .COL    (COL) ,
	.PIXEL_WIDTH  (24  ) 
) u_cml_tx
(
  .clk_div   ( clk_50M )  ,
  .clk_user  ( hsst_user_clk )     ,  
  .rst_n     ( reset_n )  ,
  .din       ( s_axi_tx_tdata[23 : 0] )  ,
  .din_val   ( s_axi_tx_tvalid ) ,         
  .din_rd    (  )  ,
  .clkout_p  ( clkout_p )  ,
  .clkout_n  ( clkout_n )  ,
  .dout_p    ( dout_p )  ,
  .dout_n    ( dout_n )     
);

cml_rx #(
	// Parameters
	.CAMERALINK_MODE  (1),	// Set the CameraLink mode. Base-->1  Medium-->2  Full-->3
	.CAMERALINK_CHAL  (4)		// Set the number of data lines per channel=4
) u_cml_rx
(
	.delay_clk_200m    ( delay_clk_200m ),	    // Clock for input delay control: 200MHz or 300Hz clk is needed
	.reset_n           ( reset_n ),		// Active low rst_n

	.i_clk_in_p        ( clkout_p ),		// Input from LVDS clock receiver pin
	.i_clk_in_n        ( clkout_n ),		// Input from LVDS clock receiver pin
	.i_data_in_p       ( dout_p ),		// Input from LVDS data pins
	.i_data_in_n       ( dout_n ),		// Input from LVDS data pins
//decode video_clk and video_data output
	.o_pixel_clk       (  ),		// Pixel clock output
	// Chip X signals
	.o_xLVAL           (  ),		// Line Valid, active high
	.o_xFVAL           (  ),		// Frame Valid, active high
	.o_xDVAL           (  ),		// Data Valid, active high. Maybe always zero.
	.o_PortA           (  ),		// Camera Link interface Port A , total 8 ports
	.o_PortB           (  ),		// Camera Link interface Port B , total 8 ports
	.o_PortC           (  ),		// Camera Link interface Port C , total 8 ports
	// Chip Y signals
	.o_yLVAL           (  ),		// Line Valid, active high
	.o_yFVAL           (  ),		// Frame Valid, active high
	.o_yDVAL           (  ),		// Data Valid, active high. Maybe always zero.
	.o_PortD           (  ),		// Camera Link interface Port D , total 8 ports
	.o_PortE           (  ),		// Camera Link interface Port E , total 8 ports
	.o_PortF           (  ),		// Camera Link interface Port F , total 8 ports
	// Chip Z signals
	.o_zLVAL           (  ),		// Line Valid, active high
	.o_zFVAL           (  ),		// Frame Valid, active high
	.o_zDVAL           (  ),		// Data Valid, active high. Maybe always zero.
	.o_PortG           (  ),		// Camera Link interface Port G , total 8 ports
	.o_PortH           (  )		// Camera Link interface Port H , total 8 ports	
);

endmodule
