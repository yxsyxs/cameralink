//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2018 PANGO MICROSYSTEMS, INC
// ALL RIGHTS RESERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library: General technology primitive
// Filename: GTP_PLL_E3.v
//
// Functional description:
//
// Parameter description:
//
// Port description:
//
// Revision:
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ns/10fs
module GTP_PLL_E3 #(
    parameter real CLKIN_FREQ = 50.0,
    parameter PFDEN_EN        = "FALSE", //"TRUE"; "FALSE"
    parameter VCOCLK_DIV2     = 1'b0,    //1'b0~1'b1
    parameter DYNAMIC_RATIOI_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIOM_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIO0_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIO1_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIO2_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIO3_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIO4_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_RATIOF_EN = "FALSE", //"TRUE"; "FALSE"
    parameter integer STATIC_RATIOI = 1, //1~512
    parameter integer STATIC_RATIOM = 1, //1~64
    parameter integer STATIC_RATIO0 = 1, //1~512
    parameter integer STATIC_RATIO1 = 1, //1~512
    parameter integer STATIC_RATIO2 = 1, //1~512
    parameter integer STATIC_RATIO3 = 1, //1~512
    parameter integer STATIC_RATIO4 = 1, //1~512
    parameter integer STATIC_RATIOF = 1, //1~512
    parameter DYNAMIC_DUTY0_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_DUTY1_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_DUTY2_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_DUTY3_EN = "FALSE", //"TRUE"; "FALSE"
    parameter DYNAMIC_DUTY4_EN = "FALSE", //"TRUE"; "FALSE"
    parameter integer STATIC_DUTY0 = 2, //2<=STATIC_DUTY0<=2*STATIC_RATIO0-2
    parameter integer STATIC_DUTY1 = 2, //2<=STATIC_DUTY1<=2*STATIC_RATIO1-2
    parameter integer STATIC_DUTY2 = 2, //2<=STATIC_DUTY2<=2*STATIC_RATIO2-2
    parameter integer STATIC_DUTY3 = 2, //2<=STATIC_DUTY3<=2*STATIC_RATIO3-2
    parameter integer STATIC_DUTY4 = 2, //2<=STATIC_DUTY4<=2*STATIC_RATIO4-2
    parameter integer STATIC_PHASE0  = 0, //0~7
    parameter integer STATIC_PHASE1  = 0, //0~7
    parameter integer STATIC_PHASE2  = 0, //0~7
    parameter integer STATIC_PHASE3  = 0, //0~7
    parameter integer STATIC_PHASE4  = 0, //0~7
    parameter integer STATIC_PHASEF  = 0, //0~7
    parameter integer STATIC_CPHASE0 = 0, //0~511
    parameter integer STATIC_CPHASE1 = 0, //0~511
    parameter integer STATIC_CPHASE2 = 0, //0~511
    parameter integer STATIC_CPHASE3 = 0, //0~511
    parameter integer STATIC_CPHASE4 = 0, //0~511
    parameter integer STATIC_CPHASEF = 0, //0~511
    parameter CLK_CAS1_EN = "FALSE", //"TRUE"; "FALSE"
    parameter CLK_CAS2_EN = "FALSE", //"TRUE"; "FALSE"
    parameter CLK_CAS3_EN = "FALSE", //"TRUE"; "FALSE"
    parameter CLK_CAS4_EN = "FALSE", //"TRUE"; "FALSE"
    parameter integer CLKOUT5_SEL = 0, //0~4
    parameter CLKIN_BYPASS_EN     = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT0_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT0_EXT_SYN_EN  = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT1_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT2_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT3_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT4_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter CLKOUT5_SYN_EN      = "FALSE", //"TRUE"; "FALSE"
    parameter INTERNAL_FB = "ENABLE",  //"ENABLE"; "DISABLE"
    parameter EXTERNAL_FB = "DISABLE", //"CLKOUT0"; "CLKOUT1"; "CLKOUT2"; "CLKOUT3"; "CLKOUT4"; "DISABLE";
    parameter DYNAMIC_LOOP_EN = "FALSE", //"TRUE"; "FALSE"
    parameter LOOP_MAPPING_EN = "FALSE", //"TRUE"; "FALSE"
    parameter BANDWIDTH = "OPTIMIZED"    //"LOW"; "OPTIMIZED"; "HIGH"
    )(
    output CLKOUT0,
    output CLKOUT0_EXT,
    output CLKOUT1,
    output CLKOUT2,
    output CLKOUT3,
    output CLKOUT4,
    output CLKOUT5,
    output CLKSWITCH_FLAG,
    output LOCK,
    input CLKIN1,
    input CLKIN2,
    input CLKFB,
    input CLKIN_SEL,
    input CLKIN_SEL_EN,
    input PFDEN,
    input ICP_BASE,
    input [3:0] ICP_SEL,
    input [2:0] LPFRES_SEL,
    input CRIPPLE_SEL,
    input [2:0] PHASE_SEL,
    input PHASE_DIR,
    input PHASE_STEP_N,
    input LOAD_PHASE,
    input [9:0] RATIOI,
    input [6:0] RATIOM,
    input [9:0] RATIO0,
    input [9:0] RATIO1,
    input [9:0] RATIO2,
    input [9:0] RATIO3,
    input [9:0] RATIO4,
    input [9:0] RATIOF,
    input [9:0] DUTY0,
    input [9:0] DUTY1,
    input [9:0] DUTY2,
    input [9:0] DUTY3,
    input [9:0] DUTY4,
    input CLKOUT0_SYN,
    input CLKOUT0_EXT_SYN,
    input CLKOUT1_SYN,
    input CLKOUT2_SYN,
    input CLKOUT3_SYN,
    input CLKOUT4_SYN,
    input CLKOUT5_SYN,
    input PLL_PWD,
    input RST,
    input RSTODIV
    )/* synthesis syn_black_box */;

    initial
    begin
        if((PFDEN_EN == "TRUE") || (PFDEN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for PFDEN_EN");

        if((DYNAMIC_RATIOI_EN == "TRUE") || (DYNAMIC_RATIOI_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIOI_EN");

        if((DYNAMIC_RATIOM_EN == "TRUE") || (DYNAMIC_RATIOM_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIOM_EN");

        if((DYNAMIC_RATIO0_EN == "TRUE") || (DYNAMIC_RATIO0_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIO0_EN");

        if((DYNAMIC_RATIO1_EN == "TRUE") || (DYNAMIC_RATIO1_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIO1_EN");

        if((DYNAMIC_RATIO2_EN == "TRUE") || (DYNAMIC_RATIO2_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIO2_EN");

        if((DYNAMIC_RATIO3_EN == "TRUE") || (DYNAMIC_RATIO3_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIO3_EN");

        if((DYNAMIC_RATIO4_EN == "TRUE") || (DYNAMIC_RATIO4_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIO4_EN");

        if((DYNAMIC_RATIOF_EN == "TRUE") || (DYNAMIC_RATIOF_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_RATIOF_EN");

        if((DYNAMIC_DUTY0_EN == "TRUE") || (DYNAMIC_DUTY0_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_DUTY0_EN");

        if((DYNAMIC_DUTY1_EN == "TRUE") || (DYNAMIC_DUTY1_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_DUTY1_EN");

        if((DYNAMIC_DUTY2_EN == "TRUE") || (DYNAMIC_DUTY2_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_DUTY2_EN");

        if((DYNAMIC_DUTY3_EN == "TRUE") || (DYNAMIC_DUTY3_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_DUTY3_EN");

        if((DYNAMIC_DUTY4_EN == "TRUE") || (DYNAMIC_DUTY4_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_DUTY4_EN");

        if((CLK_CAS1_EN == "TRUE") || (CLK_CAS1_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLK_CAS1_EN");

        if((CLK_CAS2_EN == "TRUE") || (CLK_CAS2_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLK_CAS2_EN");

        if((CLK_CAS3_EN == "TRUE") || (CLK_CAS3_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLK_CAS3_EN");

        if((CLK_CAS4_EN == "TRUE") || (CLK_CAS4_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLK_CAS4_EN");

        if((CLKIN_BYPASS_EN == "TRUE") || (CLKIN_BYPASS_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKIN_BYPASS_EN");

        if((CLKOUT0_SYN_EN == "TRUE") || (CLKOUT0_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT0_SYN_EN");

        if((CLKOUT0_EXT_SYN_EN == "TRUE") || (CLKOUT0_EXT_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT0_EXT_SYN_EN");

        if((CLKOUT1_SYN_EN == "TRUE") || (CLKOUT1_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT1_SYN_EN");

        if((CLKOUT2_SYN_EN == "TRUE") || (CLKOUT2_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT2_SYN_EN");

        if((CLKOUT3_SYN_EN == "TRUE") || (CLKOUT3_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT3_SYN_EN");

        if((CLKOUT4_SYN_EN == "TRUE") || (CLKOUT4_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT4_SYN_EN");

        if((CLKOUT5_SYN_EN == "TRUE") || (CLKOUT5_SYN_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for CLKOUT5_SYN_EN");

        if((INTERNAL_FB == "ENABLE") || (INTERNAL_FB == "DISABLE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for INTERNAL_FB");

        if((EXTERNAL_FB == "CLKOUT0") || (EXTERNAL_FB == "CLKOUT1") || (EXTERNAL_FB == "CLKOUT2") || (EXTERNAL_FB == "CLKOUT3") || (EXTERNAL_FB == "CLKOUT4") || (EXTERNAL_FB == "DISABLE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for EXTERNAL_FB");

        if((BANDWIDTH == "LOW") || (BANDWIDTH == "OPTIMIZED") || (BANDWIDTH == "HIGH"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for BANDWIDTH");

        if((DYNAMIC_LOOP_EN == "TRUE") || (DYNAMIC_LOOP_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for DYNAMIC_LOOP_EN");

        if((LOOP_MAPPING_EN == "TRUE") || (LOOP_MAPPING_EN == "FALSE"))
        begin
        end
        else
            $display ("GTP_PLL_E3 error: illegal setting for LOOP_MAPPING_EN");
    end
///////////////////////////////////////////////////////
    wire rst_n, rstodiv_n;
///////////////////////////////////////////////////////
    wire clk_sel, clk_in, clk0, clk1, rstclksw_n;
    reg [1:0] cnt0, cnt1;
    reg dynauto_clkin;
///////////////////////////////////////////////////////
    reg clk_in_first_time, clk_fb_first_time;
    realtime clk_in_first_edge, clk_fb_first_edge;
    reg adjust;
    realtime fb_route_delay, virtual_delay1;
    integer tmp_ratio;
    realtime tmp_delay, real_delay;
///////////////////////////////////////////////////////
    wire pfden;
    reg [1:0] pfd_en_reg;
    reg clk_pfd, vcolow;
    integer cnt;

    reg clk_test, clkwo;
    realtime clk_test_time1 , clk_test_time2, clk_test_time3;
///////////////////////////////////////////////////////
    wire [9:0] idivider, divider0, divider1, divider2, divider3, divider4, fdivider;
    wire [6:0] mdivider;
    real fsdiv_set_int, fbdiv_set_int;
    reg [5:0] fbdiv_sel;
    integer prop;

    wire rstanalog_n;
    realtime clkin_rtime_last, clkin_rtime_next;
    realtime clkin_time, clkin_time1, clkin_time2, clkin_time3;
    reg clkout_lock;
    realtime vcoclk_period, vcoclk_period_half;
    realtime clkout0_time, clkout1_time, clkout2_time, clkout3_time, clkout4_time;
    integer  vcoclk_period_amp;
    realtime vcoclk_period_real, vcoclk_period_dev;

    reg done;
    integer idiv_set;
    integer fdiv_set;
    integer swap_set;
    integer fdiv_int;
    realtime offset;

    real cnt_fdiv;
    reg clk_gate, inner_clk;
    reg vcoclk;
    reg clk_vcodiv2;
    wire clkout;
///////////////////////////////////////////////////////
    wire clk_lock;
    reg [2:0] cnt_clkfb;
    reg start_clk;
    reg [10:0] cnt_lock;
    reg lock_reg;
///////////////////////////////////////////////////////
    wire clk_sel0, clk_sel1, clk_sel2, clk_sel3, clk_sel4;
    wire odiv0_rstn, odiv1_rstn, odiv2_rstn, odiv3_rstn, odiv4_rstn;
    wire [9:0] odiv0_duty, odiv1_duty, odiv2_duty, odiv3_duty, odiv4_duty;
    wire [9:0] odiv0_duty_ctrl, odiv1_duty_ctrl, odiv2_duty_ctrl, odiv3_duty_ctrl, odiv4_duty_ctrl;
    reg [2:0] enclk0, enclk1, enclk2, enclk3, enclk4;
    wire clk_en0, clk_en1, clk_en2, clk_en3, clk_en4;
    reg [9:0] odiv0_counter, odiv1_counter, odiv2_counter, odiv3_counter, odiv4_counter;
    reg odiv0_clkdivr, odiv1_clkdivr, odiv2_clkdivr, odiv3_clkdivr, odiv4_clkdivr;
    reg odiv0_set, odiv1_set, odiv2_set, odiv3_set, odiv4_set;
    wire odiv0_out, odiv1_out, odiv2_out, odiv3_out, odiv4_out;
///////////////////////////////////////////////////////
    reg fphase_step, last_fphase_step;
    integer step_odiv0, step_odiv1, step_odiv2, step_odiv3, step_odiv4;
    integer step_odiv0_1, step_odiv1_1, step_odiv2_1, step_odiv3_1, step_odiv4_1;
    integer step_odiv0_2, step_odiv1_2, step_odiv2_2, step_odiv3_2, step_odiv4_2;
    integer step_odiv0_3, step_odiv1_3, step_odiv2_3, step_odiv3_3, step_odiv4_3;
    integer step_odiv0_4, step_odiv1_4, step_odiv2_4, step_odiv3_4, step_odiv4_4;
    integer step_odiv0_5, step_odiv1_5, step_odiv2_5, step_odiv3_5, step_odiv4_5;

    realtime vco_fphase_delay0, vco_fphase_delay1, vco_fphase_delay2, vco_fphase_delay3, vco_fphase_delay4;
    integer phase0, phase1, phase2, phase3, phase4;
    realtime cphase_delay0, cphase_delay1, cphase_delay2, cphase_delay3, cphase_delay4;
    reg odiv0_out_delay1, odiv1_out_delay1, odiv2_out_delay1, odiv3_out_delay1, odiv4_out_delay1;
    reg odiv0_out_delay, odiv1_out_delay, odiv2_out_delay, odiv3_out_delay, odiv4_out_delay;
///////////////////////////////////////////////////////
    reg [2:0] clk_out0_gate, clk_out0_ext_gate, clk_out1_gate, clk_out2_gate, clk_out3_gate, clk_out4_gate, clk_out5_gate;
    reg clk_out5_reg;
    wire clkout0_en, clkout0_ext_en, clkout1_en, clkout1_adc_en, clkout2_en, clkout3_en, clkout4_en, clkout5_en, clkout4_sel;
    reg inner_rstn;
///////////////////////////////////////////////////////
    initial
    begin
        cnt0 = 2'b00;
        cnt1 = 2'b00;
        dynauto_clkin = 1'b0;
        clk_in_first_time = 1'b0;
        clk_fb_first_time = 1'b0;
        clk_in_first_edge = 0.0;
        clk_fb_first_edge = 0.0;
        fb_route_delay = 0.0;
        tmp_ratio = 0;
        tmp_delay = 0.0;
        real_delay = 0.0;
        clk_pfd  = 1'b0;
        clk_test = 1'b0;
        fsdiv_set_int = 0;
        fbdiv_set_int = 0;
        fbdiv_sel     = 6'b000001;
        done = 1'b0;
        idiv_set = 0;
        fdiv_set = 0;
        swap_set = 0;
        fdiv_int = 0;
        offset = 0;
        cnt_fdiv  = 0;
        clk_gate  = 1'b1;
        inner_clk = 1'b0;
        vcoclk    = 1'b0;
        fphase_step = 1'b0;
        last_fphase_step = 1'b0;
        step_odiv0 = 0;
        step_odiv1 = 0;
        step_odiv2 = 0;
        step_odiv3 = 0;
        step_odiv4 = 0;
        step_odiv0_1 = STATIC_PHASE0;
        step_odiv1_1 = STATIC_PHASE1;
        step_odiv2_1 = STATIC_PHASE2;
        step_odiv3_1 = STATIC_PHASE3;
        step_odiv4_1 = STATIC_PHASE4;
        step_odiv0_2 = STATIC_PHASE0;
        step_odiv1_2 = STATIC_PHASE1;
        step_odiv2_2 = STATIC_PHASE2;
        step_odiv3_2 = STATIC_PHASE3;
        step_odiv4_2 = STATIC_PHASE4;
        step_odiv0_3 = STATIC_PHASE0;
        step_odiv1_3 = STATIC_PHASE1;
        step_odiv2_3 = STATIC_PHASE2;
        step_odiv3_3 = STATIC_PHASE3;
        step_odiv4_3 = STATIC_PHASE4;
        step_odiv0_4 = STATIC_PHASE0;
        step_odiv1_4 = STATIC_PHASE1;
        step_odiv2_4 = STATIC_PHASE2;
        step_odiv3_4 = STATIC_PHASE3;
        step_odiv4_4 = STATIC_PHASE4;
        vco_fphase_delay0 = 0.0;
        vco_fphase_delay1 = 0.0;
        vco_fphase_delay2 = 0.0;
        vco_fphase_delay3 = 0.0;
        vco_fphase_delay4 = 0.0;
        cphase_delay0 = 0.0;
        cphase_delay1 = 0.0;
        cphase_delay2 = 0.0;
        cphase_delay3 = 0.0;
        cphase_delay4 = 0.0;
        odiv0_out_delay1 = 1'b0;
        odiv1_out_delay1 = 1'b0;
        odiv2_out_delay1 = 1'b0;
        odiv3_out_delay1 = 1'b0;
        odiv4_out_delay1 = 1'b0;
        odiv0_out_delay = 1'b0;
        odiv1_out_delay = 1'b0;
        odiv2_out_delay = 1'b0;
        odiv3_out_delay = 1'b0;
        odiv4_out_delay = 1'b0;
        clk_out0_gate = 3'b000;
        clk_out0_ext_gate = 3'b000;
        clk_out1_gate = 3'b000;
        clk_out2_gate = 3'b000;
        clk_out3_gate = 3'b000;
        clk_out4_gate = 3'b000;
        clk_out5_gate = 3'b000;
        clk_out5_reg  = 1'b0;
        inner_rstn = 1'b0;
        #1;
        inner_rstn = 1'b1;
        clk_in_first_time = 1'b1;
        clk_fb_first_time = 1'b1;
    end
///////////////////////////////////////////////////////
////RESET//////////////////////////////////////////////
    assign rst_n     = ~(PLL_PWD | RST) & inner_rstn;
    assign rstodiv_n = rst_n & (~RSTODIV);
///////////////////////////////////////////////////////
////INPUT_CLK_SEL//////////////////////////////////////
    assign clk_sel = (CLKIN_SEL_EN == 1'b0) ? dynauto_clkin : CLKIN_SEL;
    assign clk_in  = (clk_sel == 1'b0) ? CLKIN1 : CLKIN2;

    assign clk0 = CLKIN1 & (~CLKIN_SEL_EN);
    assign clk1 = CLKIN2 & (~CLKIN_SEL_EN);

    assign rstclksw_n = ~PLL_PWD & (~CLKIN_SEL_EN) & (~(cnt0[0] & cnt1[0] & (cnt0[1] | cnt1[1]))) & (~((cnt0[1]^cnt0[0]) & (cnt1[1]^cnt1[0])));

    always @(posedge clk0 or negedge rstclksw_n)
    begin
        if(!rstclksw_n)
            cnt0 <= 2'b00;
        else
            cnt0 <= cnt0+1;
    end

    always @(posedge clk1 or negedge rstclksw_n)
    begin
        if(!rstclksw_n)
            cnt1 <= 2'b00;
        else
            cnt1 <= cnt1+1;
    end

    always @(*)
    begin
        if(cnt0 == 2'b11)
            dynauto_clkin <= 1'b0;
        else
            if(cnt1 == 2'b11)
                dynauto_clkin <= 1'b1;
            else
                dynauto_clkin <= dynauto_clkin;
    end

    assign CLKSWITCH_FLAG = dynauto_clkin;
///////////////////////////////////////////////////////
////FBCK_DELAY/////////////////////////////////////////
    always @(posedge clk_in or negedge rst_n)
    begin
        if(!rst_n)
        begin
            clk_in_first_time = 1'b1;
            clk_in_first_edge = 0.0;
        end
        else
        begin
            if(clk_in_first_time == 1'b1)
                clk_in_first_edge = $realtime;
            clk_in_first_time = 1'b0;
        end
    end

    always @(posedge CLKFB or negedge rst_n)
    begin
        if(!rst_n)
        begin
            clk_fb_first_time = 1'b1;
            clk_fb_first_edge = 0.0;
        end
        else
        begin
            if(clk_fb_first_time == 1'b1)
                clk_fb_first_edge = $realtime;
            clk_fb_first_time = 1'b0;
        end
    end
///////////////////////////////////////////////////////
////PFD_ENABLE/////////////////////////////////////////
    assign pfden = (PFDEN_EN == "TRUE") ? PFDEN : 1'b1;

    always # 0.5 clk_pfd = ~clk_pfd;

    always @(posedge clk_in or negedge rst_n)
    begin
        if(!rst_n)
            pfd_en_reg <= 2'b11;
        else
            pfd_en_reg <= {pfd_en_reg[0], pfden};
    end

    always @(posedge clk_pfd or negedge rst_n)
    begin
        if(!rst_n)
        begin
            vcolow <= 0;
            cnt = 0;
        end
        else
            if(pfd_en_reg[1])
            begin
                vcolow <= 0;
                cnt = 0;
            end
            else
            begin
                cnt = cnt + 1;
                if(cnt == 500000)
                    vcolow <= 1;
            end
    end

    always #200 clk_test = ~clk_test;

    always @(posedge clk_test or negedge rst_n)
    begin
        if(!rst_n)
        begin
            clkwo <= 1'b0;
            clk_test_time1 = 0;
            clk_test_time2 = 0;
            clk_test_time3 = 0;

        end
        else
        begin
            clk_test_time3 = clk_test_time2;
            clk_test_time2 = clk_test_time1;
            clk_test_time1 = clkin_rtime_next;
            if(clk_test_time3 == clk_test_time1)
                clkwo <= 1'b1;
            else
                clkwo <= 1'b0;
        end
    end
///////////////////////////////////////////////////////
////PLL_ANALOG/////////////////////////////////////////
////FEEDBACK_DIVIDER_CAL///////////////////////////////
    assign idivider = (DYNAMIC_RATIOI_EN == "TRUE") ? RATIOI : STATIC_RATIOI;
    assign divider0 = (DYNAMIC_RATIO0_EN == "TRUE") ? RATIO0 : STATIC_RATIO0;
    assign divider1 = (DYNAMIC_RATIO1_EN == "TRUE") ? RATIO1 : STATIC_RATIO1;
    assign divider2 = (DYNAMIC_RATIO2_EN == "TRUE") ? RATIO2 : STATIC_RATIO2;
    assign divider3 = (DYNAMIC_RATIO3_EN == "TRUE") ? RATIO3 : STATIC_RATIO3;
    assign divider4 = (DYNAMIC_RATIO4_EN == "TRUE") ? RATIO4 : STATIC_RATIO4;
    assign fdivider = (DYNAMIC_RATIOF_EN == "TRUE") ? RATIOF : STATIC_RATIOF;
    assign mdivider = (DYNAMIC_RATIOM_EN == "TRUE") ? RATIOM : STATIC_RATIOM;

    always @(*)
    begin
        if(INTERNAL_FB == "ENABLE")
        begin
            fsdiv_set_int = fdivider;
            fbdiv_sel = 6'b000001;
        end
        else
            case(EXTERNAL_FB)
                "CLKOUT0": begin
                             fsdiv_set_int = divider0;
                             fbdiv_sel = 6'b000010;
                         end
                "CLKOUT1": begin
                             fsdiv_set_int = divider1;
                             fbdiv_sel = 6'b000100;
                         end
                "CLKOUT2": begin
                             fsdiv_set_int = divider2;
                             fbdiv_sel = 6'b001000;
                         end
                "CLKOUT3": begin
                             fsdiv_set_int = divider3;
                             fbdiv_sel = 6'b010000;
                         end
                "CLKOUT4": begin
                             fsdiv_set_int = divider4;
                             fbdiv_sel = 6'b100000;
                         end
            endcase
    end

    always @(*)
    begin
        if(VCOCLK_DIV2 == 1'b1)
        begin
            fbdiv_set_int = mdivider * fsdiv_set_int * 2;
            prop = 2;
        end
        else
        begin
            fbdiv_set_int = mdivider * fsdiv_set_int;
            prop = 1;
        end
    end
////PLL_VCO_CAL////////////////////////////////////////
    assign rstanalog_n = rst_n & ~vcolow;

    always @(posedge clk_in or negedge rstanalog_n)
    begin
        if(!rstanalog_n)
        begin
            clkin_rtime_last = 0.0;
            clkin_rtime_next = 0.0;
            clkin_time  <= 0.0;
            clkin_time1 <= 0.0;
            clkin_time2 <= 0.0;
            clkin_time3 <= 0.0;
            clkout_lock <= 0.0;
            vcoclk_period <= 1'b0;
            vcoclk_period_half <= 0.0;
            clkout0_time       <= 0.0;
            clkout1_time       <= 0.0;
            clkout2_time       <= 0.0;
            clkout3_time       <= 0.0;
            clkout4_time       <= 0.0;
            vcoclk_period_amp  <= 0.0;
            vcoclk_period_real <= 0.0;
            vcoclk_period_dev  <= 0.0;
        end
        else
        begin
            clkin_rtime_last = clkin_rtime_next;
            clkin_rtime_next = $realtime;
            if(clkin_rtime_last > 0)
            begin
                clkin_time  <= clkin_rtime_next-clkin_rtime_last;
                clkin_time1 <= clkin_time;
                clkin_time2 <= clkin_time1;
                clkin_time3 <= clkin_time2;
            end
            if(clkin_time > 0)
            begin
                clkout_lock <= (clkin_time  > 0) &&
                               (clkin_time1 > 0) &&
                               (clkin_time2 > 0) &&
                               (clkin_time3 > 0) &&
                               ((clkin_time - clkin_time1)  < 0.0001) &&
                               ((clkin_time1 - clkin_time)  < 0.0001) &&
                               ((clkin_time1 - clkin_time2) < 0.0001) &&
                               ((clkin_time2 - clkin_time1) < 0.0001) &&
                               ((clkin_time2 - clkin_time3) < 0.0001) &&
                               ((clkin_time3 - clkin_time2) < 0.0001);
            end
            if(clkin_time > 0)
            begin
                vcoclk_period      = (clkin_time * idivider) / fbdiv_set_int;
                vcoclk_period_half = vcoclk_period / 2;
                clkout0_time       = vcoclk_period * divider0 * prop;
                clkout1_time       = vcoclk_period * divider1 * prop;
                clkout2_time       = vcoclk_period * divider2 * prop;
                clkout3_time       = vcoclk_period * divider3 * prop;
                clkout4_time       = vcoclk_period * divider4 * prop;
                vcoclk_period_amp  = vcoclk_period_half * 100000;
                vcoclk_period_real = vcoclk_period_amp / 100000.0;
                vcoclk_period_dev  = (clkin_time - (vcoclk_period_real * 2 * fbdiv_set_int) / idivider) / 2;
            end
        end
    end

    always @(*)
    begin
        if(!rst_n)
        begin
            done = 1'b0;
            idiv_set = 0;
            fdiv_set = 0;
            swap_set = 0;
            fdiv_int = 0;
            offset = 0;
        end
        else
        begin
            idiv_set = idivider;
            fdiv_set = fbdiv_set_int;
            while(!done)
            begin
                if(idiv_set < fdiv_set)
                begin
                    swap_set = idiv_set;
                    idiv_set = fdiv_set;
                    fdiv_set = swap_set;
                end
                else
                    if(fdiv_set != 0)
                        idiv_set = idiv_set - fdiv_set;
                    else
                        done = 1;
            end
            fdiv_int = idiv_set;
            offset = vcoclk_period_dev * idivider/fdiv_int;
        end
    end

    always @(clkout_lock or inner_clk or clkwo)
    begin
        if(clkout_lock == 1'b0 || clkwo == 1'b1)
        begin
            inner_clk <= 1'b0;
            clk_gate  <= 1'b1;
            cnt_fdiv   = 0;
        end
        else
            if(clk_gate == 1)
            begin
                inner_clk <= 1'b1;
                clk_gate  <= 1'b0;
                cnt_fdiv   = 0;
            end
            else
            begin
                cnt_fdiv = cnt_fdiv + 1;
                if(cnt_fdiv == fbdiv_set_int/fdiv_int)
                begin
                    inner_clk <= #(vcoclk_period_half + offset) ~inner_clk;
                    cnt_fdiv = 0;
                end
                else
                    inner_clk <= #vcoclk_period_half ~inner_clk;
            end
    end

    always @(clk_in or CLKFB or negedge rst_n)
    begin
        if(!rst_n)
        begin
            adjust <= 1'b1;
            fb_route_delay = 0.0;
            tmp_ratio  = 0;
            tmp_delay  = 0.0;
            real_delay = 0.0;
        end
        else
            if(adjust == 1'b1)
            begin
                fb_route_delay = clk_fb_first_edge - clk_in_first_edge;
                if((clkin_time > 0) && (fb_route_delay > 0))
                begin
                    tmp_ratio  = fb_route_delay / clkin_time;
                    tmp_delay  = fb_route_delay - (clkin_time * tmp_ratio);
                    real_delay = clkin_time - tmp_delay;
                    adjust <= 1'b0;
                end
            end
    end

    always @(inner_clk)
    begin
        if(EXTERNAL_FB == "CLKOUT0" || EXTERNAL_FB == "CLKOUT1" || EXTERNAL_FB == "CLKOUT2" || EXTERNAL_FB == "CLKOUT3" || EXTERNAL_FB == "CLKOUT4")
            vcoclk <= #real_delay inner_clk;
        else
            vcoclk <= inner_clk;
    end
////VCO_CLK_DIV2///////////////////////////////////////
    always @(posedge vcoclk or negedge rst_n)
    begin
        if(!rst_n)
            clk_vcodiv2 <= 1'b0;
        else
            if(VCOCLK_DIV2)
                clk_vcodiv2 <= ~clk_vcodiv2;
            else
                clk_vcodiv2 <= 1'b0;
    end

    assign clkout = (VCOCLK_DIV2 == 1'b0) ? vcoclk : clk_vcodiv2;
///////////////////////////////////////////////////////
////PLL_LOCK///////////////////////////////////////////
    assign clk_lock = (INTERNAL_FB == "ENABLE") ? clk_in : CLKFB;

    always @(posedge clk_lock or negedge rstanalog_n)
    begin
        if(!rstanalog_n)
        begin
            start_clk <= 1'b0;
            cnt_clkfb <= 2'b00;
        end
        else
            if(cnt_clkfb == 3)
                start_clk = 1'b1;
            else
                cnt_clkfb = cnt_clkfb + 1;
    end

    always @(posedge clk_in or negedge rstanalog_n or clk_gate)
    begin
        if(!rstanalog_n)
        begin
            cnt_lock <= 11'b000_0000_0001;
            lock_reg <= 1'b0;
        end
        else
            if(!clk_gate && start_clk)
                if(cnt_lock == idivider * 3)
                    lock_reg <= 1'b1;
                else
                    cnt_lock <= cnt_lock+1;
            else
            begin
                cnt_lock <= 11'b000_0000_0001;
                lock_reg <= 1'b0;
            end
    end

    assign LOCK = lock_reg;
///////////////////////////////////////////////////////
////PLL_ODIV///////////////////////////////////////////
////ODIV0//////////////////////////////////////////////
    assign clk_sel0   = clkout;
    assign odiv0_rstn = rst_n & (fbdiv_sel[1] | rstodiv_n);

    assign odiv0_duty      = (DYNAMIC_DUTY0_EN  == "TRUE") ? DUTY0 : STATIC_DUTY0;
    assign odiv0_duty_ctrl = (odiv0_duty[0] == 1'b1) ? (odiv0_duty+1'b1) >> 1 : odiv0_duty >> 1;

    always @(negedge clk_sel0 or negedge odiv0_rstn)
    begin
        if(!odiv0_rstn)
            enclk0 <= 3'b000;
        else
            enclk0 <= {enclk0[1:0],1'b1};
    end

    assign clk_en0 = clk_sel0 & enclk0[2];

    always @(posedge clk_en0 or negedge odiv0_rstn)
    begin
        if(!odiv0_rstn)
            odiv0_counter <= 10'b00_0000_0000;
        else
            if(odiv0_counter == divider0 - 1'b1)
                odiv0_counter <= 10'b00_0000_0000;
            else
                odiv0_counter <= odiv0_counter + 1'b1;
    end

    always @(posedge clk_en0 or negedge odiv0_rstn)
    begin
        if(!odiv0_rstn)
            odiv0_clkdivr <= 1'b0;
        else
            if(odiv0_counter < odiv0_duty_ctrl)
                odiv0_clkdivr <= 1'b1;
            else
                odiv0_clkdivr <= 1'b0;
    end

    always @(negedge clk_en0 or negedge odiv0_rstn)
    begin
        if(!odiv0_rstn)
            odiv0_set <= 1'b0;
        else
            if(odiv0_counter == odiv0_duty_ctrl)
                odiv0_set <= odiv0_duty[0];
            else
                odiv0_set <= 1'b0;
    end

    assign odiv0_out = (divider0 == 10'b00_0000_0001) ? clk_en0 & enclk0[2] : odiv0_clkdivr & (~odiv0_set);
////ODIV1//////////////////////////////////////////////
    assign clk_sel1   = (CLK_CAS1_EN == "TRUE") ? odiv0_out : clkout;
    assign odiv1_rstn = rst_n & (fbdiv_sel[2] | rstodiv_n);

    assign odiv1_duty      = (DYNAMIC_DUTY1_EN  == "TRUE") ? DUTY1 : STATIC_DUTY1;
    assign odiv1_duty_ctrl = (odiv1_duty[0] == 1'b1) ? (odiv1_duty+1'b1) >> 1 : odiv1_duty >> 1;

    always @(negedge clk_sel1 or negedge odiv1_rstn)
    begin
        if(!odiv1_rstn)
            enclk1 <= 3'b000;
        else
            enclk1 <= {enclk1[1:0],1'b1};
    end

    assign clk_en1 = clk_sel1 & enclk1[2];

    always @(posedge clk_en1 or negedge odiv1_rstn)
    begin
        if(!odiv1_rstn)
            odiv1_counter <= 10'b00_0000_0000;
        else
            if(odiv1_counter == divider1 - 1'b1)
                odiv1_counter <= 10'b00_0000_0000;
            else
                odiv1_counter <= odiv1_counter + 1'b1;
    end

    always @(posedge clk_en1 or negedge odiv1_rstn)
    begin
        if(!odiv1_rstn)
            odiv1_clkdivr <= 1'b0;
        else
            if(odiv1_counter < odiv1_duty_ctrl)
                odiv1_clkdivr <= 1'b1;
            else
                odiv1_clkdivr <= 1'b0;
    end

    always @(negedge clk_en1 or negedge odiv1_rstn)
    begin
        if(!odiv1_rstn)
            odiv1_set <= 1'b0;
        else
            if(odiv1_counter == odiv1_duty_ctrl)
                odiv1_set <= odiv1_duty[0];
            else
                odiv1_set <= 1'b0;
    end

    assign odiv1_out = (divider1 == 10'b00_0000_0001) ? clk_en1 & enclk1[2] : odiv1_clkdivr & (~odiv1_set);
////ODIV2//////////////////////////////////////////////
    assign clk_sel2   = (CLK_CAS2_EN == "TRUE") ? odiv1_out : clkout;
    assign odiv2_rstn = rst_n & (fbdiv_sel[3] | rstodiv_n);

    assign odiv2_duty      = (DYNAMIC_DUTY2_EN  == "TRUE") ? DUTY2 : STATIC_DUTY2;
    assign odiv2_duty_ctrl = (odiv2_duty[0] == 1'b1) ? (odiv2_duty+1'b1) >> 1 : odiv2_duty >> 1;

    always @(negedge clk_sel2 or negedge odiv2_rstn)
    begin
        if(!odiv2_rstn)
            enclk2 <= 3'b000;
        else
            enclk2 <= {enclk2[1:0],1'b1};
    end

    assign clk_en2 = clk_sel2 & enclk2[2];

    always @(posedge clk_en2 or negedge odiv2_rstn)
    begin
        if(!odiv2_rstn)
            odiv2_counter <= 10'b00_0000_0000;
        else
            if(odiv2_counter == divider2 - 1'b1)
                odiv2_counter <= 10'b00_0000_0000;
            else
                odiv2_counter <= odiv2_counter + 1'b1;
    end

    always @(posedge clk_en2 or negedge odiv2_rstn)
    begin
        if(!odiv2_rstn)
            odiv2_clkdivr <= 1'b0;
        else
            if(odiv2_counter < odiv2_duty_ctrl)
                odiv2_clkdivr <= 1'b1;
            else
                odiv2_clkdivr <= 1'b0;
    end

    always @(negedge clk_en2 or negedge odiv2_rstn)
    begin
        if(!odiv2_rstn)
            odiv2_set <= 1'b0;
        else
            if(odiv2_counter == odiv2_duty_ctrl)
                odiv2_set <= odiv2_duty[0];
            else
                odiv2_set <= 1'b0;
    end

    assign odiv2_out = (divider2 == 10'b00_0000_0001) ? clk_en2 & enclk2[2] : odiv2_clkdivr & (~odiv2_set);
////ODIV3//////////////////////////////////////////////
    assign clk_sel3   = (CLK_CAS3_EN == "TRUE") ? odiv2_out : clkout;
    assign odiv3_rstn = rst_n & (fbdiv_sel[4] | rstodiv_n);

    assign odiv3_duty      = (DYNAMIC_DUTY3_EN  == "TRUE") ? DUTY3 : STATIC_DUTY3;
    assign odiv3_duty_ctrl = (odiv3_duty[0] == 1'b1) ? (odiv3_duty+1'b1) >> 1 : odiv3_duty >> 1;

    always @(negedge clk_sel3 or negedge odiv3_rstn)
    begin
        if(!odiv3_rstn)
            enclk3 <= 3'b000;
        else
            enclk3 <= {enclk3[1:0],1'b1};
    end

    assign clk_en3 = clk_sel3 & enclk3[2];

    always @(posedge clk_en3 or negedge odiv3_rstn)
    begin
        if(!odiv3_rstn)
            odiv3_counter <= 10'b00_0000_0000;
        else
            if(odiv3_counter == divider3 - 1'b1)
                odiv3_counter <= 10'b00_0000_0000;
            else
                odiv3_counter <= odiv3_counter + 1'b1;
    end

    always @(posedge clk_en3 or negedge odiv3_rstn)
    begin
        if(!odiv3_rstn)
            odiv3_clkdivr <= 1'b0;
        else
            if(odiv3_counter < odiv3_duty_ctrl)
                odiv3_clkdivr <= 1'b1;
            else
                odiv3_clkdivr <= 1'b0;
    end

    always @(negedge clk_en3 or negedge odiv3_rstn)
    begin
        if(!odiv3_rstn)
            odiv3_set <= 1'b0;
        else
            if(odiv3_counter == odiv3_duty_ctrl)
                odiv3_set <= odiv3_duty[0];
            else
                odiv3_set <= 1'b0;
    end

    assign odiv3_out = (divider3 == 10'b00_0000_0001) ? clk_en3 & enclk3[2] : odiv3_clkdivr & (~odiv3_set);
////ODIV4//////////////////////////////////////////////
    assign clk_sel4   = (CLK_CAS4_EN == "TRUE") ? odiv3_out : clkout;
    assign odiv4_rstn = rst_n & (fbdiv_sel[5] | rstodiv_n);

    assign odiv4_duty      = (DYNAMIC_DUTY4_EN  == "TRUE") ? DUTY4 : STATIC_DUTY4;
    assign odiv4_duty_ctrl = (odiv4_duty[0] == 1'b1) ? (odiv4_duty+1'b1) >> 1 : odiv4_duty >> 1;

    always @(negedge clk_sel4 or negedge odiv4_rstn)
    begin
        if(!odiv4_rstn)
            enclk4 <= 3'b000;
        else
            enclk4 <= {enclk4[1:0],1'b1};
    end

    assign clk_en4 = clk_sel4 & enclk4[2];

    always @(posedge clk_en4 or negedge odiv4_rstn)
    begin
        if(!odiv4_rstn)
            odiv4_counter <= 10'b00_0000_0000;
        else
            if(odiv4_counter == divider4 - 1'b1)
                odiv4_counter <= 10'b00_0000_0000;
            else
                odiv4_counter <= odiv4_counter + 1'b1;
    end

    always @(posedge clk_en4 or negedge odiv4_rstn)
    begin
        if(!odiv4_rstn)
            odiv4_clkdivr <= 1'b0;
        else
            if(odiv4_counter < odiv4_duty_ctrl)
                odiv4_clkdivr <= 1'b1;
            else
                odiv4_clkdivr <= 1'b0;
    end

    always @(negedge clk_en4 or negedge odiv4_rstn)
    begin
        if(!odiv4_rstn)
            odiv4_set <= 1'b0;
        else
            if(odiv4_counter == odiv4_duty_ctrl)
                odiv4_set <= odiv4_duty[0];
            else
                odiv4_set <= 1'b0;
    end

    assign odiv4_out = (divider4 == 10'b00_0000_0001) ? clk_en4 & enclk4[2] : odiv4_clkdivr & (~odiv4_set);
///////////////////////////////////////////////////////
////PHASE_SHIFT////////////////////////////////////////
    always @(*)
    begin
        fphase_step = PHASE_STEP_N;
    end

    always @(fphase_step)
    begin
        last_fphase_step <= fphase_step;
    end

    always @(*)
    begin
        if(LOAD_PHASE == 1'b1)
        begin
            step_odiv0 = step_odiv0_1;
            step_odiv1 = step_odiv1_1;
            step_odiv2 = step_odiv2_1;
            step_odiv3 = step_odiv3_1;
            step_odiv4 = step_odiv4_1;
        end
        else
            if(PHASE_SEL == 3'b000)
            begin
                if(fphase_step === 1'b0 && last_fphase_step === 1'b1)
                    if(PHASE_DIR == 1'b0)
                        step_odiv0 <= step_odiv0 + 1;
                    else
                        step_odiv0 <= step_odiv0 - 1;
            end
            else if(PHASE_SEL == 3'b001)
            begin
                if(fphase_step === 1'b0 && last_fphase_step === 1'b1)
                    if(PHASE_DIR == 1'b0)
                        step_odiv1 <= step_odiv1 + 1;
                    else
                        step_odiv1 <= step_odiv1 - 1;
            end
            else if(PHASE_SEL == 3'b010)
            begin
                if(fphase_step === 1'b0 && last_fphase_step === 1'b1)
                    if(PHASE_DIR == 1'b0)
                        step_odiv2 <= step_odiv2 + 1;
                    else
                        step_odiv2 <= step_odiv2 - 1;
            end
            else if(PHASE_SEL == 3'b011)
            begin
                if(fphase_step === 1'b0 && last_fphase_step === 1'b1)
                    if(PHASE_DIR == 1'b0)
                        step_odiv3 <= step_odiv3 + 1;
                    else
                        step_odiv3 <= step_odiv3 - 1;
            end
            else if(PHASE_SEL == 3'b100)
            begin
                if(fphase_step === 1'b0 && last_fphase_step === 1'b1)
                    if(PHASE_DIR == 1'b0)
                        step_odiv4 <= step_odiv4 + 1;
                    else
                        step_odiv4 <= step_odiv4 - 1;
            end
    end

    always @(posedge last_fphase_step or negedge rst_n)
    begin
        if(!rst_n)
        begin
            step_odiv0_1 <= STATIC_PHASE0;
            step_odiv1_1 <= STATIC_PHASE1;
            step_odiv2_1 <= STATIC_PHASE2;
            step_odiv3_1 <= STATIC_PHASE3;
            step_odiv4_1 <= STATIC_PHASE4;
        end
        else
        begin
            step_odiv0_1 <= step_odiv0;
            step_odiv1_1 <= step_odiv1;
            step_odiv2_1 <= step_odiv2;
            step_odiv3_1 <= step_odiv3;
            step_odiv4_1 <= step_odiv4;
        end
    end

    always @(posedge inner_clk)
    begin
        step_odiv0_2 <= step_odiv0_1;
        step_odiv0_3 <= step_odiv0_2;
        step_odiv1_2 <= step_odiv1_1;
        step_odiv1_3 <= step_odiv1_2;
        step_odiv2_2 <= step_odiv2_1;
        step_odiv2_3 <= step_odiv2_2;
        step_odiv3_2 <= step_odiv3_1;
        step_odiv3_3 <= step_odiv3_2;
        step_odiv4_2 <= step_odiv4_1;
        step_odiv4_3 <= step_odiv4_2;
    end

    always @(negedge inner_clk)
    begin
        step_odiv0_4 <= step_odiv0_3;
        step_odiv1_4 <= step_odiv1_3;
        step_odiv2_4 <= step_odiv2_3;
        step_odiv3_4 <= step_odiv3_3;
        step_odiv4_4 <= step_odiv4_3;
    end
////PHASE_SHIFT_CAL////////////////////////////////////
    always @(*)
    begin
        if(step_odiv0_4 >= 0)
            step_odiv0_5 <= step_odiv0_4;
        else
            step_odiv0_5 <= step_odiv0_4 + (~step_odiv0_4/(8*divider0))*8*divider0;

        if(step_odiv1_4 >= 0)
            step_odiv1_5 <= step_odiv1_4;
        else
            step_odiv1_5 <= step_odiv1_4 + (~step_odiv1_4/(8*divider1))*8*divider1;

        if(step_odiv2_4 >= 0)
            step_odiv2_5 <= step_odiv2_4;
        else
            step_odiv2_5 <= step_odiv2_4 + (~step_odiv2_4/(8*divider2))*8*divider2;

        if(step_odiv3_4 >= 0)
            step_odiv3_5 <= step_odiv3_4;
        else
            step_odiv3_5 <= step_odiv3_4 + (~step_odiv3_4/(8*divider3))*8*divider3;

        if(step_odiv4_4 >= 0)
            step_odiv4_5 <= step_odiv4_4;
        else
            step_odiv4_5 <= step_odiv4_4 + (~step_odiv4_4/(8*divider4))*8*divider4;
    end

    always @(*)
    begin
        if(clkout0_time > 0)
            if(step_odiv0_5 >= 0)
                vco_fphase_delay0 <= (step_odiv0_5 * clkout0_time) / (8 * prop * divider0);
            else
                vco_fphase_delay0 <= clkout0_time + (step_odiv0_5 * clkout0_time) / (8 * prop * divider0);

        if(clkout1_time > 0)
            if(step_odiv1_5 >= 0)
                vco_fphase_delay1 <= (step_odiv1_5 * clkout1_time) / (8 * prop * divider1);
            else
                vco_fphase_delay1 <= clkout1_time + (step_odiv1_5 * clkout1_time) / (8 * prop * divider1);

        if(clkout2_time > 0)
            if(step_odiv2_5 >= 0)
                vco_fphase_delay2 <= (step_odiv2_5 * clkout2_time) / (8 * prop * divider2);
            else
                vco_fphase_delay2 <= clkout2_time + (step_odiv2_5 * clkout2_time) / (8 * prop * divider2);

        if(clkout3_time > 0)
            if(step_odiv3_5 >= 0)
                vco_fphase_delay3 <= (step_odiv3_5 * clkout3_time) / (8 * prop * divider3);
            else
                vco_fphase_delay3 <= clkout3_time + (step_odiv3_5 * clkout3_time) / (8 * prop * divider3);

        if(clkout4_time > 0)
            if(step_odiv4_5 >= 0)
                vco_fphase_delay4 <= (step_odiv4_5 * clkout4_time) / (8 * prop * divider4);
            else
                vco_fphase_delay4 <= clkout4_time + (step_odiv4_5 * clkout4_time) / (8 * prop * divider4);
    end

    always @(*)
    begin
        if(divider0 > STATIC_CPHASE0)
            phase0 = STATIC_CPHASE0;
        else
            phase0 = STATIC_CPHASE0 - (STATIC_CPHASE0/divider0)*divider0;

        if(divider1 > STATIC_CPHASE1)
            phase1 = STATIC_CPHASE1;
        else
            phase1 = STATIC_CPHASE1 - (STATIC_CPHASE1/divider1)*divider1;

        if(divider2 > STATIC_CPHASE2)
            phase2 = STATIC_CPHASE2;
        else
            phase2 = STATIC_CPHASE2 - (STATIC_CPHASE2/divider2)*divider2;

        if(divider3 > STATIC_CPHASE3)
            phase3 = STATIC_CPHASE3;
        else
            phase3 = STATIC_CPHASE3 - (STATIC_CPHASE3/divider3)*divider3;

        if(divider4 > STATIC_CPHASE4)
            phase4 = STATIC_CPHASE4;
        else
            phase4 = STATIC_CPHASE4 - (STATIC_CPHASE4/divider4)*divider4;
    end

    always @(*)
    begin
        if(clkout0_time > 0)
            cphase_delay0 <= clkout0_time - (((divider0 - phase0) * clkout0_time) / divider0);
        else
            cphase_delay0 <= 0.0;

        if(clkout1_time > 0)
            cphase_delay1 <= clkout1_time - (((divider1 - phase1) * clkout1_time) / divider1);
        else
            cphase_delay1 <= 0.0;

        if(clkout2_time > 0)
            cphase_delay2 <= clkout2_time - (((divider2 - phase2) * clkout2_time) / divider2);
        else
            cphase_delay2 <= 0.0;

        if(clkout3_time > 0)
            cphase_delay3 <= clkout3_time - (((divider3 - phase3) * clkout3_time) / divider3);
        else
            cphase_delay3 <= 0.0;

        if(clkout4_time > 0)
            cphase_delay4 <= clkout4_time - (((divider4 - phase4) * clkout4_time) / divider4);
        else
            cphase_delay4 <= 0.0;
    end
////PHASE_SHIFT_DLY////////////////////////////////////
    always @(odiv0_out)
    begin
        odiv0_out_delay1 <= #vco_fphase_delay0 odiv0_out;
    end

    always @(odiv0_out_delay1)
    begin
        odiv0_out_delay <= #cphase_delay0 odiv0_out_delay1;
    end

    always @(odiv1_out)
    begin
        odiv1_out_delay1 <= #vco_fphase_delay1 odiv1_out;
    end

    always @(odiv1_out_delay1)
    begin
        odiv1_out_delay <= #cphase_delay1 odiv1_out_delay1;
    end

    always @(odiv2_out)
    begin
        odiv2_out_delay1 <= #vco_fphase_delay2 odiv2_out;
    end

    always @(odiv2_out_delay1)
    begin
        odiv2_out_delay <= #cphase_delay2 odiv2_out_delay1;
    end

    always @(odiv3_out)
    begin
        odiv3_out_delay1 <= #vco_fphase_delay3 odiv3_out;
    end

    always @(odiv3_out_delay1)
    begin
        odiv3_out_delay <= #cphase_delay3 odiv3_out_delay1;
    end

    always @(odiv4_out)
    begin
        odiv4_out_delay1 <= #vco_fphase_delay4 odiv4_out;
    end

    always @(odiv4_out_delay1)
    begin
        odiv4_out_delay <= #cphase_delay4 odiv4_out_delay1;
    end
///////////////////////////////////////////////////////
////PLL_GATE///////////////////////////////////////////
    always @(negedge odiv0_out_delay or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out0_gate <= 3'b000;
        else
            clk_out0_gate <= {clk_out0_gate[1:0],~CLKOUT0_SYN};
    end

    assign clkout0_gate = (CLKOUT0_SYN_EN == "TRUE") ? clk_out0_gate[2] : 1'b1;
    assign CLKOUT0      = odiv0_out_delay & clkout0_gate;

    always @(negedge odiv0_out_delay or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out0_ext_gate <= 3'b000;
        else
            clk_out0_ext_gate <= {clk_out0_ext_gate[1:0],~CLKOUT0_EXT_SYN};
    end

    assign clkout0_ext_gate = (CLKOUT0_EXT_SYN_EN == "TRUE") ? clk_out0_ext_gate[2] : 1'b1;
    assign CLKOUT0_EXT      = odiv0_out_delay & clkout0_ext_gate;

    always @(negedge odiv1_out_delay or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out1_gate <= 3'b000;
        else
            clk_out1_gate <= {clk_out1_gate[1:0],~CLKOUT1_SYN};
    end

    assign clkout1_gate = (CLKOUT1_SYN_EN == "TRUE") ? clk_out1_gate[2] : 1'b1;
    assign CLKOUT1      = odiv1_out_delay & clkout1_gate;

    always @(negedge odiv2_out_delay or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out2_gate <= 3'b000;
        else
            clk_out2_gate <= {clk_out2_gate[1:0],~CLKOUT2_SYN};
    end

    assign clkout2_gate = (CLKOUT2_SYN_EN == "TRUE") ? clk_out2_gate[2] : 1'b1;
    assign CLKOUT2      = odiv2_out_delay & clkout2_gate;

    always @(negedge odiv3_out_delay or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out3_gate <= 3'b000;
        else
            clk_out3_gate <= {clk_out3_gate[1:0],~CLKOUT3_SYN};
    end

    assign clkout3_gate = (CLKOUT3_SYN_EN == "TRUE") ? clk_out3_gate[2] : 1'b1;
    assign CLKOUT3      = odiv3_out_delay & clkout3_gate;

    assign clkout4_sel = (CLKIN_BYPASS_EN == "TRUE") ? clk_in : odiv4_out_delay;

    always @(negedge clkout4_sel or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out4_gate <= 3'b000;
        else
            clk_out4_gate <= {clk_out4_gate[1:0],~CLKOUT4_SYN};
    end

    assign clkout4_gate = (CLKOUT4_SYN_EN == "TRUE") ? clk_out4_gate[2] : 1'b1;
    assign CLKOUT4      = clkout4_sel & clkout4_gate;

    always @(*)
    begin
        case(CLKOUT5_SEL)
            0: clk_out5_reg = odiv0_out_delay;
            1: clk_out5_reg = odiv1_out_delay;
            2: clk_out5_reg = odiv2_out_delay;
            3: clk_out5_reg = odiv3_out_delay;
            4: clk_out5_reg = odiv4_out_delay;
            default: clk_out5_reg = odiv0_out_delay;
        endcase
    end

    assign clkout5_synen = (CLKOUT5_SYN_EN == "TRUE") ? 1'b1 : 1'b0;

    always @(negedge clk_out5_reg or negedge inner_rstn)
    begin
        if(!inner_rstn)
            clk_out5_gate <= 3'b000;
        else
            clk_out5_gate <= {clk_out5_gate[1:0],~CLKOUT5_SYN};
    end

    assign clkout5_gate = (CLKOUT5_SYN_EN == "TRUE") ? clk_out5_gate[2] : 1'b1;
    assign CLKOUT5      = clk_out5_reg & clkout5_gate;
endmodule
