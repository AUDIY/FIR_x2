# FIR_x2
FPGA based PCM oversampling FIR filter (oversample ratio: 2).  
![Image 1](/Images/image1.png)

## Japanese Page
### Summary
https://audio-diy.hatenablog.com/entry/FIR_x2_summary
### How to Use
https://audio-diy.hatenablog.com/entry/FIR_x2_howtouse

## Usage
### Simulation
1. Compile each module and <module_name>_tb.v (memory initialization file & test signals are necessary on some modules).
2. Start Simulation.
   
### Real Machine
1. Add all modules (except <module_name>_tb.v other than test bench for DUT) and memory initialization file into your project.
2. Change parameters depending on your audio data settings (ex. MCLK frequency, BCK frequency).
3. Synthesize, place & route to your FPGA.
4. Confirm actual operation.

## Notes
1. Single-Port ROM (SPROM.v) & Simple Dual-Port RAM (SDPRAM_SINGLECLK.v) are provided but it is recommended to use each-vendor official IP.
2. FIR filter length must be equals to (MCLK_I frequency)/(Sampling frequency)
3. Test benches are used on Questa - Intel FPGA Starter Edition. So there are no stop command in them.
4. This project includes asynchronous design now. The author will try to make this completely synchronous design.

## Verified Devices
1. Efinix T20F256I4 on Trion T20 BGA256 Development Kit( https://www.efinixinc.com/products-devkits-triont20.html )
2. Intel MAX10 10M50DAF484C7G on terasIC DE10-Lite ( https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021 )
3. Intel Cyclone IV E EP4CE22F17C6N on terasIC DE0-Nano ( https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=165&No=593#contents )
4. Gowin Arora GW2A-LV18PG256C8/I7 on Sipeed Tang Primer 20K & Dock ext-board ( https://wiki.sipeed.com/hardware/en/tang/tang-primer-20k/primer-20k.html )
5. AMD Spartan-7 XC7S25-1CSGA225C on Digilent Cmod S7 ( https://digilent.com/reference/programmable-logic/cmod-s7/start )

## Examples
1. Oversample_x2_DE10Lite.qar for DE10-Lite & Quartus-Prime Lite v22.1 ( /10_Example/01_DE10-Lite )
2. Oversample_x2_T20F256DevKit.zip for T20F256 Dev Kit & Efinity IDE v2023.1.150.6.14 ( /10_Example/02_T20F256DevKit )
3. Oversample_x2_DE0Nano.qar for DE0-Nano & Quartus-Prime Lite v22.1 ( /10_Example/03_DE0-Nano )
4. Oversample_x2_Tang_Primer_20K.gar for Tang Primer 20K & Gowin EDA v1.9.8.11 Education ( /10_Example/04_Tang_Primer_20K )
5. Oversample_x2_Cmod_S7.xpr.zip for Cmod S7 & Vivado v2024.1.2 ( /10_Example/05_Cmod_S7 )

## License
Copyright AUDIY 2023 - 2025.

This source describes Open Hardware and is licensed under the CERN-OHL-W v2

You may redistribute and modify this documentation and make products using it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl). 

This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.

Source location: https://github.com/AUDIY/FIR_x2

As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these sources, You must maintain the Source Location visible on the external case of the FIR_x2 or other product you make using this documentation.
