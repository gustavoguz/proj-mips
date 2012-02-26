add wave -position anchor  \
sim:/testbench/i_cache/clk \
sim:/testbench/i_cache/reset \
sim:/testbench/i_cache/Pc_in \
sim:/testbench/i_cache/Rd_en \
sim:/testbench/i_cache/Dout \
sim:/testbench/i_cache/Dout_valid \
sim:/testbench/i_cache/mem

run -all
