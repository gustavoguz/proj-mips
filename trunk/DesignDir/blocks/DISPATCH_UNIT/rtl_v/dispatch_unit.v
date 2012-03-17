






module dispatch_unit (
	);

regfile regfile(
	input			clock,
	input			reset,
	input 	[31: 0]		Data_In,
	input 	[ 4: 0]		Waddr,
	input			W_en,
	output	[31: 0]		Data_out1,
	input	[ 4: 0]		Rd_Addr1,
	output	[31: 0]		Data_out2,
	input	[ 4: 0]		Rd_Addr2
	);

decoder decoder (
	input              	clock,
	input             	reset,
	input  		[31:0] 	Inst,
	output reg 	[ 2:0]	Dispatch_opcode,
	output reg	[ 4:0]	Dispatch_shfamt,
	output reg 		Dispatch_en_integer,
	output reg 		Dispatch_en_ld_st,
	output reg 	[15:0]	Dispatch_imm_ld_st,
	output reg 		Dispatch_en_mult
	);

tagfifo tagfifo(
	input			clock,
	input			reset,
	output 	[DSIZE-1:0] 	Tag_Out,
	output 			tagFifo_full,
	output 			tagFifo_empty,
	input 	[DSIZE-1:0] 	RB_Tag,
	input 			RB_Tag_Valid,
	input 			Rd_en,
	);

branchlogic  branchlogic (
	input 		is_jump,
	input	[32:0]	pc,
	input	[15:0]	immediate,
	output	[32:0]  Jmp_branch_address
	);

rst rst (
  	input        	clock,
  	input        	reset,
  	input  	[ 4:0] 	Rsaddr_rst,
  	output 	[ 4:0] 	Rstag_rst,
  	output       	Rsvalid_rst,
  	input  	[ 4:0] 	Rtaddr_rst,
  	output 	[ 4:0] 	Rttag_rst,
  	output       	Rtvalid_rst,
  	input  	[ 4:0] 	RB_tag_rst,
	input        	RB_valid_rst,
 	input  	[ 4:0] 	Wdata_rst,
  	input  	[ 4:0] 	Waddr_rst,
	input 	[31:0] 	Wen0_rst,
	input 		Wen_rst,
	output reg [31:0] 	Wen1_rst 
	);

module rob (
	input 	[  4:  0]	Rs_reg,
	input 			Rs_reg_ren,
	input  	[  5:  0]	Rs_token,
	output 	[ 31:  0]	Rs_Data_spec,
	output 			Rs_Data_valid,
	input  	[  4:  0]	Rt_reg,
	input  			Rt_reg_ren,
	output	[  5:  0]	Rt_token,
	output	[ 31:  0]	Rt_Data_spec,
	output			Rt_Data_valid,
	input	[  4:  0]	Dispatch_Rd_tag,
	input	[  4:  0]	Dispatch_Rd_reg,
	input 	[ 31:  0]	Dispatch_pc,
	input	[  1:  0]	Dispatch_inst_type,
	input 	[  4:  0]	Cdb_rd_tag,
	input			Cdb_valid,
	input	[ 31:  0]	Cdb_data,
	input 			Cdb_branch,
	input			Cdb_branch_taken,
	output	[  4:  0]	Retire_rd_tag,
	output	[  4:  0]	Retire_rd_reg,
	output	[ 31:  0]	Retire_data,
	output	[ 31:  0]	Retire_pc,
	output			Retire_branch,
	output			Retire_branch_taken,
	output			Retire_store_ready,
	output			Retire_valid
	);

endmodule 
