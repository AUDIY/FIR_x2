/*-----------------------------------------------------------------------------
* DATA_BUFFER.v
*
* Input DATA Buffer with RAM
*
* Version: 0.13
* Author : AUDIY
* Date   : 2023/12/23
*
* Port
*   Input
*       MCLK_I       : Master Clock Input
*       BCK_I        : Bit Clock Input
*       LRCK_I       : LR Clock Input
*       NRST_I       : Reset Input (Active Low)
*       WDATA_I      : Audio Data Input
*
*   Output
*       RDATA_O      : Audio Data Output
*
*   Parameter
*       DATA_WITDH   : Coefficient DATA Width
*       ADDR_WIDTH   : ROM Address Width
*       OUTPUT_REG   : Output Register Enable
*       RAM_INIT_FILE: RAM Initialization File
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

module DATA_BUFFER #(
    /* Parameter Definition */
    parameter ADDR_WIDTH    = 8,
    parameter DATA_WIDTH    = 32,
    parameter OUTPUT_REG    = "TRUE",
    parameter RAM_INIT_FILE = "BUFFER_INIT.hex"
)
(
    /* Input Port Definition */
    input  wire                           MCLK_I,
    input  wire                           BCK_I,
    input  wire                           LRCK_I,
    input  wire                           NRST_I,
    input  wire signed [(DATA_WIDTH-1):0] WDATA_I,

    /* Output Port Definition */
    output wire signed [(DATA_WIDTH-1):0] RDATA_O
);

    /* Internal Wire/Register Definition */
    wire WEN;
    wire REN;
    wire [(ADDR_WIDTH-1):0] WADDR;
    wire [(ADDR_WIDTH-1):0] RADDR;

    /* Dual Port RAM Controller */
    DPRAM_CONT u_DPRAM_CONT(
        .MCLK_I(MCLK_I),
        .BCK_I(BCK_I),
        .LRCK_I(LRCK_I),
        .NRST_I(NRST_I),
        .WEN_O(WEN),
        .WADDR_O(WADDR),
        .RADDR_O(RADDR),
        .NERR_ADDR_O(REN)
    );
    defparam u_DPRAM_CONT.ADDR_WIDTH = ADDR_WIDTH;

    /* Simple Dual Port RAM */
    SDPRAM_SINGLECLK u_SDPRAM_SINGLECLK(
        .CLK_I(MCLK_I),
        .WENABLE_I(WEN),
        .WADDR_I(WADDR),
        .WDATA_I(WDATA_I),
        .RENABLE_I(REN),
        .RADDR_I(RADDR),
        .RDATA_O(RDATA_O)
    );
    defparam u_SDPRAM_SINGLECLK.DATA_WIDTH = DATA_WIDTH;
    defparam u_SDPRAM_SINGLECLK.ADDR_WIDTH = ADDR_WIDTH;
    defparam u_SDPRAM_SINGLECLK.OUTPUT_REG = OUTPUT_REG;
    defparam u_SDPRAM_SINGLECLK.RAM_INIT_FILE = RAM_INIT_FILE;
    

endmodule
