add log -r *

add wave -position insertpoint  \
sim:/FIR_x2_TB/u_FIR_x2/MCLK_I \
sim:/FIR_x2_TB/u_FIR_x2/BCK_I \
sim:/FIR_x2_TB/u_FIR_x2/LRCK_I \
sim:/FIR_x2_TB/u_FIR_x2/NRST_I \
sim:/FIR_x2_TB/u_FIR_x2/DATA_I \
sim:/FIR_x2_TB/u_FIR_x2/BCKx2_O \
sim:/FIR_x2_TB/u_FIR_x2/LRCKx2_O \
sim:/FIR_x2_TB/u_FIR_x2/DATA_O

onfinish stop

run -all

coverage report -output report.txt -du=* -assert -directive -cvg -codeAll