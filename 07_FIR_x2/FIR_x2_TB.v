/*-----------------------------------------------------------------------------
* FIR_x2_TB.v
*
* Test Bench for FIR_x2.v
*
* Version: 0.16
* Author : AUDIY
* Date   : 2023/12/23
*
* License
--------------------------------------------------------------------------------
| Copyright AUDIY 2023 - 2025.                                                 |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-W v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl).                    |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.  |
|                                                                              |
| Source location: https://github.com/AUDIY/FIR_x2                             |
|                                                                              |
| As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these |
| sources, You must maintain the Source Location visible on the external case  |
| of the FIR_x2 or other products you make using this source.                  |
--------------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/

`timescale 1 ns / 1 ps

module FIR_x2_TB();

    localparam DATA_WIDTH = 32;

    reg                          MCLK_I = 1'b1;
    wire                         BCK_I;
    wire                         LRCK_I;
    reg                          NRST_I = 1'b1;
    reg  signed [DATA_WIDTH-1:0] DATA_I = {{1'b0}};

    reg  signed [DATA_WIDTH-1:0] DATAREG = {DATA_WIDTH{1'b0}};
    reg  signed [DATA_WIDTH-1:0] PCM_I   = {DATA_WIDTH{1'b0}};

    wire                         BCKx2_O;
    wire                         LRCKx2_O;
    wire signed [DATA_WIDTH-1:0] DATA_O;

    integer                      fp;
    integer                      rp;
    reg         [8:0]            MCLK_CNT = {9{1'b0}};

    FIR_x2 u_FIR_x2(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .DATA_I(PCM_I),
        .BCKx2_O(BCKx2_O),
        .LRCKx2_O(LRCKx2_O),
        .DATA_O(DATA_O)
    );
    defparam u_FIR_x2.DATA_WIDTH  = DATA_WIDTH;
    defparam u_FIR_x2.COEF_WIDTH  = 16;
    defparam u_FIR_x2.WADDR_WIDTH = 8;
    defparam u_FIR_x2.COEF_INIT   = "FIR512_x2_48000.hex";

    initial begin
        if (fp != 0) begin
            $fclose(fp);
        end

        //fp = $fopen("./Impulse_44100Hz_32bit.txt", "r");
        fp = $fopen("./PCM_1kHz_44100fs_32bit.txt", "r");

        if (fp == 0) begin
            $display("ERROR: The file doesn't exist.");
            $finish(0);
        end
    end

    always begin
        #1 MCLK_I <= ~MCLK_I;
    end
    /*
    always begin
        #400000 NRST_I <= 1'b0;
        #400000 NRST_I <= 1'b1;
    end
    */

    always @ (negedge MCLK_I) begin
        MCLK_CNT <= MCLK_CNT + 1'b1;
    end

    assign BCK_I  = MCLK_CNT[2];
    assign LRCK_I = MCLK_CNT[8];

    always @ (posedge LRCK_I) begin
        rp = $fscanf(fp, "%d\n", DATAREG);
    end

    always @ (negedge LRCK_I) begin
        PCM_I <= (NRST_I == 1'b0) ? {DATA_WIDTH{1'b0}} : DATAREG;
    end

endmodule
