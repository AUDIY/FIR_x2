vlib work

vmap work work

vlog +cover=bcs ../*.v

vsim -debugdb=+acc work.SPROM_CONT_TB -voptargs=+acc -assertdebug -coverage -do "run.do"