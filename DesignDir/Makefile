
DESIGN_DIR:=${PWD}
DEBUG :=0
export DESIGN_DIR
export DEBUG


BLOCK_NAME:=BranchLogic
SUB_LIST:=""

test: query_blocks query_blockdir query_rtl query_verilog query_testbench
	@echo DONE
query_blocks:
	@tclsh scripts/query_blocks.tcl "*"

query_blockdir:
	@tclsh scripts/query_bldir.tcl "*" ""

query_rtl:
	@tclsh scripts/query_bldir.tcl "*" "rtl_v"

query_verilog:
	@tclsh scripts/query_files.tcl "*" "rtl_v" "*.v"

create_files:
	@tclsh scripts/query_blocks_files.tcl ${BLOCK_NAME} "rtl_v" "*.v"

query_testbench:
	@tclsh scripts/query_files.tcl "*" "testbench" "*.v"

create_block:
	@tclsh scripts/create_block.tcl ${BLOCK_NAME} ${SUB_LIST}
	@tclsh scripts/query_blocks_files.tcl ${BLOCK_NAME} "rtl_v" "*.v"

help:
	@echo "scripts/query_blocks.tcl : shows all the design blocks"
	@echo "scripts/query_bldir.tcl <block> <sub_block_dir> : show an specific directory"  
	@echo "scripts/query_files.tcl <block> <sub_block_dir> <file> : show an specific file"
	

