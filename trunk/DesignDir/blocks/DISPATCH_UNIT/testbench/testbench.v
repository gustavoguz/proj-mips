//Testbench: DISPATCH_UNIT

`timescale 1ns / 100ps

module testbench;


	reg 			clock;
	reg 			reset;
	reg  [  31: 0]		ifetch_pc_4;
	reg  [  31: 0]		ifetch_intruction;
	reg			ifetch_empty;
	wire [ 31:  0]		Dispatch_jmp_addr;
	wire			Dispatch_jmp;
	wire			Dispatch_ren;
	wire [ 31:  0]		dispatch_rs_data;
	wire			dispatch_rs_data_valid;
	wire [  4:  0]		dispatch_rs_tag;
	wire [ 31:  0]		dispatch_rt_data;
	wire 			dispatch_rt_data_valid;
	wire [  4:  0]		dispatch_rt_tag;
	wire [  4:  0]		dispatch_rd_tag;
	wire 			dispatch_en_integer_A;
	wire 			dispatch_en_integer_B;
	reg			issueque_integer_full_A;
	reg			issueque_integer_full_B;
	wire [  3:  0]		dispatch_opcode;
	wire [  4:  0]		dispatch_shfamt;
	wire			dispatch_en_ld_st;
	reg			issueque_full_ld_st;
	wire [ 15:  0]		dispatch_imm_ld_st;
	wire			dispatch_en_mul;
	wire			flush;
	wire 			Retire_store_ready;
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
	.dispatch_en_integer_A	(dispatch_en_integer_A),
	.dispatch_en_integer_B	(dispatch_en_integer_B),
	.issueque_integer_full_A	(issueque_integer_full_A),
	.issueque_integer_full_B	(issueque_integer_full_B),
	.dispatch_opcode	(dispatch_opcode),
	.dispatch_shfamt	(dispatch_shfamt),
	.dispatch_en_ld_st	(dispatch_en_ld_st),
	.issueque_full_ld_st	(issueque_full_ld_st),
	.dispatch_imm_ld_st	(dispatch_imm_ld_st),
	.dispatch_en_mul	(dispatch_en_mul),
	.issueque_mul_full	(issueque_mul_full),
	.flush			(flush),
	.Retire_store_ready	(Retire_store_ready)
	);
always begin
# 5	clock = !clock;
end

initial begin
	clock =	0;
	reset = 0;
	reset = 0;
#5	reset = 0;
	reset = 1;
#10	reset = 0;
//mem [ 0] = 32'h00000020 ; //add $0, $0, $0     //nop *** INITIALIZATION FOR BUBBLE SORT ***
//mem [ 1] = 32'h0080F820 ; //add $31, $4, $0    //$31 = 4 
//mem [ 2] = 32'h00BF1019 ; //mul $2, $5, $31    //ak = 4 * num_of_items
//mem [ 3] = 32'h00000020 ; //add $0, $0, $0     //noop
$display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
$display ("INFO : DISPATCHER_TB : START ");
ifetch_pc_4=0;
ifetch_intruction=32'h0080F820;
ifetch_empty=0;
issueque_integer_full_A=0;
issueque_integer_full_B=0;
issueque_full_ld_st=0;
issueque_mul_full=0;
//------------------------------------
#40
$display ("INFO : DISPATCHER_TB : START ");
ifetch_pc_4=0;
ifetch_pc_4=4;
ifetch_intruction=32'h00BF1018;
ifetch_empty=0;
issueque_integer_full_A=0;
issueque_integer_full_B=0;
issueque_full_ld_st=0;
issueque_mul_full=0;
//------------------------------------
#40
$display ("INFO : DISPATCHER_TB : START ");
ifetch_pc_4=0;
ifetch_pc_4=0;
ifetch_intruction=32'h00000020;
ifetch_empty=0;
issueque_integer_full_A=0;
issueque_integer_full_B=0;
issueque_full_ld_st=0;
issueque_mul_full=0;
//------------------------------------


#20 ifetch_empty=1;
$display ("INFO : DISPATCHER_TB : END ");
#20 $finish;
end

endmodule
