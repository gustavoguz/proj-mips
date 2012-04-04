//Testbench: ROB

`timescale 1ns / 100ps

module testbench;

  	reg        	clock;
  	reg        	reset;
	reg 		new_rd_tag;
	reg		new_rd_tag_valid;
	reg 	[  4:  0]	Rs_reg;
	reg 			Rs_reg_ren;
	wire 	[  5:  0]	Rs_token;
	wire 	[ 31:  0]	Rs_Data_spec;
	wire 			Rs_Data_valid;
	reg  	[  4:  0]	Rt_reg;
	reg  			Rt_reg_ren;
	wire	[  5:  0]	Rt_token;
	wire	[ 31:  0]	Rt_Data_spec;
	wire			Rt_Data_valid;

	reg	[  4:  0]	Dispatch_Rd_tag;
	reg	[  4:  0]	Dispatch_Rd_reg;
	reg 	[ 31:  0]	Dispatch_pc;
	reg	[  1:  0]	Dispatch_inst_type;

	reg 	[  4:  0]	Cdb_rd_tag;
	reg			Cdb_valid;
	reg	[ 31:  0]	Cdb_data;
	reg 			Cdb_branch;
	reg			Cdb_branch_taken;

	wire	[  4:  0]	Retire_rd_tag;
	wire	[  4:  0]	Retire_rd_reg;
	wire	[ 31:  0]	Retire_data;
	wire	[ 31:  0]	Retire_pc;
	wire			Retire_branch;
	wire			Retire_branch_taken;
	wire			Retire_store_ready;
	wire			Retire_valid;

rob rob (
  	.clock(clock),
  	.reset(reset),
	.new_rd_tag(new_rd_tag),
	.new_rd_tag_valid(new_rd_tag_valid),
	.Rs_reg(Rs_reg),
	.Rs_reg_ren(Rs_reg_ren),
	.Rs_token(Rs_token),
	.Rs_Data_spec(Rs_Data_spec),
	.Rs_Data_valid(Rs_Data_valid),
	.Rt_reg(Rt_reg),
	.Rt_reg_ren(Rt_reg_ren),
	.Rt_token(Rt_token),
	.Rt_Data_spec(Rt_Data_spec),
	.Rt_Data_valid(Rt_Data_valid),
	.Dispatch_Rd_tag(Dispatch_Rd_tag),
	.Dispatch_Rd_reg(Dispatch_Rd_reg),
	.Dispatch_pc(Dispatch_pc),
	.Dispatch_inst_type(Dispatch_inst_type),
	.Cdb_rd_tag(Cdb_rd_tag),
	.Cdb_valid(Cdb_valid),
	.Cdb_data(Cdb_data),
	.Cdb_branch(Cdb_branch),
	.Cdb_branch_taken(Cdb_branch_taken),
	.Retire_rd_tag(Retire_rd_tag),
	.Retire_rd_reg(Retire_rd_reg),
	.Retire_data(Retire_data),
	.Retire_pc(Retire_pc),
	.Retire_branch(Retire_branch),
	.Retire_branch_taken(Retire_branch_taken),
	.Retire_store_ready(Retire_store_ready),
	.Retire_valid(Retire_valid)
	);

integer i;
reg  [ 4:0] temp=0;

always begin
#5 	clock=!clock;
end

always @(posedge clock or posedge reset) begin
	$display ("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ i %d temp %d", i, temp);
	if (reset) begin
	temp <=0;
	end else begin
	temp <=i;
		if (i != temp) begin
			new_rd_tag <=1;
		end else begin
			new_rd_tag <=0;
		end
	end
end
//#5 new_rd_tag=!new_rd_tag;

initial begin
	clock=0;
	reset=0;
#5	reset=1;
#10	reset=0;
Dispatch_pc=0;
Rs_reg_ren=0;
Rt_reg_ren=0;
Cdb_valid=0;
Cdb_rd_tag=0;
Cdb_data=0;
Cdb_branch=0;
Cdb_branch_taken=0;
// Nueva instruccion:
new_rd_tag_valid=0;
new_rd_tag=0;
for (i=0; i<40; i=i+1) begin
//#10
#30
	`ifdef DEBUG_ROB_TB $display("Nueva instruccion,Dispatch_Rd_tag=%d,Dispatch_Rd_reg=%d,Dispatch_pc=%d,Dispatch_inst_type=2'b11",i,i,Dispatch_pc+4); `endif
	Dispatch_Rd_tag=i;
	Dispatch_Rd_reg=i;
	Dispatch_pc=Dispatch_pc+4;
	Dispatch_inst_type=2'b11;
	new_rd_tag_valid=1;
	temp <= 0;
	//new_rd_tag =1;
//#5
end
new_rd_tag_valid=0;

// Lectura del estdo de los registros:
for (i=0; i<40; i=i+1) begin
#10	Rs_reg=i;
	Rs_reg_ren=1;
	Rt_reg=i;
	Rt_reg_ren=1;
`ifdef DEBUG_ROB_TB $display ("------------------------------------------"); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token 	 %d",Rs_token); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_tag 	 %d",Rs_token[5:1]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_valid 	 %d",Rs_token[0]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_Data_spec  %d",Rs_Data_spec); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_Data_valid %d",Rs_Data_valid); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_token 	 %d",Rt_token); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_tag 	 %d",Rt_token[5:1]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_valid 	 %d",Rt_token[0]); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_Data_spec  %d",Rt_Data_spec); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_Data_valid %d",Rt_Data_valid); `endif
`ifdef DEBUG_ROB_TB $display ("------------------------------------------"); `endif
end

`ifdef DEBUG_ROB_TB $display ("+++++++++++++++++++++++++++++++++------------------------------------------+++++++++++++++++++++++++++++++++++++++"); `endif
`ifdef DEBUG_ROB_TB $display ("INFO : ROB TB : START UPDATING CDB BUS "); `endif
`ifdef DEBUG_ROB_TB $display ("+++++++++++++++++++++++++++++++++------------------------------------------+++++++++++++++++++++++++++++++++++++++"); `endif
// CDB update:
Rs_reg_ren = 0;
Rt_reg_ren = 0;
for (i=0; i<40; i=i+1) 	begin
#10	Cdb_rd_tag	= i;
	Cdb_data	= i;
	if (i==10) 		begin
	Cdb_branch	= 1;
	Cdb_branch_taken= 0;
	end else if (i==20) 	begin
	Cdb_branch	= 1;
	Cdb_branch_taken= 1;
	end 	else 		begin
	Cdb_branch	= 0;
	Cdb_branch_taken= 0;
	end
	if (i<32)
	Cdb_valid	= 1;
	else 
	Cdb_valid	= 0;
end 
// Lectura del estdo de los registros:
Rs_reg_ren = 1;
Rt_reg_ren = 1;
for (i=0; i<40; i=i+1) begin
#10	Rs_reg=i;
	Rs_reg_ren=1;
	Rt_reg=i;
	Rt_reg_ren=1;
`ifdef DEBUG_ROB_TB $display ("------------------------------------------"); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token 	 %d",Rs_token); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_tag 	 %d",Rs_token[5:1]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_valid 	 %d",Rs_token[0]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_Data_spec  %d",Rs_Data_spec); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_Data_valid %d",Rs_Data_valid); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_token 	 %d",Rt_token); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_tag 	 %d",Rt_token[5:1]); `endif
`ifdef DEBUG_ROB_TB $display ("Rs_token_valid 	 %d",Rt_token[0]); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_Data_spec  %d",Rt_Data_spec); `endif
`ifdef DEBUG_ROB_TB $display ("Rt_Data_valid %d",Rt_Data_valid); `endif
`ifdef DEBUG_ROB_TB $display ("------------------------------------------"); `endif
end

#40 $finish;
end

endmodule
