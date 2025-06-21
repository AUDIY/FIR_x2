add log -r *

add wave -position insertpoint  \
sim:/SPROM_CONT_TB/u1/MCLK_I \
sim:/SPROM_CONT_TB/u1/BCK_I \
sim:/SPROM_CONT_TB/u1/LRCK_I \
sim:/SPROM_CONT_TB/u1/NRST_I \
sim:/SPROM_CONT_TB/u1/CADDR_O \
sim:/SPROM_CONT_TB/u1/LRCKx_O \
sim:/SPROM_CONT_TB/u1/BCKx_O

onfinish stop

run -all

coverage report -output report.txt -du=* -assert -directive -cvg -codeAll