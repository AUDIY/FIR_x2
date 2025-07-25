/*-----------------------------------------------------------------------------
* DPRAM_CONT_TB.v
*
* Test Bench for DPRAM_CONT.v
*
* Version: 1.11
* Author : AUDIY
* Date   : 2025/06/23
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

module DPRAM_CONT_TB();

    /* Parameter Definition */
    parameter ADDR_WIDTH = 8;

    /* Register/Wire Definition for Test bench */
    reg  MCLK_I = 1'b0;
    wire BCK_I;
    wire LRCK_I;
    reg  NRST_I = 1'b1;

    wire WEN_O;
    wire [ADDR_WIDTH-1:0] WADDR_O;
    wire [ADDR_WIDTH-1:0] RADDR_O;
    wire REN_O;

    reg [8:0] MCLK_REG = {9{1'b0}};

    /* DPRAM_CONT module (EUT) */
    DPRAM_CONT #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u1 (
        .MCLK_I(MCLK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WEN_O(WEN_O),
        .WADDR_O(WADDR_O),
        .REN_O(REN_O),
        .RADDR_O(RADDR_O)
    );

    /* Test bench */
    initial begin
        $dumpfile("DPRAM_CONT_TB.vcd");
        $dumpvars(0, DPRAM_CONT_TB);

        #400000 $finish;

    end

    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    always @ (posedge MCLK_I) begin
        MCLK_REG <= MCLK_REG + 1'b1;
    end

    assign BCK_I  = MCLK_REG[2];
    assign LRCK_I = MCLK_REG[8];

    always begin
        #4989 NRST_I <= 1'b0;
        #512  NRST_I <= 1'b1;
    end

endmodule

`default_nettype wire
