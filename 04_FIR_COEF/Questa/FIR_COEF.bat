vlib work

vmap work work

vlog +cover=bcs ../SPROM.v
vlog +cover=bcs ../../03_SPROM_CONT/SPROM_CONT.v
vlog +cover=bcs ../FIR_COEF.v
vlog ../FIR_COEF_TB.v

vsim -debugdb=+acc work.FIR_COEF_TB -voptargs=+acc -coverage -do "do run.do"