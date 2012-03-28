//Testbench: DISPATCH_UNIT

`timescale 1ns / 100ps

module testbench;


	reg 			clock;
	reg 			reset;
	reg			ifetch_pc_4;
	reg			ifetch_intruction;
	reg			ifetch_empty;
	wire [ 32:  0]		Dispatch_jmp_addr;
	wire			Dispatch_jmp;
	wire			Dispatch_ren;
	wire [ 32:  0]		dispatch_rs_data;
	wire			dispatch_rs_data_valid;
	wire [  4:  0]		dispatch_rs_tag;
	wire [ 32:  0]		dispatch_rt_data;
	wire 			dispatch_rt_data_valid;
	wire [  4:  0]		dispatch_rt_tag;
	wire [  4:  0]		dispatch_rd_tag;
	wire 			dispatch_en_integer;
	reg			issueque_integer_full;
	wire [  3:  0]		dispatch_opcode;
	wire [  4:  0]		dispatch_shfamt;
	wire			dispatch_en_ld_st;
	reg			issueque_full_ld_st;
	wire [ 15:  0]		dispatch_imm_ld_st;
	wire			dispatch_en_mul;
	reg			issueque_mul_full;


dispatch_unit dispatch_unit (
	.clock			(clock),
	.reset			(reset),
	.ifetch_pc_4		(ifetch_pc_4),
	.ifetch_intruction	(ifetch_intruction),
	.ifetch_empty		(ifetch_empty),
	.Dispatch_jmp_addr	(Dispatch_jmp_addr),
	.Dispatch_jmp		(Dispatch_jmp),
	.Dispatch_ren		(Dispatch_ren),
	.dispatch_rs_data	(dispatch_rs_data),
	.dispatch_rs_data_valid	(dispatch_rs_data_valid),
	.dispatch_rs_tag	(dispatch_rs_tag),
	.dispatch_rt_data	(dispatch_rt_data),
	.dispatch_rt_data_valid	(dispatch_rt_data_valid),
	.dispatch_rt_tag	(dispatch_rt_tag),
	.dispatch_rd_tag	(dispatch_rd_tag),
	.dispatch_en_integer	(dispatch_en_integer),
	.issueque_integer_full	(issueque_integer_full),
	.dispatch_opcode	(dispatch_opcode),
	.dispatch_shfamt	(dispatch_shfamt),
	.dispatch_en_ld_st	(dispatch_en_ld_st),
	.issueque_full_ld_st	(issueque_full_ld_st),
	.dispatch_imm_ld_st	(dispatch_imm_ld_st),
	.dispatch_en_mul	(dispatch_en_mul),
	.issueque_mul_full	(issueque_mul_full)
	);

endmodule
