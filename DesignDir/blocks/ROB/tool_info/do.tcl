#add wave -position anchor sim:/testbench/*
add wave -position anchor sim:/testbench/rob/clock
add wave -position anchor sim:/testbench/rob/increment
add wave -position anchor sim:/testbench/rob/OrderQueueNew_read
add wave -position anchor sim:/testbench/rob/RequestQueryRs
add wave -position anchor sim:/testbench/rob/OrderQueue_data
add wave -position anchor sim:/testbench/rob/Rs_reg_reg
add wave -position anchor sim:/testbench/rob/Retire_rd_tag
add wave -position anchor sim:/testbench/rob/Reg_File_Tmp_data_Rs;
add wave -position anchor sim:/testbench/rob/OrderQueue_data_temp
add wave -position anchor sim:/testbench/rob/RequestAddNew
run -all
