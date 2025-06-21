/*-----------------------------------------------------------------------------
* ADD_TB.v
*
* Test Bench for ADD.v
*
* Version: 1.02
* Author : AUDIY
* Date   : 2025/06/22
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
`default_nettype none

`timescale 1 ns / 1 ps

module ADD_TB();

    /* Parameter Definition */
    localparam DATA_WIDTH  = 32;
    localparam COEF_WIDTH  = 16;
    localparam WADDR_WIDTH = 8;
    localparam RADDR_WIDTH = WADDR_WIDTH + 1;
    localparam OUTPUT_REG  = "TRUE";
    localparam COEF_INIT   = "FIR512_x2_48000.hex";
    localparam BUFF_INIT   = "BUFFER_INIT.hex";

    /* Register/Wire Definition for Test bench. */
    reg  MCLK_I = 1'b1;
    wire BCK_I;
    wire LRCK_I;
    reg  NRST_I = 1'b1;

    reg  signed [DATA_WIDTH-1:0] DATAREG = {DATA_WIDTH{1'b0}};
    reg  signed [DATA_WIDTH-1:0] PCM_I   = {DATA_WIDTH{1'b0}};
    wire signed [DATA_WIDTH-1:0] PCM_O;
    wire                         BCKx2_O;

    wire signed [COEF_WIDTH-1:0] COEF_O;
    wire signed [DATA_WIDTH+COEF_WIDTH-1:0] ADD_O;
    wire                         LRCKx2_1;
    wire                         LRCKx2_2;
    wire                         LRCKx2_O;
    wire                         BCKx2_COEF;
    wire                         BCKx2_MULT;

    integer fp;
    integer rp;
    reg [8:0] MCLK_CNT = {9{1'b0}};

    wire signed [DATA_WIDTH+COEF_WIDTH-1:0] MULT_O;

    /* DATA_BUFFER module */
    DATA_BUFFER #(
        .ADDR_WIDTH(WADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .RAM_INIT_FILE(BUFF_INIT)
    ) u_DATA_BUFFER(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WDATA_I(PCM_I),
        .RDATA_O(PCM_O)
    );

    /* FIR_COEF module */
    FIR_COEF #(
        .DATA_WIDTH(COEF_WIDTH),
        .ADDR_WIDTH(RADDR_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .RAM_INIT_FILE(COEF_INIT)
    ) u_FIR_COEF(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .COEF_O(COEF_O),
        .LRCKx2_O(LRCKx2_1),
        .BCKx2_O(BCKx2_COEF)
    );

    /* Multiplier */
    MULT #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH)
    ) u_MULT(
        .MCLK_I(MCLK_I),
        .DATA_I(PCM_O),
        .COEF_I(COEF_O),
        .LRCKx2_I(LRCKx2_1),
        .BCKx2_I(BCKx2_COEF),
        .NRST_I(NRST_I),
        .DATA_O(MULT_O),
        .LRCKx2_O(LRCKx2_2),
        .BCKx2_O(BCKx2_MULT)
    );

    /* Adder (EUT) */
    ADD #(
        .MULT_WIDTH(DATA_WIDTH+COEF_WIDTH),
        .RAM_ADDR_WIDTH(WADDR_WIDTH)
    ) u_ADD(
        .MCLK_I(MCLK_I),
        .BCKx2_I(BCKx2_MULT),
        .LRCKx2_I(LRCKx2_2),
        .MULT_I(MULT_O),
        .NRST_I(NRST_I),
        .ADD_O(ADD_O),
        .LRCKx2_O(LRCKx2_O),
        .BCKx2_O(BCKx2_O)
    );

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

        $dumpfile("ADD_TB.vcd");
        $dumpvars(0, ADD_TB);

        #400000 $finish;
    end

    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    /*
    always begin
        #4989 NRST_I <= 1'b0;
        #5    NRST_I <= 1'b1;
    end
    */

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

`default_nettype wire
