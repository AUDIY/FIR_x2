/*-----------------------------------------------------------------------------
* FIR_COEF.v
*
* FIR Coefficients ROM.
*
* Version: 1.01
* Author : AUDIY
* Date   : 2025/06/21
*
* Port
*   Input
*       MCLK_I       : Master Clock Input
*       BCK_I        : Bit Clock Input
*       LRCK_I       : LR Clock Input
*       NRST_I       : Reset Input (Active Low)
*
*   Output
*       COEF_O       : FIR Filter Coefficient Output
*       LRCKx2_O     : x2 LRCK Output (Added 2023/08/12)
*       BCKx2_O      : x2 BCK Output (Added 2023/09/03)
*
* Parameter
*       DATA_WITDH   : Coefficient DATA Width
*       ADDR_WIDTH   : ROM Address Width
*       OUTPUT_REG   : Output Register Enable
*       RAM_INIT_FILE: ROM Initialization File
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
module FIR_COEF #(
    /* Parameter Definition */
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 9,
    parameter OUTPUT_REG = "TRUE",
    parameter RAM_INIT_FILE = "FIR512_x2_48000.inithex"
)
(
    /* Input Port Definition */
    input  wire                         MCLK_I,
    input  wire                         BCK_I,
    input  wire                         LRCK_I,
    input  wire                         NRST_I,

    /* Output Port Definition */
    output wire signed [DATA_WIDTH-1:0] COEF_O,
    output wire                         LRCKx2_O, // Add 2023/08/12
    output wire                         BCKx2_O  // Add 2023/09/03
);

    /* Internal Register/Wire Definition */
    wire                  LRCKx_O;
    reg                   LRCKx2_p1 = 1'b1; // Add 2023/08/12
    reg                   LRCKx2_p2 = 1'b1; // Add 2023/08/12
    wire                  BCKx_O;
    reg                   BCKx2_p1  = 1'b1; // Add 2023/09/03
    reg                   BCKx2_p2  = 1'b1; // Add 2023/09/03
    wire [ADDR_WIDTH-1:0] CADDR;
    

    /* Single Port ROM Controller */
    SPROM_CONT #(
        .ROM_ADDR_WIDTH(ADDR_WIDTH)
    ) u_SPROM_CONT(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .CADDR_O(CADDR),
        .LRCKx_O(LRCKx_O),
        .BCKx_O(BCKx_O)
    );

    /* Single Port ROM */
    SPROM #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .ROM_INIT_FILE(RAM_INIT_FILE)
    ) u_SPROM(
        .CLK_I(MCLK_I),
        .RADDR_I(CADDR),
        .RDATA_O(COEF_O)
    );

    /* Add LRCKx_O Output Register, 2023/08/12 */
    always @ (posedge MCLK_I) begin
        LRCKx2_p1 <= LRCKx_O;
        LRCKx2_p2 <= LRCKx2_p1;

        /* Add BCKx_O Output Register, 2023/09/03 */
        BCKx2_p1  <= (ADDR_WIDTH >= 8) ? BCKx_O : 1'b0; // Change BCKx2 Generation (2023/11/26)
        BCKx2_p2  <= BCKx2_p1; 
    end

    generate
        if (OUTPUT_REG == "TRUE") begin : gen_regtrue
            assign LRCKx2_O = LRCKx2_p2;
            assign BCKx2_O  = (ADDR_WIDTH >= 8) ? BCKx2_p2 : MCLK_I; // Change BCKx2_O Generation (2023/11/26)
        end else begin : gen_regfalse
            assign LRCKx2_O = LRCKx2_p1;
            assign BCKx2_O  = (ADDR_WIDTH >= 8) ? BCKx2_p1 : MCLK_I; // Change BCKx2_O Generation (2023/11/26)
        end
    endgenerate

endmodule
