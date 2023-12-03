/*-----------------------------------------------------------------------------
* DATA_BUFFER.v
*
* Input DATA Buffer with RAM
*
* Version: 0.11
* Author : AUDIY
* Date   : 2023/12/03
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
    simple_dual_port_ram u_simple_dual_port_ram(
        .wclk(MCLK_I),
        .we(WEN),
        .waddr(WADDR),
        .wdata(WDATA_I),
        .rclk(MCLK_I),
        .re(REN),
        .raddr(RADDR),
        .rdata(RDATA_O)
    );
    defparam u_simple_dual_port_ram.DATA_WIDTH = DATA_WIDTH;
    defparam u_simple_dual_port_ram.ADDR_WIDTH = ADDR_WIDTH;
    defparam u_simple_dual_port_ram.OUTPUT_REG = OUTPUT_REG;
    defparam u_simple_dual_port_ram.RAM_INIT_FILE = RAM_INIT_FILE;
    

endmodule