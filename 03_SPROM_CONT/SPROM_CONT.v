/*-----------------------------------------------------------------------------
* SPROM_CONT.v
*
* Single Port ROM Controller to Output Filter Coefficients.
*
* Version: 2.00
* Author : AUDIY
* Date   : 2025/08/27
*
* Port
*   Input
*       MCLK_I        : Master Clock Input
*       BCK_I         : Bit CLock Input
*       LRCK_I        : LR Clock Input
*       NRST_I        : Reset Input (Active Low)
*
*   Output
*       CADDR_O       : Coefficient Address Output
*       LRCKx_O       : Oversampled LRCK Output
*       BCKx_O        : Oversampled BCK Output
*
*   Parameter
*       ROM_ADDR_WIDTH:  Address Width, Default: 9 (511 - 0)
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

module SPROM_CONT #(
    /* Parameter Definition */
    parameter ROM_ADDR_WIDTH = 9 // Default: 9bits (511 - 0)
)
(
    /* Input Definition */
    input  wire MCLK_I,
    input  wire BCK_I,
    input  wire LRCK_I,
    input  wire NRST_I, // Active Low

    /* Output Definition */
    output wire [ROM_ADDR_WIDTH-1:0] CADDR_O,
    output wire                      LRCKx_O,
    output wire                      BCKx_O
);

    /* Internal Wire/Register Definition */
    reg BCK_REG  = 1'b0;
    reg LRCK_REG = 1'b0;

    reg BCKx_REG  = 1'b1;
    reg LRCKx_REG = 1'b1;

    reg [ROM_ADDR_WIDTH-1:0] CADDR_REG  = {ROM_ADDR_WIDTH{1'b0}};
    reg [ROM_ADDR_WIDTH-1:0] CADDRO_REG = {ROM_ADDR_WIDTH{1'b0}};

    /* RTL */
    always @ (posedge MCLK_I) begin
        /* Read BCK & LRCK */
        BCK_REG  <= BCK_I;
        LRCK_REG <= LRCK_I;

        /* Update Address */
        if (LRCK_I & ~LRCK_REG == 1'b1) begin
            /* Change Initial Address */
            CADDR_REG <= {{(ROM_ADDR_WIDTH-1){1'b0}}, 1'b1};
        end else begin
            /* Change Odd & Even */
            CADDR_REG <= {(CADDR_REG[ROM_ADDR_WIDTH-1:1] + 1'b1), LRCK_I};
        end

        /* Output Pipeline with positive edge. */
        CADDRO_REG <= {ROM_ADDR_WIDTH{1'b1}} - CADDR_REG;
        LRCKx_REG  <= CADDR_REG[ROM_ADDR_WIDTH-1];
        BCKx_REG   <= (ROM_ADDR_WIDTH >= 8) ? CADDR_REG[ROM_ADDR_WIDTH-7] : 1'b0;
    end

    /* Output Assign */
    assign CADDR_O = CADDRO_REG;
    assign LRCKx_O = LRCKx_REG;
    assign BCKx_O  = (ROM_ADDR_WIDTH >= 7) ? BCKx_REG : MCLK_I; // Change BCK Generation

endmodule

`default_nettype wire
