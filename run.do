vlib work
vlog -f src_files.list    +cover -covercells
vsim -voptargs=+acc work.top -cover -sv_seed 3402923261
add wave /top/F_if/*
add wave -position insertpoint  \
sim:/top/f1/wr_ptr \
sim:/top/f1/rd_ptr \
sim:/top/f1/count
coverage save FIFO_top.ucdb -onexit
run -all