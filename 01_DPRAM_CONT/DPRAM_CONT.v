/*-----------------------------------------------------------------------------
* DPRAM_CONT.v
*
* Simple Dual Port RAM Controller to operate as Ring-Buffer.
*
* Version: 2.00
* Author : AUDIY
* Date   : 2025/08/27
*
* Port
*   Input
*       MCLK_I     : Master Clock Input
*       BCK_I      : Bit CLock Input
*       LRCK_I     : LR Clock Input
*       NRST_I     : Reset Input (Active Low)
*
*   Output
*       WEN_O      : Write Enable Output
*       REN_O      : Read Enable Output
*       WADDR_O    : Write Address Output
*       RADDR_O    : Read Address Output
*
* Parameter
*       ADDR_WIDTH : Address Width, Default: 8 (255 - 0)
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

module DPRAM_CONT #(
    /* Parameter Definition*/
    parameter ADDR_WIDTH = 8 // Default: 8bits (255 - 0s)
)(
    /* Input Definition */
    input  wire MCLK_I,
    input  wire LRCK_I,
    input  wire NRST_I, // Active Low.

    /* Output Definition */
    output wire WEN_O,
    output wire [ADDR_WIDTH-1:0] WADDR_O,
    output wire REN_O,
    output wire [ADDR_WIDTH-1:0] RADDR_O
);

    /* Internal Wire/Register Definition */
    reg LRCK_REG = 1'b0;
    reg WEN_REG  = 1'b0;

    reg [ADDR_WIDTH-1:0] WADDR_REG = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] RADDR_REG = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] ADDR_PTR  = {ADDR_WIDTH{1'b0}};

    /* RTL */
    always @ (posedge MCLK_I) begin
        /* Read LRCK */
        LRCK_REG <= LRCK_I;

        /* Update Address. */
        if (NRST_I == 1'b0) begin
            /* Reset Opearation.
               Update Address for Initializing RAM Data.*/
            WADDR_REG <= RADDR_REG;
            RADDR_REG <= RADDR_REG + 1'b1;
            
            WEN_REG   <= 1'b1; // Enable WEN_O while Reset.
        end else begin
            /* Normal Operation */
            if ((LRCK_I & ~LRCK_REG) == 1'b1) begin
                /* When Write Enable */
                ADDR_PTR  <= ADDR_PTR + 1'b1;  // Update the Head of Address.
                WADDR_REG <= ADDR_PTR;         // Update Write Address.
                RADDR_REG <= ADDR_PTR + 1'b1;  // Update Read Address.
            end else begin
                RADDR_REG <= RADDR_REG + 1'b1; // Update Only Read Address.
            end 

            WEN_REG   <= LRCK_I & ~LRCK_REG;
        end
    end

    /* Output Assign */
    // Assertion #0: REN_O must be 1'b1
    // psl assert always (REN_O == 1'b1) @ (posedge MCLK_I);
    assign REN_O       = ~(WEN_REG & (WADDR_REG == RADDR_REG));

    // Assertion #1: WEN_O must be 1'b0 when WADDR_O equals to RADDR_O.
    // psl assert always ((WADDR_O == RADDR_O) -> (WEN_O == 1'b0)) @ (posedge MCLK_I);
    assign WEN_O       = WEN_REG;

    // Assertion #2: RADDR_O must be equals to (WADDR_O + 1'b1) if WEN_REG_P is 1'b1
    // psl assert always ((WEN_O == 1'b1) -> (RADDR_O == WADDR_O + 1'b1)) @ (posedge MCLK_I);
    assign WADDR_O     = WADDR_REG;
    assign RADDR_O     = RADDR_REG;

endmodule

`default_nettype wire
