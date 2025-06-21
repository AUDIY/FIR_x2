add log -r *

add wave -position insertpoint  \
sim:/MULT_TB/u_MULT/MCLK_I \
sim:/MULT_TB/u_MULT/DATA_I \
sim:/MULT_TB/u_MULT/COEF_I \
sim:/MULT_TB/u_MULT/LRCKx2_I \
sim:/MULT_TB/u_MULT/BCKx2_I \
sim:/MULT_TB/u_MULT/NRST_I \
sim:/MULT_TB/u_MULT/DATA_O \
sim:/MULT_TB/u_MULT/LRCKx2_O \
sim:/MULT_TB/u_MULT/BCKx2_O

onfinish stop

run -all

coverage report -output report.txt -du=* -assert -directive -cvg -codeAll