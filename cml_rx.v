`timescale 1ps/1ps
module cml_rx #(
	// Parameters
	parameter integer	CAMERALINK_MODE = 2,	// Set the CameraLink mode. Base-->1  Medium-->2  Full-->3
	parameter integer	CAMERALINK_CHAL = 4		// Set the number of data lines per channel=4
)
(
	input				                            delay_clk_200m,	    // Clock for input delay control: 200MHz or 300Hz clk is needed
	input				                            reset_n       ,		// Active low reset

	input	[CAMERALINK_MODE-1:0]		            i_clk_in_p    ,		// Input from LVDS clock receiver pin
	input	[CAMERALINK_MODE-1:0]		            i_clk_in_n    ,		// Input from LVDS clock receiver pin
	input	[CAMERALINK_MODE*CAMERALINK_CHAL-1:0]	i_data_in_p   ,		// Input from LVDS data pins
	input	[CAMERALINK_MODE*CAMERALINK_CHAL-1:0]	i_data_in_n   ,		// Input from LVDS data pins
//decode video_clk and video_data output
	output				                            o_pixel_clk   ,		// Pixel clock output
	// Chip X signals
	output			                                o_xLVAL       ,		// Line Valid, active high
	output			                                o_xFVAL       ,		// Frame Valid, active high
	output			                                o_xDVAL       ,		// Data Valid, active high. Maybe always zero.
	output	[7:0]	                                o_PortA       ,		// Camera Link interface Port A , total 8 ports
	output	[7:0]	                                o_PortB       ,		// Camera Link interface Port B , total 8 ports
	output	[7:0]	                                o_PortC       ,		// Camera Link interface Port C , total 8 ports
	// Chip Y signals
	output			                                o_yLVAL       ,		// Line Valid, active high
	output			                                o_yFVAL       ,		// Frame Valid, active high
	output			                                o_yDVAL       ,		// Data Valid, active high. Maybe always zero.
	output	[7:0]	                                o_PortD       ,		// Camera Link interface Port D , total 8 ports
	output	[7:0]	                                o_PortE       ,		// Camera Link interface Port E , total 8 ports
	output	[7:0]	                                o_PortF       ,		// Camera Link interface Port F , total 8 ports
	// Chip Z signals
	output			                                o_zLVAL       ,		// Line Valid, active high
	output			                                o_zFVAL       ,		// Frame Valid, active high
	output			                                o_zDVAL       ,		// Data Valid, active high. Maybe always zero.
	output	 [7:0]	                                o_PortG       ,		// Camera Link interface Port G , total 8 ports
	output	 [7:0]	                                o_PortH       		// Camera Link interface Port H , total 8 ports	
);
 
wire [CAMERALINK_MODE*CAMERALINK_CHAL*7-1:0]	data_out;			// Serial to parallel data output
//**********差分转单端,然后串并转换,由Xilinx IDELAYE2 和 ISERDESE2 原语实现**********//
lvds_n_x_1to7_sdr_rx #(
	// Parameters
	.CAMERALINK_MODE (CAMERALINK_MODE),				// Set the number of channels
	.CAMERALINK_CHAL (CAMERALINK_CHAL)				// Set the number of data lines per channel
)
CameraLink_sdr(
	.delay_refclk_in(delay_clk_200m),	// Clock for input delay control: 200MHz or 300Hz clk is needed
	.reset_n        (reset_n       ),	// Active low reset
	.clk_in_p       (i_clk_in_p    ),	// Input from LVDS clock receiver pin
	.clk_in_n       (i_clk_in_n    ),	// Input from LVDS clock receiver pin
	.data_in_p      (i_data_in_p   ),	// Input from LVDS data pins
	.data_in_n      (i_data_in_n   ),	// Input from LVDS data pins
	.data_out       (data_out      ),	// Serial to parallel data output
	.pixel_clk      (o_pixel_clk   )	// Pixel clock output
);
//**********差分转单端,然后串并转换,由Xilinx IDELAYE2 和 ISERDESE2 原语实现**********//


//*****************根据CameraLink的数据格式，解码出行、场、de、数据*****************//
// cameralink_bit_allocation_rx #(
// 	// Parameters
// 	.N (CAMERALINK_MODE),				// Set the number of channels
// 	.X (CAMERALINK_CHAL)				// Set the number of data lines per channel
// )
// CameraLink_decode(
// 	.data_in             (data_out),		// Parallel data input
// 	// Chip X signals
// 	.xLVAL  (o_xLVAL),		// Line Valid, active high
// 	.xFVAL  (o_xFVAL),		// Frame Valid, active high
// 	.xDVAL  (o_xDVAL),		// Data Valid, active high. Maybe always zero.
// 	.PortA  (o_PortA),		// Camera Link interface Port A , total 8 ports
// 	.PortB  (o_PortB),		// Camera Link interface Port B , total 8 ports
// 	.PortC  (o_PortC),		// Camera Link interface Port C , total 8 ports
// 	// Chip Y signals
// 	.yLVAL  (o_yLVAL),		// Line Valid, active high
// 	.yFVAL  (o_yFVAL),		// Frame Valid, active high
// 	.yDVAL  (o_yDVAL),		// Data Valid, active high. Maybe always zero.
// 	.PortD  (o_PortD),		// Camera Link interface Port D , total 8 ports
// 	.PortE  (o_PortE),		// Camera Link interface Port E , total 8 ports
// 	.PortF  (o_PortF),		// Camera Link interface Port F , total 8 ports
// 	// Chip Z signals
// 	.zLVAL  (o_zLVAL),		// Line Valid, active high
// 	.zFVAL  (o_zFVAL),		// Frame Valid, active high
// 	.zDVAL  (o_zDVAL),		// Data Valid, active high. Maybe always zero.
// 	.PortG  (o_PortG),		// Camera Link interface Port G , total 8 ports
// 	.PortH  (o_PortH)		// Camera Link interface Port H , total 8 ports
// );
//*****************根据CameraLink的数据格式，解码出行、场、de、数据*****************//
//解码后的时许如下：

//              __    __    __    __    __    __    __    __    __    __    __    __    __    __    __
//o_pixel_clk__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \ 
//                 ____________________________________________________________________________________
//o_xFVAL_________/
//                         _______________________                   _______________________
//o_xLVAL_________________/                       \_________________/                       \__________
//                         _______________________                   _______________________
//o_xDVAL_________________/                       \_________________/                       \__________
//       _________________ _______________________ _________________ _______________________                
//o_PortA___invalid_data__\_______valid_data______\___invalid_data__\_______valid_data______\_invalid_data_
//       _________________ _______________________ _________________ _______________________               
//o_PortB___invalid_data__\_______valid_data______\___invalid_data__\_______valid_data______\_invalid_data_
//       _________________ _______________________ _________________ _______________________               
//o_PortC___invalid_data__\_______valid_data______\___invalid_data__\_______valid_data______\_invalid_data_

endmodule
