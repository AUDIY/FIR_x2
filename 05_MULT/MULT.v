/*-----------------------------------------------------------------------------
* MULT.v
*
* PCM DATA & Digital Filter Multiplier w/ input & output register.
*
* Version: 0.15
* Author : AUDIY
* Date   : 2023/12/23
*
* Port
*   Input
*       MCLK_I     : Master Clock Input
*       DATA_I     : PCM Data Input
*       COEF_I     : Filter Coefficient Input
*       LRCKx2_I   : Oversampled LRCK input
*       BCKx2_I    : Oversampled BCK input, Added 2023/09/03
*       NRST_I     : Reset Input (Active Low)
*
*   Output
*       DATA_O     : Multiplied Data Output
*       LRCKx2_O   : Oversampled LRCK Output (w/ delay)
*       BCKx2_O    : Oversampled BCK Output (w/ delay), Added 2023/09/03
*
* Parameter
*       DATA_WIDTH : PCM Data input bitwise.
*       COEF_WIDTH : Coefficient bitwise.
*
* License
--------------------------------------------------------------------------------
| Copyright AUDIY 2023.                                                        |
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

module MULT #(
    /* Parameter Definition */
    parameter DATA_WIDTH = 32,
    parameter COEF_WIDTH = 16,
    parameter ROM_ADDR_WIDTH = 9 // Add parameter to judge BCK Output (2023/11/26)
)
(
    /* Input Port Definition */
    input  wire                                    MCLK_I,
    input  wire signed [DATA_WIDTH-1:0]            DATA_I,
    input  wire signed [COEF_WIDTH-1:0]            COEF_I,
    input  wire                                    LRCKx2_I,
    input  wire                                    BCKx2_I,
    input  wire                                    NRST_I,

    /* Output Port Definition */
    output wire signed [DATA_WIDTH+COEF_WIDTH-1:0] DATA_O,
    output wire                                    LRCKx2_O,
    output wire                                    BCKx2_O
);

    /* Internal Wire/Register Definition */
    reg  LRCKx2_p1 = 1'b0;
    reg  LRCKx2_p2 = 1'b0;
    reg  BCKx2_p1  = 1'b0;
    reg  BCKx2_p2  = 1'b0;
    reg  signed [DATA_WIDTH-1:0]            DATAI_p1 = {DATA_WIDTH{1'b0}};
    reg  signed [COEF_WIDTH-1:0]            COEF_p1  = {COEF_WIDTH{1'b0}};
    reg  signed [DATA_WIDTH+COEF_WIDTH-1:0] DATAO_p1 = {(DATA_WIDTH+COEF_WIDTH){1'b0}};

    wire signed [DATA_WIDTH+COEF_WIDTH-1:0] MULT_WIRE; 

    /* RTL */
    always @ (posedge MCLK_I) begin
        LRCKx2_p1 <= LRCKx2_I;
        LRCKx2_p2 <= LRCKx2_p1;
        BCKx2_p1  <= (ROM_ADDR_WIDTH >= 8) ? BCKx2_I : 1'b0; // Change BCKx2 Input (2023/11/26)
        BCKx2_p2  <= (ROM_ADDR_WIDTH >= 8) ? BCKx2_p1 : 1'b0; // Change BCKx2 Input (2023/11/26)
        DATAI_p1  <= DATA_I;
        COEF_p1   <= COEF_I;
        DATAO_p1  <= (NRST_I == 1'b0) ? {(DATA_WIDTH+COEF_WIDTH){1'b0}} : MULT_WIRE;
    end

    // Note: Multiplier assign recommendation differs depends on FPGA vendor.
    //       Please check the HDL coding guideline of the target FPGA.
    assign MULT_WIRE = DATAI_p1 * COEF_p1;

    assign LRCKx2_O  = LRCKx2_p2;
    assign BCKx2_O   = (ROM_ADDR_WIDTH >= 8) ? BCKx2_p2 : MCLK_I; // Change BCKx2_O Output assignment (2023/11/26)
    assign DATA_O    = DATAO_p1;

endmodule
