/*-----------------------------------------------------------------------------
* ADD.v
*
* Multiplied Data Integrator w/ input & output register.
*
* Version: 0.15
* Author : AUDIY
* Date   : 2023/12/03
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
    reg  signed [MULT_WIDTH-1:0] MULT_p1   = {MULT_WIDTH{1'b0}};
    reg  signed [MULT_WIDTH-1:0] ADD_p1    = {MULT_WIDTH{1'b0}};
    reg  signed [MULT_WIDTH-1:0] ADDO_p1   = {MULT_WIDTH{1'b0}};
    reg  signed [MULT_WIDTH-1:0] ADDO_n1   = {MULT_WIDTH{1'b0}};
    reg                          LRCKx2_p1 = 1'b0;
    reg                          LRCKx2_n1 = 1'b0;
    reg                          BCKx2_p1  = 1'b0;
    reg                          BCKx2_n1  = 1'b0;
    reg                          NRST_p1   = 1'b1;

    /* RTL */
    always @ (posedge MCLK_I) begin
        MULT_p1   <= MULT_I;
        LRCKx2_p1 <= LRCKx2_I;
        BCKx2_p1  <= (RAM_ADDR_WIDTH >= 7) ? BCKx2_I : 1'b0; // Change BCKx2 input (2023/11/26)

        if (~LRCKx2_I & LRCKx2_p1 == 1'b1) begin
            /* Update Reset Status. */
            NRST_p1 <= NRST_I;

            /* Negedge of LRCKx2: Reset Adder. */
            ADD_p1  <= (NRST_p1 == 1'b1) ? MULT_p1 : {MULT_WIDTH{1'b0}};
            ADDO_p1 <= (NRST_p1 == 1'b1) ? ADD_p1  : {MULT_WIDTH{1'b0}};
        end else begin
            /* Normal Operation */
            ADD_p1 <= (NRST_p1 == 1'b1) ? (ADD_p1 + MULT_p1) : {MULT_WIDTH{1'b0}};
        end
    end

    always @ (negedge MCLK_I) begin
        /* Output Data synchronize with negedge of MCLK_I */
        ADDO_n1   <= (NRST_p1 == 1'b1) ? ADDO_p1 : {MULT_WIDTH{1'b0}};
        LRCKx2_n1 <= LRCKx2_p1;
        BCKx2_n1  <= (RAM_ADDR_WIDTH >= 7) ? BCKx2_p1 : 1'b0;  // Change BCKx2 input (2023/11/26)
    end

    /* Output Assign */
    assign ADD_O    = ADDO_n1;
    assign LRCKx2_O = LRCKx2_n1;
    assign BCKx2_O  = (RAM_ADDR_WIDTH >= 7) ? BCKx2_n1 : MCLK_I; // Change BCKx2 Output (2023/11/26)

endmodule