vlib work

vmap work work

vlog +cover=bcs ../FIR_x2.v
vlog ../../01_DPRAM_CONT/DPRAM_CONT.v
vlog ../../02_DATA_BUFFER/SDPRAM_SINGLECLK.v
vlog ../../02_DATA_BUFFER/DATA_BUFFER.v
vlog ../../03_SPROM_CONT/SPROM_CONT.v
vlog ../../04_FIR_COEF/SPROM.v
vlog ../../04_FIR_COEF/FIR_COEF.v
vlog ../../05_MULT/MULT.v
vlog ../../06_ADD/ADD.v
vlog ../FIR_x2_TB.v

vsim -debugdb=+acc work.FIR_x2_TB -voptargs=+acc -coverage -do "do run.do"
