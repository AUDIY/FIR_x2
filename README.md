# FIR_x2
FPGA based PCM oversampling FIR filter (oversample ratio: 2).

## Usage
### Simulation
1. Compile each module and <module_name>_tb.v (memory initialization file & test signals are necessary on some modules).
2. Start Simulation.
### Real Machine
1. Add all modules (except <module_name>_tb.v) and memory initialization file into your project.
2. Change parameters depending on your audio data settings (ex. MCLK frequency, BCK frequency).
3. Synthesize, place & route to your FPGA.
4. Confirm actual operation.

## Notes
1. Single-Port ROM (SPROM.v) & Simple Dual-Port RAM (SDPRAM_SINGLECLK.v) are provided but it is recommended to use each-vendor official IP.
2. FIR filter length must be equals to (MCLK_I frequency)/(Sampling frequency)
3. Test benches are used on Questa - Intel FPGA Starter Edition. So there are no stop command in them.

## Verified Devices
1. Efinix T20F256I4 on Trion T20 BGA256 Development Kit( https://www.efinixinc.com/products-devkits-triont20.html )
2. Intel MAX10 10M50DAF484C7G on terasIC DE10-Lite ( https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021 )

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
