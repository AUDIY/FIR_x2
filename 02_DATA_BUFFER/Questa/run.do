add log -r *

add wave -position insertpoint  \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/MCLK_I \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/BCK_I \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/LRCK_I \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/NRST_I \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/WDATA_I \
sim:/DATA_BUFFER_TB/u_DATA_BUFFER/RDATA_O

onfinish stop

run -all

coverage report -output report.txt -du=* -recursive -assert -directive -cvg -codeAll