add log -r *

add wave -position insertpoint \
sim:/DPRAM_CONT_TB/u1/MCLK_I \
sim:/DPRAM_CONT_TB/u1/LRCK_I \
sim:/DPRAM_CONT_TB/u1/NRST_I \
sim:/DPRAM_CONT_TB/u1/WEN_O \
sim:/DPRAM_CONT_TB/u1/WADDR_O \
sim:/DPRAM_CONT_TB/u1/REN_O \
sim:/DPRAM_CONT_TB/u1/RADDR_O 

onfinish stop

run -all

coverage report -html -output covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90