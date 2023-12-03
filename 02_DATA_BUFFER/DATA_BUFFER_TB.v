/*-----------------------------------------------------------------------------
* DATA_BUFFER_TB.v
*
* Test bench for DATA_BUFFER.v
*
* Version: 0.11
* Author : AUDIY
* Date   : 2023/12/03
*
* License
--------------------------------------------------------------------------------
| Copyright AUDIY 2023.                                                        |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-S v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).         |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.  |
|                                                                              |
| Source location: https://github.com/AUDIY/FIR_x2                             |
|                                                                              |
| As per CERN-OHL-S v2 section 4, should You produce hardware based on this    |
| source, You must where practicable maintain the Source Location visible      |
| on the external case of the Gizmo or other products you make using this      |
| source.                                                                      |
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
    DATA_BUFFER u_DATA_BUFFER(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WDATA_I(PCM_I),
        .RDATA_O(PCM_O)
    );
    defparam u_DATA_BUFFER.ADDR_WIDTH = 8;
    defparam u_DATA_BUFFER.DATA_WIDTH = 32;
    defparam u_DATA_BUFFER.OUTPUT_REG = "TRUE";

    /* Test bench */
    initial begin
        if (fp != 0) begin
            $fclose(fp);
        end

        fp = $fopen("./PCM_1kHz_44100fs_32bit.txt", "r");

        if (fp == 0) begin
            $display("ERROR: The file doesn't exist.");
            $finish(0);
        end
    end

    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    always begin
        #4998 NRST_I <= 1'b0;
        #5    NRST_I <= 1'b1;
    end

    always @ (negedge MCLK_I) begin
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