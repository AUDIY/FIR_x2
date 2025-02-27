/*----------------------------------------------------------------------------
* SDPRAM_SINGLECLK.v
*
* Simple Dual-Port RAM (Single Clock)
*
* Version: 1.00
* Author : AUDIY
* Date   : 2025/01/20
*
* Port
*   Input
*       CLK_I        : RAM Write/Read Clock Input
*       WADDR_I      : Write Address Input
*       WENABLE_I    : Write Enable Input
*       WDATA_I      : Stored Data Input
*       RADDR_I      : Read Address Input
*       RENABLE_I    : Read Enable Input
*
*   Output
*       RDATA_O      : Stored Data Output
*
*   Parameter
*       DATA_WIDTH   : Coefficient DATA Width
*       ADDR_WIDTH   : ROM Address Width
*       OUTPUT_REG   : Output Register Enable
*       RAM_INIT_FILE: RAM Initialization File
*
* License under CERN-OHL-P v2
--------------------------------------------------------------------------------
| Copyright AUDIY 2023 - 2025.                                                 |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-P v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-P v2 (https:/cern.ch/cern-ohl).                    |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-P v2 for applicable conditions.  |
--------------------------------------------------------------------------------
*
-----------------------------------------------------------------------------*/

module SDPRAM_SINGLECLK #(
    /* Parameter Definition */
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 9,
    parameter OUTPUT_REG = "TRUE",
    parameter RAM_INIT_FILE = "RAMINIT.hex"
) (
    /* Input Port Definiton */
    input  wire                  CLK_I,
    input  wire [ADDR_WIDTH-1:0] WADDR_I,
    input  wire                  WENABLE_I,
    input  wire [DATA_WIDTH-1:0] WDATA_I,
    input  wire [ADDR_WIDTH-1:0] RADDR_I,
    input  wire                  RENABLE_I,

    /* Output Port Definition */
    output wire [DATA_WIDTH-1:0] RDATA_O
);

    /* Local Parameters */
    localparam MEMORY_DEPTH = 2**ADDR_WIDTH;
    localparam MAX_DATA     = (1 << ADDR_WIDTH) - 1;

    /* Internal Wire/Register Definition */
    reg [DATA_WIDTH-1:0] RAM[MEMORY_DEPTH-1:0];
    reg [DATA_WIDTH-1:0] RDATA_REG_1P = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] RDATA_REG_2P = {DATA_WIDTH{1'b0}};
    
    /* Memory Initialization */
    initial begin
        if (RAM_INIT_FILE != "") begin
            $readmemh(RAM_INIT_FILE, RAM);
        end
    end

    /* Store Data */
    always @ (posedge CLK_I) begin
        if (WENABLE_I == 1'b1) begin
            RAM[WADDR_I] <= WDATA_I;
        end
    end
    
    /* Output Register */
    always @ (posedge CLK_I) begin
        if (RENABLE_I == 1'b1) begin
            RDATA_REG_1P <= RAM[RADDR_I];
            RDATA_REG_2P <= RDATA_REG_1P;
        end
    end

    /* Output */
    generate
		if (OUTPUT_REG == "TRUE")
			assign RDATA_O = RDATA_REG_2P;
		else
			assign RDATA_O = RDATA_REG_1P;
	endgenerate

    /* Assertions */
    // Assertion #0: When RADDR_I and WADDR_I are the same, either or both of WENABLE_I and RENABLE returns 1'b0.
    // psl assert always ((RADDR_I == WADDR_I) -> ((WENABLE_I & RENABLE_I) == 1'b0)) @ (posedge CLK_I);

    // Assertion #1: When both of WENABLE_I and RENABLE_I returns 1'b1, RADDR_I and WADDR_I must be different.
    // psl assert always ((WENABLE_I & RENABLE_I == 1'b1) -> (WADDR_I != RADDR_I)) @(posedge CLK_I);

endmodule
