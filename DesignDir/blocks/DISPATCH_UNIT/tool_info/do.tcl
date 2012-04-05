onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -position anchor sim:/testbench/*
add wave -position anchor sim:/testbench/dispatch_unit/new_instruction
add wave -position anchor sim:/testbench/dispatch_unit/issueque_integer_full_A
add wave -position anchor sim:/testbench/dispatch_unit/issueque_integer_full_B
add wave -position anchor sim:/testbench/dispatch_unit/last
add wave -position anchor sim:/testbench/dispatch_unit/next
add wave -position anchor sim:/testbench/dispatch_unit/dispatch_en_integer_A
add wave -position anchor sim:/testbench/dispatch_unit/dispatch_en_integer_B
add wave -position anchor -divider refgile
add wave -position anchor -radix hexadecimal -color Orange sim:/testbench/dispatch_unit/rob/regfiletmp/RegFile
run -all
