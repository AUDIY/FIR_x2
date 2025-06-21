vlib work

vmap work work

vlog -work work -cover bcs ../*.v ../../01_DPRAM_CONT/DPRAM_CONT.v

vsim -debugdb=+acc work.DATA_BUFFER_TB -voptargs=+acc -assertdebug -coverage -do "do run.do"