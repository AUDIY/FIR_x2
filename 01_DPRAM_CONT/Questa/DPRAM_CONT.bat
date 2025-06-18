vlib work
vmap work work

vlog -work work -cover bcs ../*.v

vsim -debugdb=+acc -assertdebug work.DPRAM_CONT_TB -coverage -voptargs=+acc -do "do run.do"