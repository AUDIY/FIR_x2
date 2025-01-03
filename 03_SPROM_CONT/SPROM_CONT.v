/*-----------------------------------------------------------------------------
* SPROM_CONT.v
*
* Single Port ROM Controller to Output Filter Coefficients.
*
* Version: 0.18
* Author : AUDIY
* Date   : 2023/12/23
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
    output wire                      LRCKx_O, // Added 2023/08/12
    output wire                      BCKx_O   // Added 2023/09/03
);

    /* Internal Wire/Register Definition */
    reg BCK_REG_P  = 1'b0;
    reg BCK_REG_N  = 1'b0;
    reg LRCK_REG_P = 1'b0;
    reg LRCK_REG_N = 1'b0;

    reg WEN_REG_P = 1'b0;
    reg WEN_REG_N = 1'b0;

    reg NRST_REG_P = 1'b1;

    reg [ROM_ADDR_WIDTH-1:0] CADDR_REG = {ROM_ADDR_WIDTH{1'b0}};

    reg [ROM_ADDR_WIDTH-1:0] CADDR_REG_P = {ROM_ADDR_WIDTH{1'b0}};
    reg [ROM_ADDR_WIDTH-1:0] CADDR_REG_N = {ROM_ADDR_WIDTH{1'b0}};
    reg                      LRCKx_REG_P = 1'b0;
    reg                      LRCKx_REG_N = 1'b0;
    reg                      BCKx_REG_P  = 1'b0;
    reg                      BCKx_REG_N  = 1'b0;

    /* RTL */
    always @ (posedge MCLK_I) begin
        /* Read BCK & LRCK */
        BCK_REG_P  <= BCK_I;
        LRCK_REG_P <= LRCK_I;

        /* Synthesize NRST_I */
        NRST_REG_P <= NRST_I;

        /* Judge Write Enable */
        WEN_REG_P <= LRCK_I & ~LRCK_REG_N;

        /* Output Pipeline with positive edge. (2023/11/08) */
        CADDR_REG_P <= {ROM_ADDR_WIDTH{1'b1}} - CADDR_REG;
        LRCKx_REG_P <= CADDR_REG[ROM_ADDR_WIDTH-1];
        BCKx_REG_P  <= (ROM_ADDR_WIDTH >= 8) ? CADDR_REG[ROM_ADDR_WIDTH-7] : 1'b0;
    end

    always @ (negedge MCLK_I) begin
        /* 1 MCLK cycle Delay */
        BCK_REG_N  <= BCK_REG_P;
        LRCK_REG_N <= LRCK_REG_P;

        /* Update Adress */
        if (WEN_REG_P == 1'b1) begin
            /* Change Initial Address (2023/11/25) */
            CADDR_REG <= {ROM_ADDR_WIDTH{1'b0}} + 1'b1;
        end else begin
            /* Jump Address */
            // LRCK_REG_N == 1'b1: Odd Address.
            // LRCK_REG_N == 1'b0: Even Address.
            /* Change Odd & Even (2023/11/25) */
            CADDR_REG <= {(CADDR_REG[ROM_ADDR_WIDTH-1:1] + 1'b1), LRCK_REG_P};
        end

        WEN_REG_N <= WEN_REG_P;

        /* Output Pipeline with negative edge. (2023/11/08) */
        CADDR_REG_N <= CADDR_REG_P;
        LRCKx_REG_N <= LRCKx_REG_P;
        BCKx_REG_N  <= BCKx_REG_P;
    end

    /* Output Assign (Changed 2023/11/08) */
    assign CADDR_O = CADDR_REG_N;
    assign LRCKx_O = LRCKx_REG_N;
    assign BCKx_O  = (ROM_ADDR_WIDTH >= 7) ? BCKx_REG_N : MCLK_I; // Change BCK Generation (2023/11/26)

endmodule
