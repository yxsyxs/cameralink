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
// Filename: GTP_GRS.v
//
// Functional description: Global reset/set
//
// Parameter description:
//
// Port description:
//
// Revision:
//    06/18/14 - Initial version.
//    03/23/19 - add global signal
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_GRS
(
    input wire GRS_N
);
////////////////GTP_I2C/////////////////
    wire            i2c0_scl_i      ;
    wire            i2c0_scl_o      ;
    wire            i2c0_sda_i      ;
    wire            i2c0_sda_o      ;
    wire            irq_i2c0        ;
    wire            i2c1_scl_i      ;
    wire            i2c1_scl_o      ;
    wire            i2c1_sda_i      ;
    wire            i2c1_sda_o      ;
    wire            irq_i2c1        ;

////////////////GTP_POWERCTL//////////////
    wire            clk_pctl;
    wire            rstn_pctl;
    wire            spi_wakeup_pctl;
    wire            i2c0_wakeup_pctl;
    wire            i2c1_wakeup_pctl;

////////////////GTP_SPI/////////////////
    wire            spi_ss_i_n      ;
    wire    [7:0]   spi_ss_o_n      ;
    wire            spi_sck_oe_n    ;
    wire            spi_sck_i       ;
    wire            spi_sck_o       ;
    wire            spi_mosi_oe_n   ;
    wire            spi_mosi_i      ;
    wire            spi_mosi_o      ;
    wire            spi_miso_oe_n   ;
    wire            spi_miso_i      ;
    wire            spi_miso_o      ;
    wire            irq_spi         ;

////////////////GTP_TIMER/////////////////
    wire            timer_rstn      ;
    wire            timer_clk       ;
    wire            timer_stamp     ;
    wire            timer_pwm       ;
    wire            irq_timer       ;

///////////////////PLL////////////////////
    wire    [7:0]   pll0_prdata     ;
    wire            pll0_pready     ;
    wire    [7:0]   pll1_prdata     ;
    wire            pll1_pready     ;

    wire GRSNET;

    assign GRSNET = GRS_N;

endmodule

