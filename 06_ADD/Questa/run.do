add log -r *

add wave -position insertpoint  \
sim:/ADD_TB/u_ADD/MCLK_I \
sim:/ADD_TB/u_ADD/BCKx2_I \
sim:/ADD_TB/u_ADD/LRCKx2_I \
sim:/ADD_TB/u_ADD/MULT_I \
sim:/ADD_TB/u_ADD/NRST_I \
sim:/ADD_TB/u_ADD/ADD_O \
sim:/ADD_TB/u_ADD/LRCKx2_O \
sim:/ADD_TB/u_ADD/BCKx2_O

onfinish stop

run -all

coverage report -output report.txt -du=* -assert -directive -cvg -codeAll