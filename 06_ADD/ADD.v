/*-----------------------------------------------------------------------------
* ADD.v
*
* Multiplied Data Integrator w/ input & output register.
*
* Version: 1.11
* Author : AUDIY
* Date   : 2025/06/23
*
* Port
*   Input
*       MCLK_I     : Master Clock Input
*       LRCKx2_I   : Oversampled LRCK input
*       BCKx2_I    : Oversampled BCK input, Added 2023/09/03
*       MULT_I     : Multiplied Data Input
*       NRST_I     : Reset Input (Active Low)
*
*   Output
*       DATA_O     : Integrated Data Output
*       LRCKx2_O   : Oversampled LRCK Output (w/ delay)
*       BCKx2_O    : Oversampled BCK Output (w/ delay), Added 2023/09/03
*
* Parameter
*       MULT_WIDTH     : Multiplied Data input bitwise.
*       FIR_ADDR_WIDTH : Integration bitwise.
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

module ADD #(
    /* Parameter Definition */
    parameter MULT_WIDTH = 48,
    parameter RAM_ADDR_WIDTH = 8
)
(
    /* Input Port Definition */
    input  wire                         MCLK_I,
    input  wire                         BCKx2_I,
    input  wire                         LRCKx2_I,
    input  wire signed [MULT_WIDTH-1:0] MULT_I,
    input  wire                         NRST_I,

    /* Output Port Definition */
    output wire signed [MULT_WIDTH-1:0] ADD_O,
    output wire                         LRCKx2_O,
    output wire                         BCKx2_O
);

    /* Internal Wire/Register Definition */
    reg  signed [MULT_WIDTH-1:0] MULT_REG   = {MULT_WIDTH{1'b0}};
    reg  signed [MULT_WIDTH-1:0] ADD_REG    = {MULT_WIDTH{1'b0}};
    reg  signed [MULT_WIDTH-1:0] ADDO_REG   = {MULT_WIDTH{1'b0}};
    reg                          LRCKx2_REG = 1'b0;
    reg                          BCKx2_REG  = 1'b0;

    /* RTL */
    always @ (posedge MCLK_I) begin
        MULT_REG  <= MULT_I;
        LRCKx2_REG <= LRCKx2_I;
        BCKx2_REG  <= (RAM_ADDR_WIDTH >= 7) ? BCKx2_I : 1'b0;

        if (~LRCKx2_I & LRCKx2_REG == 1'b1) begin
            /* Negedge of LRCKx2: Reset Adder. */
            ADD_REG <= (NRST_I == 1'b1) ? MULT_REG : {MULT_WIDTH{1'b0}};
            ADDO_REG <= (NRST_I == 1'b1) ? ADD_REG : {MULT_WIDTH{1'b0}};
        end else begin
            /* Normal Operation */
            ADD_REG <= (NRST_I == 1'b1) ? (ADD_REG + MULT_REG) : {MULT_WIDTH{1'b0}};
        end
    end

    /* Output Assign */
    assign ADD_O    = ADDO_REG;
    assign LRCKx2_O = LRCKx2_REG;
    assign BCKx2_O  = (RAM_ADDR_WIDTH >= 7) ? BCKx2_REG : MCLK_I;

endmodule

`default_nettype wire
