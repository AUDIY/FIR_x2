/*-----------------------------------------------------------------------------
* DPRAM_CONT_TB.v
*
* Test Bench for DPRAM_CONT.v
*
* Version: 0.22
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
    wire NERR_ADDR_O;

    reg [8:0] MCLK_REG = {9{1'b0}};

    /* DPRAM_CONT module (EUT) */
    DPRAM_CONT u1(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WEN_O(WEN_O),
        .WADDR_O(WADDR_O),
        .RADDR_O(RADDR_O),
        .NERR_ADDR_O(NERR_ADDR_O)
    );
    defparam u1.ADDR_WIDTH = ADDR_WIDTH;

    /* Test bench */
    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    always @ (negedge MCLK_I) begin
        MCLK_REG <= MCLK_REG + 1'b1;
    end

    assign BCK_I  = MCLK_REG[2];
    assign LRCK_I = MCLK_REG[8];

    always begin
        #4989 NRST_I <= 1'b0;
        #512  NRST_I <= 1'b1;
    end

endmodule