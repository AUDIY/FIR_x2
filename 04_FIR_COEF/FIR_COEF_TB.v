/*-----------------------------------------------------------------------------
* FIR_COEF_TB.v
* 
* Test Bench for FIR_COEF.v
*
* Version: 0.14
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
    wire                         LRCKx2_O; // Add 2023/08/12
    wire                         BCKx2_O;  // Add 2023/09/03

    reg [8:0] MCLK_REG = {9{1'b0}};

    /* FOR_COEF module (EUT) */
    FIR_COEF u_FIR_COEF(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .COEF_O(COEF_O),
        .LRCKx2_O(LRCKx2_O), // Add 2023/08/12
        .BCKx2_O(BCKx2_O) // Add 2023/09/03
    );
    defparam u_FIR_COEF.DATA_WIDTH    = DATA_WIDTH;
    defparam u_FIR_COEF.ADDR_WIDTH    = ADDR_WIDTH;
    defparam u_FIR_COEF.OUTPUT_REG    = OUTPUT_REG;
    defparam u_FIR_COEF.RAM_INIT_FILE = RAM_INIT_FILE;

    /* Generate Master Clock */
    always begin
        #1 MCLK_I <= ~MCLK_I;
    end

    always @ (negedge MCLK_I) begin
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