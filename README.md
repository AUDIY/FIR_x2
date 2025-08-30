# FIR_x2
FPGA based PCM oversampling FIR filter (oversample ratio: 2).  
![Image 1](/Images/image1.png)

## ⚠️ Project Status Update
**[FIR_x2](https://github.com/AUDIY/FIR_x2) is NO LONGER MAINTAINED and will be archived soon.**  

Once the successor project is released, this repository will be archived.  
Until then, minor updates such as license adjustments and creation of Releases may occur, but no changes will be made to the source code itself, including bug fixes.  
Please look forward to the upcoming successor project, which will expand upon the features of FIR_x2.  

**We sincerely appreciate everyone who has starred, forked, or simply followed this repository — thank you for your support and interest in [FIR_x2](https://github.com/AUDIY/FIR_x2).**

## Japanese Page
### Summary
https://audio-diy.hatenablog.com/entry/FIR_x2_summary
### How to Use
https://audio-diy.hatenablog.com/entry/FIR_x2_howtouse
### FIR filter file generation
https://audio-diy.hatenablog.com/entry/FIR_x2_coef_gen

## Usage
### Custom FIR filter generation
1. Generate the signed integer FIR filter using like Python or MATLAB.
2. If the number of coefficients is odd, prepend a zero to make the count even.
3. Convert the signed decimal numbers into hexadecimal format using 2's complement representation.  

If you would like more details, please refer to the [README.md](./11_fir_gen/README.md) in the [11_fir_gen](./11_fir_gen) directory.

### Simulation
1. Compile each module and <module_name>_tb.v (memory initialization file & test signals are necessary on some modules).
2. If you use Questa advanced simulator, you can use the batch file in the "Questa" directory in each module.
3. Start Simulation.
   
### Real Machine
1. Add all modules (except <module_name>_tb.v other than test bench for DUT) and memory initialization file into your project.
2. Change parameters depending on your audio data settings (ex. MCLK frequency, BCK frequency).
3. Synthesize, place & route to your FPGA.
4. Confirm actual operation.

## Notes
1. Single-Port ROM (SPROM.v) & Simple Dual-Port RAM (SDPRAM_SINGLECLK.v) are provided from [AUDIY_Verilog_IP](https://github.com/AUDIY/AUDIY_Verilog_IP) but it is recommended to use each-vendor official IP.
2. FIR filter length must be equals to (MCLK_I frequency)/(Sampling frequency)
3. When you use in vivado, memory file(.hex) should be changed to data file(.data). 

## Verified Devices
1. Altera Cyclone 10 LP 10CL025YU256I7G on [Intel Cyclone 10 LP FPGA Evaluation Kit EK-10CL025U256](https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/cyclone/10-lp-evaluation-kit.html)
2. Altera Cyclone IV E EP4CE22F17C6N on [Terasic DE0-Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=593)
3. Altera MAX 10 10M50DAF484C7G on [Terasic DE10-Lite](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=234&No=1021)
4. Efinix Trion T20F256I4 on [Efinix Trion T20 BGA256 Development Kit](https://www.efinixinc.com/products-devkits-triont20.html)
5. AMD Artix-7 XC7A35T-1CPG236C on [Digilent Cmod A7](https://digilent.com/reference/programmable-logic/cmod-a7/start)
6. AMD Spartan-7 XC7S25-1CSGA225C on [Digilent Cmod S7](https://digilent.com/reference/programmable-logic/cmod-s7/start)
7. Gowin Arora GW2A-LV18PG256C8/I7 on [Sipeed Tang Primer 20K + Dock](https://wiki.sipeed.com/hardware/en/tang/tang-primer-20k/primer-20k.html#Dock-ext-board-appearance)

## Examples
These sample projects oversample 44.1/48kHz PCM to 88.2/96kHz PCM.
1. [Oversample_x2_EK10CL025.qar for Cyclone 10 LP FPGA Evaluation Kit EK-10CL025U256 & Quartus Prime Lite v24.1](/10_Example/01_EK-10CL025U256)
2. [Oversample_x2_DE0-Nano.qar for DE0-Nano & Quartus Prime Lite v24.1](/10_Example/02_DE0-Nano)
3. [Oversample_x2_DE10-Lite.qar for DE10-Lite & Quartus Prime Lite v24.1](/10_Example/03_DE10-Lite)
4. [Oversample_x2_T20F256DevKit.zip for Trion T20 BGA256 Development Kit & Efinity 2025.1.110.4.9](/10_Example/04_T20F256DevKit)
5. [Oversample_x2_Cmod-A7.xpr.zip for Cmod-A7 & Vivado 2025.1](/10_Example/05_Cmod-A7)
6. [Oversample_x2_Cmod-S7.xpr.zip for Cmod-S7 & Vivado 2025.1](/10_Example/06_Cmod-S7)
7. [Oversample_x2_TangPrimer20K.gar for Tang Primer 20K & Gowin FPGA Designer v1.9.11.01 Education](/10_Example/07_TangPrimer20K)

## License
Copyright AUDIY 2023 - 2025.

This source describes Open Hardware and is licensed under the CERN-OHL-W v2

You may redistribute and modify this documentation and make products using it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl). 

This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2 for applicable conditions.

Source location: https://github.com/AUDIY/FIR_x2

As per CERN-OHL-W v2 section 4.1, should You produce hardware based on these sources, You must maintain the Source Location visible on the external case of the FIR_x2 or other product you make using this documentation.
