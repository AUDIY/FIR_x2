add log -r *

add wave -position insertpoint  \
sim:/FIR_COEF_TB/u_FIR_COEF/MCLK_I \
sim:/FIR_COEF_TB/u_FIR_COEF/BCK_I \
sim:/FIR_COEF_TB/u_FIR_COEF/LRCK_I \
sim:/FIR_COEF_TB/u_FIR_COEF/NRST_I \
sim:/FIR_COEF_TB/u_FIR_COEF/COEF_O \
sim:/FIR_COEF_TB/u_FIR_COEF/LRCKx2_O \
sim:/FIR_COEF_TB/u_FIR_COEF/BCKx2_O

onfinish stop

run -all

coverage report -output report.txt -du=* -assert -directive -cvg -codeAll