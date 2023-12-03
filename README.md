# FIR_x2
FPGA based PCM oversampling FIR filter (oversample ratio: 2).

## Notes
1. Simple dual-port RAM (simple_dual_port_ram) & Single-port ROM (single_port_rom) are necessary but the author used code examples from FPGA vendor.
You can prepare code examples or your RTL you need.
2. FIR filter length must be as (MCLK_I frequency)/(Sampling frequency)
3. Test benches are used on Questa - Intel FPGA Starter Edition. So there are no stop command in them.

## License
Copyright AUDIY 2023.

This source describes Open Hardware and is licensed under the CERN-OHL-S v2. 

You may distribute and modify this source and make products using it under
the terms of the CERN-OHL-S v2 (https://ohwr.org/cern_ohl_s_v2.txt).

This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
PARTICULAR PURPOSE. Please see the CERN-OHL-S v2 for applicable conditions.

Source location: https://github.com/AUDIY/FIR_x2

As per CERN-OHL-S v2 section 4, should You produce hardware based on this
source, You must where practicable maintain the Source Location visible
on the external case of the Gizmo or other products you make using this
source.                                                                      
