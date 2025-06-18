/*-----------------------------------------------------------------------------
* DATA_BUFFER_TB.v
*
* Test bench for DATA_BUFFER.v
*
* Version: 1.01
* Author : AUDIY
* Date   : 2025/06/19
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

module DATA_BUFFER_TB();

    /* Register/Wire Definition for Test bench */
    reg  MCLK_I = 1'b1;
    wire BCK_I;
    wire LRCK_I;
    wire signed [31:0] PCM_O;
    reg NRST_I = 1'b1;

    integer fp;
    integer rp;

    reg signed [31:0] DATAREG  = {32{1'b0}};
    reg        [8:0]  MCLK_CNT = {9{1'b0}};

    reg signed [31:0] PCM_I = {32{1'b0}};

    /* DATA_BUFFER module (EUT) */
    DATA_BUFFER #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32),
        .OUTPUT_REG("TRUE")
    ) u_DATA_BUFFER(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WDATA_I(PCM_I),
        .RDATA_O(PCM_O)
    );

    /* Test bench */
    initial begin
        $dumpfile("DATA_BUFFER_TB.vcd");
        $dumpvars(0, DATA_BUFFER_TB);

        if (fp != 0) begin
            $fclose(fp);
        end

        fp = $fopen("./PCM_1kHz_44100fs_32bit.txt", "r");

        if (fp == 0) begin
            $display("ERROR: The file doesn't exist.");
            $finish(0);
        end

        #400000 $finish;
    end

    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    //always begin
        /* Note: Reset-Test is NOT performed. */
        //#140000 NRST_I <= 1'b0;
        //#512  NRST_I <= 1'b1;
    //end

    always @ (posedge MCLK_I) begin
        MCLK_CNT <= MCLK_CNT + 1'b1;
    end

    assign BCK_I  = MCLK_CNT[2];
    assign LRCK_I = MCLK_CNT[8];

    always @ (posedge LRCK_I) begin
        rp = $fscanf(fp, "%d\n", DATAREG);
    end

    always @ (negedge LRCK_I) begin
        PCM_I <= DATAREG;
    end


endmodule
