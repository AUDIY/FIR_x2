/*-----------------------------------------------------------------------------
* DPRAM_CONT.v
*
* Simple Dual Port RAM Controller to operate as Ring-Buffer.
*
* Version: 1.00
* Author : AUDIY
* Date   : 2025/01/20
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
*       WADDR_O    : Write Address Output
*       RADDR_O    : Read Address Output
*       NERR_ADDR_O: Address Error Output (Active Low)
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

module DPRAM_CONT #(
    /* Parameter Definition */
    parameter ADDR_WIDTH = 8 // Default: 8bits (255 - 0s)
)(
    /* Input Definition */
    input  wire MCLK_I,
    input  wire BCK_I,
    input  wire LRCK_I,
    input  wire NRST_I, // Active Low.

    /* Output Definition */
    output wire WEN_O,
    output wire [ADDR_WIDTH-1:0] WADDR_O,
    output wire [ADDR_WIDTH-1:0] RADDR_O,
    output wire NERR_ADDR_O
);

    /* Internal Wire/Register Definition */
    reg BCK_REG_P     = 1'b0;
    reg BCK_REG_N     = 1'b0;
    reg LRCK_REG_P    = 1'b0;
    reg LRCK_REG_N    = 1'b0;

    reg WEN_REG_P     = 1'b0;
    reg WEN_REG_N     = 1'b0;

    reg NRST_REG_P    = 1'b1;

    reg WENO_REG_P    = 1'b0;
    reg WENO_REG_N    = 1'b0; 
    reg NERR_ADDR_REG = 1'b0;

    reg [ADDR_WIDTH-1:0] WADDR_REG   = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] RADDR_REG   = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] ADDR_PTR    = {ADDR_WIDTH{1'b0}};
    
    reg [ADDR_WIDTH-1:0] WADDR_REG_P = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] WADDR_REG_N = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] RADDR_REG_P = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] RADDR_REG_N = {ADDR_WIDTH{1'b0}};

    /* RTL */
    always @ (posedge MCLK_I) begin
        /* Read BCK & LRCK */
        BCK_REG_P  <= BCK_I;
        LRCK_REG_P <= LRCK_I;

        NRST_REG_P <= NRST_I;

        /* Judge Write Enable */
        WEN_REG_P <= LRCK_I & ~LRCK_REG_N;

        /* Output Pipeline (Positive Edge) */
        WADDR_REG_P <= WADDR_REG;
        RADDR_REG_P <= RADDR_REG;
        WENO_REG_P  <= WEN_REG_N;
    end

    always @ (negedge MCLK_I) begin
        /* 1 MCLK cycle Delay */
        BCK_REG_N  <= BCK_REG_P;
        LRCK_REG_N <= LRCK_REG_P;
        
        /* Update Address */
        if (NRST_REG_P == 1'b0) begin
            /* Update Address for Initializng RAM Data. */
            WADDR_REG  <= RADDR_REG;
            RADDR_REG  <= RADDR_REG + 1'b1;

            WEN_REG_N  <= 1'b1; // Enable WEN_O While Reset.

        end else begin
            if (WEN_REG_P == 1'b1) begin
                /* When Write Enable */
                ADDR_PTR  <= ADDR_PTR + 1'b1; // Update the head of address.
                WADDR_REG <= ADDR_PTR;        // Update Write Address.
                RADDR_REG <= ADDR_PTR + 1'b1; // Update Read Address.
            end else begin
                /* Update only Read Address */
                RADDR_REG <= RADDR_REG + 1'b1;
            end

            WEN_REG_N <= WEN_REG_P;
        end

        /* Output Pipeline (Negative Edge) */
        WADDR_REG_N   <= WADDR_REG_P;
        RADDR_REG_N   <= RADDR_REG_P;
        WENO_REG_N    <= WENO_REG_P;
        NERR_ADDR_REG <= ~(WENO_REG_P & (WADDR_REG_P == RADDR_REG_P));
    end

    /* Output Assign */
    // Assertion #1: NERR_ADDR_O must be 1'b1.
    // psl assert always (NERR_ADDR_O == 1'b1) @ (posedge MCLK_I);
    assign NERR_ADDR_O = NERR_ADDR_REG;
    
    // Assertion #3: WEN_O must be 1'b0 when WADDR_O equals to RADDR_O.
    // psl assert always ((WADDR_O == RADDR_O) -> (WEN_O == 1'b0)) @ (posedge MCLK_I);
    assign WEN_O       = WENO_REG_N;
    
    // Assertion #4: RADDR_O must be equals to (WADDR_O + 1'b1) if WEN_REG_P is 1'b1
    // psl assert always ((WEN_O == 1'b1) -> (RADDR_O == WADDR_O + 1'b1)) @ (posedge MCLK_I);
    assign WADDR_O     = WADDR_REG_N;
    assign RADDR_O     = RADDR_REG_N;


endmodule
