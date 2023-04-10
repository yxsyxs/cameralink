module lvds_n_x_1to7_sdr_rx #(
	// Parameters
	parameter integer	CAMERALINK_MODE = 2,	// Set the CameraLink mode. Base-->1  Medium-->2  Full-->3
	parameter integer	CAMERALINK_CHAL = 4		// Set the number of data lines per channel=4
)(
	input                                          delay_refclk_in,	// Clock for input delay control: 200MHz or 300Hz clk is needed
	input                                          reset_n        ,	// Active low reset
	input  [CAMERALINK_MODE-1:0]		           clk_in_p       ,	// Input from LVDS clock receiver pin
	input  [CAMERALINK_MODE-1:0]		           clk_in_n       ,	// Input from LVDS clock receiver pin
	input  [CAMERALINK_MODE*CAMERALINK_CHAL-1:0]   data_in_p      ,	// Input from LVDS data pins
	input  [CAMERALINK_MODE*CAMERALINK_CHAL-1:0]   data_in_n      ,	// Input from LVDS data pins
	output [CAMERALINK_MODE*CAMERALINK_CHAL*7-1:0] data_out       ,	// Serial to parallel data output
	output                                         pixel_clk      	// Pixel clock output
);

GTP_IOCLKDELAY #(
    .DELAY_STEP_VALUE('b00000000),
    .DELAY_STEP_SEL("PARAMETER"),
    .SIM_DEVICE("TITAN")
) <InstanceName> (
    .DELAY_STEP(),// INPUT[7:0]  
    .CLKOUT(),    // OUTPUT  
    .DELAY_OB(),  // OUTPUT  
    .CLKIN(),     // INPUT  
    .DIRECTION(), // INPUT  
    .LOAD(),      // INPUT  
    .MOVE()       // INPUT  
);

GTP_IODELAY #(
    .DELAY_STEP('b0000000),
    .DELAY_DEPTH(7)
) <InstanceName> (
    .DELAY_OB(), // OUTPUT  
    .DO(),       // OUTPUT  
    .DI(),       // INPUT  
    .DIRECTION(),// INPUT  
    .LOAD_N(),   // INPUT  
    .MOVE()      // INPUT  
);

GTP_ISERDES #(
    .ISERDES_MODE("IDDR"),
    .GRS_EN("TRUE"),
    .LRS_EN("TRUE")
) <InstanceName> (
    .DO(),    // OUTPUT[7:0]  
    .RADDR(), // INPUT[2:0]  
    .WADDR(), // INPUT[2:0]  
    .DESCLK(),// INPUT  
    .DI(),    // INPUT  
    .ICLK(),  // INPUT  
    .RCLK(),  // INPUT  
    .RST()    // INPUT  
);


endmodule 