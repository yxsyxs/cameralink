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
// Filename: GTP_DRM9K.v
//
// Functional description:
//
// Parameter  description:
//
// Port description:
//
// Revision history:
//   2017/05/23: Copy from GTP_DRM9K, Remve WW conflict feature, Size change
//               to be 9K.
//   2018/01/09: Update display informations.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module GTP_DRM9K
#(
    parameter GRS_EN = "TRUE",
    //parameter [2:0] CSA_MASK = 3'b000,
    //parameter [2:0] CSB_MASK = 3'b000,
    parameter integer DATA_WIDTH_A = 18,
    parameter integer DATA_WIDTH_B = 18,
    parameter WRITE_MODE_A = "NORMAL_WRITE",
    parameter WRITE_MODE_B = "NORMAL_WRITE",
    parameter integer DOA_REG = 0,
    parameter integer DOB_REG = 0,
    parameter integer DOA_REG_CLKINV = 0,
    parameter integer DOB_REG_CLKINV = 0,
    parameter RST_TYPE = "SYNC",
    parameter RAM_MODE = "TRUE_DUAL_PORT",
    parameter SIM_DEVICE = "LOGOS",
    parameter [287:0] INIT_00 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_01 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_02 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_03 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_04 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_05 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_06 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_07 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_08 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_09 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0A = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0B = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0C = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0D = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0E = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_0F = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_10 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_11 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_12 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_13 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_14 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_15 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_16 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_17 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_18 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_19 = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1A = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1B = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1C = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1D = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1E = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter [287:0] INIT_1F = 288'h000000000000000000000000000000000000000000000000000000000000000000000000,
    parameter INIT_FILE = "NONE",
    parameter integer BLOCK_X = 0,
    parameter integer BLOCK_Y = 0,
    parameter integer RAM_DATA_WIDTH = 9,
    parameter integer RAM_ADDR_WIDTH = 10,
    parameter INIT_FORMAT = "BIN"
) (
    output [17:0] DOA,
    output [17:0] DOB,
    input [17:0] DIA,
    input [17:0] DIB,
    input [12:0] ADDRA,
    input ADDRA_HOLD,
    input [12:0] ADDRB,
    input ADDRB_HOLD,
    //input [2:0] CSA,
    //input [2:0] CSB,
    input CLKA,
    input CLKB,
    input CEA,
    input CEB,
    input WEA,
    input WEB,
    input ORCEA,
    input ORCEB,
    input RSTA,
    input RSTB
);

    localparam  BLOCK_DEPTH = 2**(DATA_WIDTH_A == 1 ? 13 :    // block type 8k*1
                                  DATA_WIDTH_A == 2 ? 12 :    // block type 4k*2
                                  DATA_WIDTH_A == 4 ? 11 :    // block type 2k*4
                                  DATA_WIDTH_A <= 9 ? 10 :    // block type 1k*8 or 1k*9
                                 DATA_WIDTH_A <= 18 ? 9 : 8); // block type 256*36 or 256*32     block memory address width

    localparam  BLOCK_WIDTH =   DATA_WIDTH_A;             //block memory data width
//end add for initialization

    localparam MEM_SIZE = 9216;
    localparam width_a = (DATA_WIDTH_A == 32) ? 16 : (DATA_WIDTH_A == 36) ? 18 : DATA_WIDTH_A;
    localparam width_b = (DATA_WIDTH_B == 32) ? 16 : (DATA_WIDTH_B == 36) ? 18 : DATA_WIDTH_B;

    integer  cnt;
    reg [9-1:0] mem [MEM_SIZE/9-1:0];

    //reg [2:0] csa_reg = 3'b0, csb_reg = 3'b0;
    reg [12:0] ada_reg = 13'b0, adb_reg = 13'b0;
    reg [17:0] da_reg = 18'b0, db_reg = 18'b0;
    reg wea_reg = 1'b0, web_reg = 1'b0;
    wire [3:0] bea_reg;   // modify for byte_write_enable bug
    wire [1:0] beb_reg;
    wire write_en_a, write_en_b, read_en_a, read_en_b;

    reg [17:0] a_out = 18'b0, a_out_reg = 18'b0;
    //reg [17:0] a_out_reg_sync = 18'b0, a_out_reg_async = 18'b0, a_out_reg_async_sy = 18'b0;
    reg [17:0] b_out = 18'b0, b_out_reg = 18'b0;
    //reg [17:0] b_out_reg_sync = 18'b0, b_out_reg_async = 18'b0, b_out_reg_async_sy = 18'b0;

    wire grs, rsta_grs, rstb_grs;
    reg rsta_async_sy = 1'b0, rstb_async_sy = 1'b0;
    wire rsta_grs_sync;
    wire rstb_grs_sync;
    wire rsta_grs_async;
    wire rstb_grs_async;
    wire rsta_async_synrel;
    wire rstb_async_synrel;
    wire rsta_int;
    wire rstb_int;
    
    reg [17:0] doa;
    reg [17:0] dob;

    initial begin
        doa = 0;
        dob = 0;
    end

// synthesis translate_off
// add for memory initialization 2014/7/2 10:59:37    1) add ini_mem reg array to load init.dat
//                                                    2) init_file contain all the initial data of cascaded DRMS
   reg [RAM_DATA_WIDTH-1:0] ini_mem [2**RAM_ADDR_WIDTH-1:0];
   integer p;
   initial
   begin
      if(INIT_FILE != "NONE")
      begin
          if(INIT_FORMAT == "BIN")
              $readmemb(INIT_FILE,ini_mem);
          else
              $readmemh(INIT_FILE,ini_mem);
          for(p=0;p<20;p=p+1)
              $display("ini_mem[%d] = %b",p,ini_mem[p]);
      end
   end
//end  add
///////////////////
// parameter check
///////////////////
    initial begin
        case (DATA_WIDTH_A)
            1, 2, 4, 8, 16, 32: begin
                case (DATA_WIDTH_B)
                    1, 2, 4, 8, 16, 32:  ; //null
                    default: begin
                        $display("ERROR: GTP_DRM9K instance %m parameter DATA_WIDTH_B:%d is illegal. The legal values are 1,2,4,8,16 or 32.",DATA_WIDTH_B);
                        $finish;
                    end
                endcase
            end
            9, 18, 36: begin
                case (DATA_WIDTH_B)
                    9, 18, 36:    ; //null
                    default: begin
                        $display("ERROR: GTP_DRM9K instance %m parameter DATA_WIDTH_B:%d is illegal. The legal values are 9,18 or 36.",DATA_WIDTH_B);
                        $finish;
                    end
                endcase
            end
            default: begin
                $display("ERROR: GTP_DRM9K instance %m parameter DATA_WIDTH_A:%d is illegal. The legal values are 1,2,4,8,9,16,18,32 or 36.",DATA_WIDTH_A);
                $finish;
            end
        endcase

        case (WRITE_MODE_A)
            "NORMAL_WRITE",
            "TRANSPARENT_WRITE",
            "READ_BEFORE_WRITE":    ; //null 
            default: begin
                $display("ERROR: GTP_DRM9K instance %m parameter WRITE_MODE_A: %s is illegal. The legal values are NORMAL_WRITE,TRANSPARENT_WRITE or READ_BEFORE_WRITE.", WRITE_MODE_A);
                $finish;
            end
        endcase

        case (WRITE_MODE_B)
            "NORMAL_WRITE",
            "TRANSPARENT_WRITE",
            "READ_BEFORE_WRITE":    ; //null  
            default: begin
                $display("ERROR: GTP_DRM9K instance %m parameter WRITE_MODE_B: %s is illegal. The legal values are NORMAL_WRITE,TRANSPARENT_WRITE or READ_BEFORE_WRITE.", WRITE_MODE_B);
                $finish;
            end
        endcase

        case (RST_TYPE)
            "ASYNC",
            "ASYNC_SYNC_RELEASE",
            "SYNC":     ;//null
            default: begin
                $display("ERROR: GTP_DRM9K instance %m parameter RST_TYPE: %s is illegal. The legal values are ASYNC,ASYNC_SYNC_RELEASE or SYNC.", RST_TYPE);
                $finish;
            end
        endcase

        case (RAM_MODE)
            "ROM",
            "SINGLE_PORT","SIMPLE_DUAL_PORT":     ;//null
            "TRUE_DUAL_PORT": begin
                if (DATA_WIDTH_A > 18 || DATA_WIDTH_B > 18) begin
                    $display("ERROR: GTP_DRM9K instance %m parameter DATA_WIDTH_A and DATA_WIDTH_B in TRUE_DUAL_PORT MODE:%d,%d is illegal. The legal values are 1,2,4,8,9,16 or 18.",DATA_WIDTH_A,DATA_WIDTH_B);
                    $finish;
                end
            end
            default: begin
                $display("ERROR: GTP_DRM9K instance %m parameter RAM_MODE value: %s is illegal. The legal values are ROM or SINGLE_PORT or SIMPLE_DUAL_PORT or TRUE_DUAL_PORT.", RAM_MODE);
                $finish;
            end
        endcase

        case (SIM_DEVICE)
            "LOGOS","PGL22G":    ;//null
            default: begin
                   $display("ERROR: GTP_DRM9K instance %m parameter SIM_DEVICE value: %s is illegal. The legal values are LOGOS or PGL22G.", SIM_DEVICE);
                   $finish;
            end
        endcase

    end

/////////////////=
// initialization
/////////////////=

    initial begin
        if (INIT_FILE == "NONE") begin
            for (cnt = 0; cnt < 32; cnt = cnt + 1) begin
                mem[32*0 + cnt] = INIT_00[cnt*9 +: 9];
                mem[32*1 + cnt] = INIT_01[cnt*9 +: 9];
                mem[32*2 + cnt] = INIT_02[cnt*9 +: 9];
                mem[32*3 + cnt] = INIT_03[cnt*9 +: 9];
                mem[32*4 + cnt] = INIT_04[cnt*9 +: 9];
                mem[32*5 + cnt] = INIT_05[cnt*9 +: 9];
                mem[32*6 + cnt] = INIT_06[cnt*9 +: 9];
                mem[32*7 + cnt] = INIT_07[cnt*9 +: 9];
                mem[32*8 + cnt] = INIT_08[cnt*9 +: 9];
                mem[32*9 + cnt] = INIT_09[cnt*9 +: 9];
                mem[32*10 + cnt] = INIT_0A[cnt*9 +: 9];
                mem[32*11 + cnt] = INIT_0B[cnt*9 +: 9];
                mem[32*12 + cnt] = INIT_0C[cnt*9 +: 9];
                mem[32*13 + cnt] = INIT_0D[cnt*9 +: 9];
                mem[32*14 + cnt] = INIT_0E[cnt*9 +: 9];
                mem[32*15 + cnt] = INIT_0F[cnt*9 +: 9];
                mem[32*16 + cnt] = INIT_10[cnt*9 +: 9];
                mem[32*17 + cnt] = INIT_11[cnt*9 +: 9];
                mem[32*18 + cnt] = INIT_12[cnt*9 +: 9];
                mem[32*19 + cnt] = INIT_13[cnt*9 +: 9];
                mem[32*20 + cnt] = INIT_14[cnt*9 +: 9];
                mem[32*21 + cnt] = INIT_15[cnt*9 +: 9];
                mem[32*22 + cnt] = INIT_16[cnt*9 +: 9];
                mem[32*23 + cnt] = INIT_17[cnt*9 +: 9];
                mem[32*24 + cnt] = INIT_18[cnt*9 +: 9];
                mem[32*25 + cnt] = INIT_19[cnt*9 +: 9];
                mem[32*26 + cnt] = INIT_1A[cnt*9 +: 9];
                mem[32*27 + cnt] = INIT_1B[cnt*9 +: 9];
                mem[32*28 + cnt] = INIT_1C[cnt*9 +: 9];
                mem[32*29 + cnt] = INIT_1D[cnt*9 +: 9];
                mem[32*30 + cnt] = INIT_1E[cnt*9 +: 9];
                mem[32*31 + cnt] = INIT_1F[cnt*9 +: 9];
            end
        end
        else  begin      // INIT_FILE 
//add for initialization RAM     1) load initial data from ini_mem to every mem block  when  cascaded with DRMS
// 2) the ini_mem contain  the whole data of init_file  3) distribute the initdata to every mem in cascaded DRMs
            case(DATA_WIDTH_A)
                1: begin  //DRM TYPE 8K*1
                   for(cnt=0; cnt<1024;cnt = cnt+1)
                       mem[cnt][7:0] = {ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+7][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+6][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+5][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+4][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+3][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+2][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8+1][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*8][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH]};
                end
                2: begin //DRM TYPE 4K*2
                   for(cnt=0; cnt<1024;cnt = cnt+1)
                       mem[cnt][7:0] = {ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*4+3][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*4+2][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*4+1][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                        ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*4][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH]};
                end
                4: begin //DRM TYPE 2K*4
                   for(cnt=0; cnt<1024;cnt = cnt+1)
                       {mem[cnt][7:0]} = {ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*2+1][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH],
                                          ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt*2][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH]};
                end
                8: begin //DRM TYPE 1K*8
                   for(cnt=0; cnt<1024;cnt = cnt+1)
                       mem[cnt][7:0] = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
                9: begin //DRM TYPE 1K*9
                   for(cnt=0; cnt<1024;cnt = cnt+1)
                       mem[cnt] = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
                16:begin //DRM TYPE 512*16
                   for(cnt=0; cnt<512;cnt = cnt+1)
                       {mem[cnt*2+1][7:0], mem[cnt*2][7:0]} = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
                18:begin //DRM TYPE 512*18
                   for(cnt=0; cnt<512;cnt = cnt+1)
                       {mem[cnt*2+1], mem[cnt*2]} = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
                32:begin //DRM TYPE 256*32
                   for(cnt=0; cnt<256;cnt = cnt+1)
                       {mem[cnt*4+3][7:0],mem[cnt*4+2][7:0],mem[cnt*4+1][7:0],mem[cnt*4][7:0]} = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
                36:begin //DRM TYPE 256*36
                   for(cnt=0; cnt<256;cnt = cnt+1)
                       {mem[cnt*4+3],mem[cnt*4+2],mem[cnt*4+1],mem[cnt*4]} = ini_mem[BLOCK_Y*BLOCK_DEPTH + cnt][BLOCK_X*BLOCK_WIDTH +:BLOCK_WIDTH];
                end
            endcase
        end
    end

    //always @(posedge CLKA) begin
    //    if (CEA)
    //        csa_reg <= CSA;
    //end
    always @(posedge CLKA) begin
        if (CEA) begin
            // high to hold the address
            if (ADDRA_HOLD == 1'b0) begin
                ada_reg <= ADDRA;
            end
            da_reg[17:0] <= DIA[17:0];
            wea_reg <= WEA;
        end
    end
    //always @(posedge CLKB) begin
    //    if (CEB)
    //        csb_reg <= CSB;
    //end
    always @(posedge CLKB) begin
        if (CEB) begin
            // high to hold the address
            if (ADDRB_HOLD == 1'b0) begin
                adb_reg <= ADDRB;
            end
                web_reg <= WEB;
        end
    end
    // byte write enable
    assign bea_reg = ada_reg[3:0];   // modify for byte_write_enable bug
    assign beb_reg = adb_reg[1:0];

    ///////////////////
    // task & function
    ///////////////////

    function [DATA_WIDTH_A-1:0] mem_read_a;
        input [12:0]  addr;
    begin
        case (DATA_WIDTH_A)
            1: mem_read_a = mem[addr[12:3]][addr[2:0]];
            2: mem_read_a = mem[addr[12:3]][addr[2:1]*2 +: 2];
            4: mem_read_a = mem[addr[12:3]][addr[2]*4 +: 4];
            8: mem_read_a = mem[addr[12:3]][7:0];
            9: mem_read_a = mem[addr[12:3]];
            16: mem_read_a = {mem[addr[12:4]*2+1][7:0], mem[addr[12:4]*2][7:0]};
            18: mem_read_a = {mem[addr[12:4]*2+1],      mem[addr[12:4]*2]};
            32: mem_read_a = {mem[addr[12:5]*4+3][7:0], mem[addr[12:5]*4+2][7:0],
                              mem[addr[12:5]*4+1][7:0], mem[addr[12:5]*4][7:0]};
            36: mem_read_a = {mem[addr[12:5]*4+3],      mem[addr[12:5]*4+2],
                              mem[addr[12:5]*4+1],      mem[addr[12:5]*4]};
            default:      ;//null 
        endcase
    end
    endfunction

    function [DATA_WIDTH_B-1:0] mem_read_b;
        input [12:0] addr;
    begin
        case (DATA_WIDTH_B)
            1: mem_read_b = mem[addr[12:3]][addr[2:0]];
            2: mem_read_b = mem[addr[12:3]][addr[2:1]*2 +: 2];
            4: mem_read_b = mem[addr[12:3]][addr[2]*4 +: 4];
            8: mem_read_b = mem[addr[12:3]][7:0];
            9: mem_read_b = mem[addr[12:3]];
            16: mem_read_b = {mem[addr[12:4]*2+1][7:0], mem[addr[12:4]*2][7:0]};
            18: mem_read_b = {mem[addr[12:4]*2+1],      mem[addr[12:4]*2]};
            32: mem_read_b = {mem[addr[12:5]*4+3][7:0], mem[addr[12:5]*4+2][7:0],
                              mem[addr[12:5]*4+1][7:0], mem[addr[12:5]*4][7:0]};
            36: mem_read_b = {mem[addr[12:5]*4+3],      mem[addr[12:5]*4+2],
                              mem[addr[12:5]*4+1],      mem[addr[12:5]*4]};
            default:      ;//null
        endcase
    end
    endfunction

    task mem_write_a;
        input [12:0] addr;
        input [35:0] data;
        input [3:0]  byte_en;
    begin
        case (DATA_WIDTH_A)
            1: mem[addr[12:3]][addr[2:0]] = data[0];
            2: mem[addr[12:3]][addr[2:1]*2 +: 2] = data[1:0];
            4: mem[addr[12:3]][addr[2]*4 +: 4] = data[3:0];
            8: mem[addr[12:3]][7:0] = data[7:0];
            9: mem[addr[12:3]] = data[8:0];
            16: begin
                if (byte_en[1])
                    mem[addr[12:4]*2+1][7:0] = data[16:9];
                if (byte_en[0])
                    mem[addr[12:4]*2][7:0]   = data[7:0];
            end
            18: begin
                if (byte_en[1])
                    mem[addr[12:4]*2+1] = data[17:9];
                if (byte_en[0])
                    mem[addr[12:4]*2]   = data[8:0];
            end
            32: begin
                if (byte_en[3])
                    mem[addr[12:5]*4+3][7:0] = data[34:27];
                if (byte_en[2])
                    mem[addr[12:5]*4+2][7:0] = data[25:18];
                if (byte_en[1])
                    mem[addr[12:5]*4+1][7:0] = data[16:9];
                if (byte_en[0])
                    mem[addr[12:5]*4][7:0]   = data[7:0];
            end
            36: begin
                if (byte_en[3])
                    mem[addr[12:5]*4+3] = data[35:27];
                if (byte_en[2])
                    mem[addr[12:5]*4+2] = data[26:18];
                if (byte_en[1])
                    mem[addr[12:5]*4+1] = data[17:9];
                if (byte_en[0])
                    mem[addr[12:5]*4]   = data[8:0];
            end
            default:     ;//null
        endcase
    end
    endtask

    task mem_write_b;
        input [12:0] addr;
        input [17:0] data;
        input [3:0]  byte_en;
    begin
        case (DATA_WIDTH_B)
            1: mem[addr[12:3]][addr[2:0]] = data[0];
            2: mem[addr[12:3]][addr[2:1]*2 +: 2] = data[1:0];
            4: mem[addr[12:3]][addr[2]*4 +: 4] = data[3:0];
            8: mem[addr[12:3]][7:0] = data[7:0];
            9: mem[addr[12:3]] = data[8:0];
            16: begin
                if (byte_en[1])
                    mem[addr[12:4]*2+1][7:0] = data[16:9];
                if (byte_en[0])
                    mem[addr[12:4]*2][7:0]   = data[7:0];
            end
            18: begin
                if (byte_en[1])
                    mem[addr[12:4]*2+1] = data[17:9];
                if (byte_en[0])
                    mem[addr[12:4]*2]   = data[8:0];
            end
            default:     ;//null
        endcase
    end
    endtask

    ///////////////
    // memory core
    ///////////////
reg CLKA_active;
reg CLKB_active;
initial begin
  CLKA_active = 1'b0;
  CLKB_active = 1'b0;
end
always @(posedge CLKA) begin
   if (CEA) begin
      CLKA_active <= 1'b1;
      #0.2 CLKA_active = 1'b0;
   end
   else
      CLKA_active <= 1'b0;
end
always @(posedge CLKB) begin
   if (CEB) begin
      CLKB_active <= 1'b1;
      #0.2 CLKB_active = 1'b0;
   end
   else
      CLKB_active <= 1'b0;
end

generate
////////////////////////////////////////////////////////////////////////////////////////////
// ROM or SINGLE_PORT 
////////////////////////////////////////////////////////////////////////////////////////////
if(RAM_MODE == "ROM" || RAM_MODE == "SINGLE_PORT") begin:ROMorSP_MODE  //1 no clock region switch  2 no mix width

    always @(posedge CLKA) begin    //modify for db_reg syn with CLKA
        if (CEA)
            db_reg[17:0] <= DIB[17:0];
    end
    if (DATA_WIDTH_A >= 32 || DATA_WIDTH_B >= 32) begin

        assign write_en_a = (wea_reg == 1'b1);
        assign read_en_b  = (web_reg == 1'b0);
        // Port A operations
        always @(negedge CLKA_active) begin
            if (write_en_a) begin  // write
                mem_write_a(ada_reg, {db_reg[17:0], da_reg[17:0]}, bea_reg[3:0]);
            end
        end
        always@(negedge CLKB_active or posedge rstb_int) begin
            if (rstb_int)
               {b_out[width_b-1:0], a_out[width_b-1:0]} = 'b0;
            else if(read_en_b)
               {b_out[width_b-1:0], a_out[width_b-1:0]} = mem_read_b(adb_reg);
        end

    end
    else  begin   //x1 x2 x4 x8 x9 x16 x18 

        assign write_en_a = (wea_reg == 1'b1);
        assign read_en_a  = (wea_reg == 1'b0);
        always @(negedge CLKA_active) begin
            if (write_en_a)  begin  // write
               // read during write
               if (WRITE_MODE_A == "TRANSPARENT_WRITE") begin
                   a_out[width_a-1:0] = mem_read_a(ada_reg);

                   if(DATA_WIDTH_A == 16) begin
                       if(bea_reg[0])
                           a_out[7:0] = da_reg[7:0];
                       else
                           a_out[7:0] = a_out[7:0];

                       if(bea_reg[1])
                           a_out[15:8] = da_reg[16:9];
                       else
                           a_out[15:8] = a_out[15:8];
                   end
                   else if(DATA_WIDTH_A == 18) begin
                        if(bea_reg[0])
                            a_out[8:0] = da_reg[8:0];
                        else
                            a_out[8:0] = a_out[8:0];

                        if(bea_reg[1])
                            a_out[17:9] = da_reg[17:9];
                        else
                            a_out[17:9] = a_out[17:9];
                   end
                   else begin
                      a_out[width_a-1:0] = da_reg[width_a-1:0];
                   end
               end
               else if (WRITE_MODE_A == "READ_BEFORE_WRITE")
                   a_out[width_a-1:0] = mem_read_a(ada_reg);

               mem_write_a(ada_reg, da_reg[17:0], {2'b0,bea_reg[1:0]});
            end
        end
        always @(negedge CLKA_active or posedge rsta_int) begin
            if (rsta_int)
               a_out[width_a-1:0] = 'b0;
            else if (read_en_a)          // read 
               a_out[width_a-1:0] = mem_read_a(ada_reg);
        end
        // Port B operations

    end
end
////////////////////////////////////////////////////////////////////////////////////////////
//SIMPLE_DUAL_PORT
////////////////////////////////////////////////////////////////////////////////////////////
else if(RAM_MODE == "SIMPLE_DUAL_PORT")begin:SDP_MODE  //1 clock region switch 2 mix width
    //port_A operation: only write in SDP MODE
    if (DATA_WIDTH_A >= 32) begin:PORTA

        assign write_en_a = (wea_reg == 1'b1);

        always @(posedge CLKA) begin
           if (CEA)
              db_reg[17:0]  <= DIB[17:0];   //the valid width of db_reg is equal to da_reg
        end
        always @(negedge CLKA_active) begin
           if (write_en_a)    // write 
              mem_write_a(ada_reg, {db_reg[17:0], da_reg[17:0]},bea_reg[3:0]);
        end
    end
    else  begin:PORTA    //  x1 x2 x4 x8 x9 x16 x18 

        assign write_en_a = (wea_reg == 1'b1);

        always @(negedge CLKA_active) begin
           if (write_en_a)     // write 
              mem_write_a(ada_reg, da_reg[17:0], {2'b0,bea_reg[1:0]});
        end
    end
    //port_B operation:only read in SDP MODE
    if (DATA_WIDTH_B >= 32) begin:PORTB
// SIMPLE_DUAL_PORT 
        assign read_en_b  = (web_reg == 1'b0);

        always @(negedge CLKB_active or posedge rstb_int) begin
           if (rstb_int)
              {b_out[width_b-1 : 0], a_out[width_b-1 : 0]} = 'b0;
           else if (read_en_b)       // read 
              {b_out[width_b-1 : 0], a_out[width_b-1 : 0]} = mem_read_b(adb_reg);
        end
    end
    else  begin:PORTB  //  x1 x2 x4 x8 x9 x16 x18 

        assign read_en_b  = (web_reg == 1'b0);

        always @(negedge CLKB_active or posedge rstb_int) begin
           if (rstb_int)
              b_out[width_b-1 : 0] = 'b0;
           else if (read_en_b)   //  read 
              b_out[width_b-1 : 0] = mem_read_b(adb_reg);
        end
    end
end
////////////////////////////////////////////////////////////////////////////////////////////
//DP_MODE
////////////////////////////////////////////////////////////////////////////////////////////
else   begin:DP_MODE   //  --x1 x2 x4 x8 x9 x16 x18--    1) no clock region switch   2)mix width
    assign write_en_a = (wea_reg == 1'b1) ;
    assign read_en_a  = (wea_reg == 1'b0) ;
    assign write_en_b = (web_reg == 1'b1) ;
    assign read_en_b  = (web_reg == 1'b0) ;
    // Port A operations
    always @(negedge CLKA_active ) begin
        if (write_en_a)  begin  // write
            // read during write
            if (WRITE_MODE_A == "TRANSPARENT_WRITE") begin
               a_out[width_a-1:0] = mem_read_a(ada_reg);

               if(DATA_WIDTH_A == 16) begin
                   if(bea_reg[0])
                       a_out[7:0] = da_reg[7:0];
                   else
                       a_out[7:0] = a_out[7:0];

                   if(bea_reg[1])
                       a_out[15:8] = da_reg[16:9];
                   else
                       a_out[15:8] = a_out[15:8];
               end
               else if(DATA_WIDTH_A == 18) begin
                    if(bea_reg[0])
                        a_out[8:0] = da_reg[8:0];
                    else
                        a_out[8:0] = a_out[8:0];

                    if(bea_reg[1])
                        a_out[17:9] = da_reg[17:9];
                    else
                        a_out[17:9] = a_out[17:9];
               end
               else begin
                  a_out[width_a-1:0] = da_reg[width_a-1:0];
               end
            end
            else if (WRITE_MODE_A == "READ_BEFORE_WRITE")
                a_out[width_a-1 : 0] = mem_read_a(ada_reg);

            mem_write_a(ada_reg, da_reg[17:0], {2'b0,bea_reg[1:0]});
        end
    end
    always @(negedge CLKA_active or posedge rsta_int) begin
        if (rsta_int)
           a_out[width_a-1 : 0] = 'b0;
        else if (read_en_a)
           a_out[width_a-1 : 0] = mem_read_a(ada_reg);
    end
    // Port B operations
    always @(posedge CLKB) begin  // modify for db_reg syn with CLKB
         if (CEB)
            db_reg[17:0] <= DIB[17:0];
    end

    always @(negedge CLKB_active ) begin
        if (write_en_b)  begin  // write
            // read during write
            if (WRITE_MODE_B == "TRANSPARENT_WRITE") begin

                b_out[width_b-1:0] = mem_read_b(adb_reg);

                if(DATA_WIDTH_B == 16) begin
                    if(beb_reg[0])
                        b_out[7:0] = db_reg[7:0];
                    else
                        b_out[7:0] = b_out[7:0];

                    if(beb_reg[1])
                        b_out[15:8] = db_reg[16:9];
                    else
                        b_out[15:8] = b_out[15:8];
                end
                else if(DATA_WIDTH_B == 18) begin
                    if(beb_reg[0])
                        b_out[8:0] = db_reg[8:0];
                    else
                        b_out[8:0] = b_out[8:0];

                    if(beb_reg[1])
                        b_out[17:9] = db_reg[17:9];
                    else
                        b_out[17:9] = b_out[17:9];
                end
                else begin
                   b_out[width_b-1:0] = db_reg[width_b-1:0];
                end
            end
            else if (WRITE_MODE_B == "READ_BEFORE_WRITE")
                b_out[width_b-1 : 0] = mem_read_b(adb_reg);

            mem_write_b(adb_reg, db_reg[17:0], {2'b0,beb_reg[1:0]});
        end
    end
    always @(negedge CLKB_active or posedge rstb_int) begin
        if (rstb_int)
           b_out[width_b-1 : 0] = 'b0;
        else if (read_en_b)
           b_out[width_b-1 : 0] = mem_read_b(adb_reg);
    end
end

endgenerate

    //////////////
    // core latch
    //////////////
    assign grsn =  (GRS_EN == "TRUE") ? GRS_INST.GRSNET : 1'b1;
    assign grs =  ~grsn;
    or (rsta_grs, grs, RSTA);
    or (rstb_grs, grs, RSTB);

wire CLKA_for_or,CLKB_for_or;
    // async reset
reg rsta_grsn_d;

    always @(posedge CLKA_for_or ) begin
        if (RSTA) begin
            rsta_grsn_d   <= 1'b1;
        end
        else begin
            rsta_grsn_d   <= 1'b0;
        end
    end

    always @(posedge CLKA_for_or or posedge RSTA) begin
        if (RSTA) begin
            rsta_async_sy <= 1'b1;
        end
        else begin
            rsta_async_sy <= rsta_grsn_d;
        end
    end

reg rstb_grsn_d;
    always @(posedge CLKB_for_or) begin
        if (RSTB) begin
            rstb_grsn_d   <= 1'b1;
        end
        else begin
            rstb_grsn_d   <= 1'b0;
        end
    end

    always @(posedge CLKB_for_or or posedge RSTB) begin
        if (RSTB) begin
            rstb_async_sy <= 1'b1;
        end
        else begin
            rstb_async_sy <= rstb_grsn_d;
        end
    end

initial begin
    rsta_grsn_d = 1'b1;
    rsta_async_sy = 1'b1;
    rstb_grsn_d = 1'b1;
    rstb_async_sy = 1'b1;
end

assign rsta_grs_sync  = (RST_TYPE == "SYNC") ? rsta_grsn_d : 1'b0; //register to match with CLKA_ative falling edge
assign rstb_grs_sync  = (RST_TYPE == "SYNC") ? rstb_grsn_d : 1'b0; //register to match with CLKA_ative falling edge
assign rsta_grs_async = (RST_TYPE == "ASYNC") ? rsta_grs : grs;
assign rstb_grs_async = (RST_TYPE == "ASYNC") ? rstb_grs : grs;
assign rsta_async_synrel = rsta_grs | rsta_async_sy;
assign rstb_async_synrel = rstb_grs | rstb_async_sy;
assign rsta_int = (RST_TYPE == "ASYNC_SYNC_RELEASE") ? rsta_async_synrel : rsta_grs_sync | rsta_grs_async;
assign rstb_int = (RST_TYPE == "ASYNC_SYNC_RELEASE") ? rstb_async_synrel : rstb_grs_sync | rstb_grs_async;
/////////////////////////////////////////////////////////////////////
//port out
assign CLKA_for_or = (DOA_REG_CLKINV == 1) ? ~CLKA : CLKA;
assign CLKB_for_or = (DOB_REG_CLKINV == 1) ? ~CLKB : CLKB;
generate
if (DATA_WIDTH_B >= 32) begin:FAKE_DP_OUT
    ///////////////////
    // output register
    ///////////////////
    always @(posedge CLKB_for_or or posedge rstb_int) begin
        if (rstb_int)
            a_out_reg <= 0;
        else if (ORCEB)
            a_out_reg[width_b-1 : 0] <= a_out[width_b-1 : 0];
    end
    //doa combination logic
    always @(*) begin
        if (DOB_REG == 0)
        begin
            case(DATA_WIDTH_B)
                32: {doa[16:9],doa[7:0]} = {a_out[15:8],a_out[7:0]};
                36:  doa[width_b-1:0] = a_out[width_b-1:0]        ;
            endcase
        end
        else
        begin
            case(DATA_WIDTH_B)
                32: {doa[16:9],doa[7:0]} = {a_out_reg[15:8],a_out_reg[7:0]};
                36:  doa[width_b-1:0] = a_out_reg[width_b-1 : 0];
            endcase
        end
    end

    //port_B output
    always @(posedge CLKB_for_or or posedge rstb_int) begin
        if (rstb_int)
            b_out_reg <= 0;
        else if (ORCEB)
            b_out_reg[width_b-1 : 0] <= b_out[width_b-1 : 0];
    end
    //dob combination logic
    always @(*) begin
        if (DOB_REG == 0)
        begin
            case(DATA_WIDTH_B)
                32:{dob[16:9],dob[7:0]} = {b_out[15:8],b_out[7:0]};
                36: dob[width_b-1:0] = b_out[width_b-1 : 0];
            endcase
        end
        else
        begin
            case(DATA_WIDTH_B)
                32:{dob[16:9],dob[7:0]} = {b_out_reg[15:8],b_out_reg[7:0]};
                36: dob[width_b-1:0] = b_out_reg[width_b-1 : 0];
            endcase
        end
    end
end
else  begin:TRUE_DP_OUT   // x1 x2 x4 x8 x9 x16 x18    

    //port_A output
    always @(posedge CLKA_for_or or posedge rsta_int) begin
        if (rsta_int)
            a_out_reg <= 0;
        else if (ORCEA)
            a_out_reg[width_a-1 : 0] <= a_out[width_a-1 : 0];
    end
    //doa combination logic
    always @(*) begin
        if (DOA_REG == 0)
        begin
            case(DATA_WIDTH_A)
               1: {doa[16:9],doa[7:0]} = {16{a_out[width_a-1:0]}};
               2: {doa[16:9],doa[7:0]} = { 8{a_out[width_a-1:0]}};
               4: {doa[16:9],doa[7:0]} = { 4{a_out[width_a-1:0]}};
               8: {doa[16:9],doa[7:0]} = { 2{a_out[width_a-1:0]}};
               9: {doa[17:9],doa[8:0]} = { 2{a_out[width_a-1:0]}};
               16:{doa[16:9],doa[7:0]} =     a_out[width_a-1:0]  ;
               18: doa[17:0]          =     a_out[width_a-1:0]  ;
            endcase
        end
        else
        begin
            case(DATA_WIDTH_A)
               1: {doa[16:9],doa[7:0]} = {16{a_out_reg[width_a-1:0]}};
               2: {doa[16:9],doa[7:0]} = { 8{a_out_reg[width_a-1:0]}};
               4: {doa[16:9],doa[7:0]} = { 4{a_out_reg[width_a-1:0]}};
               8: {doa[16:9],doa[7:0]} = { 2{a_out_reg[width_a-1:0]}};
               9: {doa[17:9],doa[8:0]} = { 2{a_out_reg[width_a-1:0]}};
               16:{doa[16:9],doa[7:0]} =     a_out_reg[width_a-1:0] ;
               18: doa[17:0]          =     a_out_reg[width_a-1:0] ;
            endcase
        end
    end

    //port_B output
    always @(posedge CLKB_for_or or posedge rstb_int) begin
        if (rstb_int)
            b_out_reg <= 0;
        else if (ORCEB)
            b_out_reg[width_b-1 : 0] <= b_out[width_b-1 : 0];
    end
    //dob combination logic
    always @(*) begin
        if (DOB_REG == 0)
        begin
            case(DATA_WIDTH_B)
               1: {dob[16:9],dob[7:0]} = {16{b_out[width_b-1:0]}};
               2: {dob[16:9],dob[7:0]} = { 8{b_out[width_b-1:0]}};
               4: {dob[16:9],dob[7:0]} = { 4{b_out[width_b-1:0]}};
               8: {dob[16:9],dob[7:0]} = { 2{b_out[width_b-1:0]}};
               9: {dob[17:9],dob[8:0]} = { 2{b_out[width_b-1:0]}};
               16:{dob[16:9],dob[7:0]} =     b_out[width_b-1:0] ;
               18: dob[17:0]          =     b_out[width_b-1:0] ;
            endcase
        end
        else
            case(DATA_WIDTH_B)
               1: {dob[16:9],dob[7:0]} = {16{b_out_reg[width_b-1:0]}};
               2: {dob[16:9],dob[7:0]} = { 8{b_out_reg[width_b-1:0]}};
               4: {dob[16:9],dob[7:0]} = { 4{b_out_reg[width_b-1:0]}};
               8: {dob[16:9],dob[7:0]} = { 2{b_out_reg[width_b-1:0]}};
               9: {dob[17:9],dob[8:0]} = { 2{b_out_reg[width_b-1:0]}};
               16:{dob[16:9],dob[7:0]} =     b_out_reg[width_b-1:0] ;
               18: dob[17:0]          =     b_out_reg[width_b-1:0] ;
            endcase
    end
end

endgenerate
assign DOA = doa;
assign DOB = dob;

// synthesis translate_on
endmodule
