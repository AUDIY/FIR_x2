/*-----------------------------------------------------------------------------
* FIR_COEF_TB.v
* 
* Test Bench for FIR_COEF.v
*
* Version: 2.00
* Author : AUDIY
* Date   : 2025/08/27
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

module FIR_COEF_TB();

    /* Parameter Definition */
    localparam DATA_WIDTH    = 16;
    localparam ADDR_WIDTH    = 9;
    localparam OUTPUT_REG    = "TRUE";
    localparam RAM_INIT_FILE = "FIR512_x2_48000.hex";
    
    /* Register/Wire Definition for Test bench */
    reg  MCLK_I = 1'b1;
    wire BCK_I;
    wire LRCK_I;
    reg  NRST_I = 1'b1;

    wire signed [DATA_WIDTH-1:0] COEF_O;
    wire                         LRCKx2_O;
    wire                         BCKx2_O;

    reg [8:0] MCLK_REG = {9{1'b0}};

    /* FIR_COEF module (EUT) */
    FIR_COEF #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .RAM_INIT_FILE(RAM_INIT_FILE)
    ) u_FIR_COEF(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .COEF_O(COEF_O),
        .LRCKx2_O(LRCKx2_O),
        .BCKx2_O(BCKx2_O)
    );

    initial begin
        $dumpfile("FIR_COEF_TB.vcd");
        $dumpvars(0, FIR_COEF_TB);

        #400000 $finish;
    end

    /* Generate Master Clock */
    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    always @ (posedge MCLK_I) begin
        MCLK_REG <= MCLK_REG + 1'b1;
    end

    /* Generate BCK & LRCK */
    assign BCK_I  = MCLK_REG[2];
    assign LRCK_I = MCLK_REG[8];

    
    always begin
        #4989 NRST_I <= 1'b0;
        #5    NRST_I <= 1'b1;
    end

endmodule

`default_nettype wire
