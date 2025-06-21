/*-----------------------------------------------------------------------------
* FIR_x2.v
*
* Oversampling FIR Filter Module (Oversampling Ratio: x2)
*
* Version: 1.02
* Author : AUDIY
* Date   : 2025/06/22
*
* Port
*   Input
*       MCLK_I: Master Clock Input
*       BCK_I : Bit Clock Input
*       LRCK_I: LR Clock Input
*       NRST_I: Reset Input (Active Low)
*       DATA_I: PCM DATA Input
*
*   Output
*       BCKx2_O : Oversampled Bit Clock Output
*       LRCKx2_O: Oversampled LR Clock Output
*       DATA_O  : Oversampled PCM DATA Output
*
* Parameter
*   DATA_WIDTH : PCM Input DATA Width 
*   COEF_WIDTH : Filter Coefficient Bit Width
*   WADDR_WIDTH: PCM DATA RAM depth
*   COEF_INIT  : FIR Filter Coefficient Initialization File Name.
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

module FIR_x2 #(
    /* Parameter Definition */
    parameter DATA_WIDTH  = 32,
    parameter COEF_WIDTH  = 16,
    parameter WADDR_WIDTH = 8,
    parameter COEF_INIT   = "FIR512.hex",
    parameter DATAO_WIDTH = 32
)
(
    /* Input Port Definition */
    input  wire                         MCLK_I,
    input  wire                         BCK_I,
    input  wire                         LRCK_I,
    input  wire                         NRST_I,
    input  wire signed [DATA_WIDTH-1:0] DATA_I,

    /* output Port Definition */
    output wire                         BCKx2_O, // Add 2023/09/03
    output wire                         LRCKx2_O,
    output wire signed [DATA_WIDTH-1:0] DATA_O
);
    
    /* localparam Definition */
    // Note: Changing these parameters may cause bugs.
    localparam RADDR_WIDTH = WADDR_WIDTH + 1;
    localparam MULT_WIDTH  = DATA_WIDTH + COEF_WIDTH;
    localparam OUTPUT_REG  = "TRUE";
    localparam BUFF_INIT   = "BUFFER_INIT.hex";

    /* Internal Register/Wire Definition */
    wire                         BCKx2_COEF;
    wire                         BCKx2_MULT;
    wire signed [DATA_WIDTH-1:0] RDATA;
    wire signed [COEF_WIDTH-1:0] COEF;
    wire                         LRCKx2_COEF;
    wire                         LRCKx2_MULT;
    wire signed [MULT_WIDTH-1:0] MULT_DATA;
    wire signed [MULT_WIDTH-1:0] ADD_DATA;
    wire                         DUMMY_NRST;

    assign DUMMY_NRST = 1'b1;

    wire                        BCKx2O_wire;
    wire                        LRCKx2O_wire;
    reg                         BCKx2O_REG  = 1'b0;
    reg                         LRCKx2O_REG = 1'b0;
    reg signed [DATA_WIDTH-1:0] DATAO_REG   = {DATA_WIDTH{1'b0}};
    

    /* DATA_BUFFER module */
    // PCM DATA RAM
    DATA_BUFFER #(
        .ADDR_WIDTH(WADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .RAM_INIT_FILE(BUFF_INIT)
    ) u_DATA_BUFFER (
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WDATA_I(DATA_I),
        .RDATA_O(RDATA)
    );

    /* FIR COEF module */
    // FIR filter Coefficients ROM
    FIR_COEF #(
        .DATA_WIDTH(COEF_WIDTH),
        .ADDR_WIDTH(RADDR_WIDTH),
        .OUTPUT_REG(OUTPUT_REG),
        .RAM_INIT_FILE(COEF_INIT)
    ) u_FIR_COEF (
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(DUMMY_NRST),
        .COEF_O(COEF),
        .LRCKx2_O(LRCKx2_COEF),
        .BCKx2_O(BCKx2_COEF)
    );

    /* MULT module */
    // DATA & Coefficient Multiplier
    MULT #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH)
    ) u_MULT (
        .MCLK_I(MCLK_I),
        .DATA_I(RDATA),
        .COEF_I(COEF),
        .LRCKx2_I(LRCKx2_COEF),
        .BCKx2_I(BCKx2_COEF),
        .NRST_I(NRST_I),
        .DATA_O(MULT_DATA),
        .LRCKx2_O(LRCKx2_MULT),
        .BCKx2_O(BCKx2_MULT)
    );

    /* ADD module */
    // Filtered DATA Integrator
    ADD #(
        .MULT_WIDTH(MULT_WIDTH),
        .RAM_ADDR_WIDTH(WADDR_WIDTH)
    ) u_ADD (
        .MCLK_I(MCLK_I),
        .LRCKx2_I(LRCKx2_MULT),
        .BCKx2_I(BCKx2_MULT),
        .MULT_I(MULT_DATA),
        .NRST_I(NRST_I),
        .ADD_O(ADD_DATA),
        .LRCKx2_O(LRCKx2O_wire),
        .BCKx2_O(BCKx2O_wire)
    );

    /* Pipeline (Add 2023/11/08) */
    always @ (posedge MCLK_I) begin
        BCKx2O_REG  <= BCKx2O_wire;
        LRCKx2O_REG <= LRCKx2O_wire;
        DATAO_REG   <= (ADD_DATA[MULT_WIDTH-2] == ADD_DATA[MULT_WIDTH-3]) ? ADD_DATA[MULT_WIDTH-3:MULT_WIDTH-3-(DATAO_WIDTH-1)] : {ADD_DATA[MULT_WIDTH-2], {(DATAO_WIDTH-1){ADD_DATA[MULT_WIDTH-3]}}};
    end

    /* Output Assign */
    assign BCKx2_O  = (WADDR_WIDTH >= 7) ? BCKx2O_REG : MCLK_I; // Change BCK Output (2023/11/26)
    assign LRCKx2_O = LRCKx2O_REG;
    assign DATA_O   = DATAO_REG;
    
endmodule

`default_nettype wire
