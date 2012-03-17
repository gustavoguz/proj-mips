//-----------------------------------------------------
// Design Name 	: ROB
// File Name   	: rob.v
// Function    	: Se encarga de que todas las instrucciones sean “retiradas” en el orden del programa
// Coder       	:
// Other	:
//			Dispatch_pc (32) – in // PC de la instruccion a la cual corresponde Rd_tag, en el caso de los
//			branches es la direccion de salto.
//			Dispatch_inst_type (2) – in
//			00 – instruccion donde el rd_tag es válido.
//			01 – branches
//			10 – stores.
//-----------------------------------------------------

module rob (
  	input        	clock,
  	input        	reset,
	input 	[  4:  0]	Rs_reg,
	input 			Rs_reg_ren,
	output 	[  5:  0]	Rs_token,
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

	input 	[  4:  0]	Cdb_rd_tag,//: TAG de 5 bits
	input			Cdb_valid,//: senial que indica si el TAG es válido.
	input	[ 31:  0]	Cdb_data,//: 32 bits del valor que debe de tomar el registro asociado con el TAG.
	input 			Cdb_branch,//: Indica si la instrucción que termino ejecución se trata de un branch.
	input			Cdb_branch_taken,//: „1‟ indica que el branch debe de ser tomado, „0‟ no debe de ser tomado.

	output	[  4:  0]	Retire_rd_tag,// (5) – out
	output	[  4:  0]	Retire_rd_reg,// (5) – out // registro que tiene ser actualizado en el banco de registros
	output	[ 31:  0]	Retire_data,// (32) – out
	output	[ 31:  0]	Retire_pc,// (32) – out // solo tiene sentido en caso de un branch mal predicho.
	output			Retire_branch,// (1) – out // si se trata de un branch la instruccion que fue retirada
	output			Retire_branch_taken,// (1) – out // se el branch tiene que ser tomado (prediccion equivocada)
	output			Retire_store_ready,// (1) – out // si se trata de un store la instruccion que fue retirada
	output			Retire_valid // (1) – out //indica si se esta retirando una instruccion.
	);


//Dispatch consulta estatus de los registros fuente.

wire [72:0] 	Reg_File_Tmp_data_Rs;
wire [72:0] 	Reg_File_Tmp_data_Rt;
wire [ 4:0]	Token_tag_rs;
wire 		Token_valid_rs;
wire [ 4:0]	Token_tag_rt;
wire 		Token_valid_rt;

always @ ( Rs_reg_ren or Rt_reg_ren )begin 
	if ( Rs_reg_ren ) begin 
		Rs_token 	= { Token_tag_rs , Token_valid_rs };
		Rs_Data_spec  	= Reg_File_Tmp_data_Rs [33:2];
		Rs_Data_valid 	= Reg_File_Tmp_data_Rs [1];
	end
	if ( Rt_reg_ren)  begin 
		Rt_token 	= { Token_tag_rt , Token_valid_rt };
		Rt_Data_spec  	= Reg_File_Tmp_data_Rt [33:2];
		Rt_Data_valid	= Reg_File_Tmp_data_Rt [1];
	end
end 

//Dispatch escribe nueva entrada en el ROB
reg [72:0] 	NewEntryData;
reg 		NewEntry;
reg 		UpdateEntry;
reg 		OrderQueueNew_read;
reg 		OrderQueueNew_write;
wire 		OrderQueueFull;
reg 		Wen_rst;

always @(Dispatch_Rd_tag) begin 
	if (!OrderQueueFull) begin
	NewEntry = 1;	
	OrderQueueNew_write = 1;
 	Wen_rst = 1;
	NewEntryData = {Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,32'b0,1'b0,1'b1}; //TODO : que valor deveria tener valid?
			// | rd_reg	| PC     | Inst_type | spec_data | spec_valid | valid |
			// | [72:68]	|[67:36] | [35:34]   |   [33:2]  |   [1]      |  [0]  |
	end else begin
	NewEntry = 0;   
	OrderQueueNew_write = 0;
 	Wen_rst = 0;
	end
end

always @ (posedge clock or posedge reset) 
	if (reset) begin
 		Wen_rst 	= 0;
		NewEntry 	= 0;	
		UpdateEntry 	= 0;	
		NewEntryData	= 0;
		OrderQueueNew_read	= 0;
		OrderQueueNew_write	= 0;
	end else begin
	end
end
rst rst (
	.clock(clock),
  	.reset(reset),
  	.Rsaddr_rst(Rs_reg),
  	.Rstag_rst(Token_tag_rs),
  	.Rsvalid_rst(Token_valid_rs),
  	.Rtaddr_rst(Rt_reg),
  	.Rttag_rst(Token_tag_rt),
  	.Rtvalid_rst(Token_valid_rt),
  	.RB_tag_rst(Cdb_rd_tag),
	.RB_valid_rst(Cdb_valid),
 	.Wdata_rst(Dispatch_Rd_tag),
  	.Waddr_rst(Dispatch_Rd_reg),
	input 	[31:0] 	Wen0_rst(),
	.Wen_rst(Wen_rst),
	output reg [31:0] 	Wen1_rst() 
	);


 36         input   [ 31:  0]       Cdb_data,//: 32 bits del valor que debe de tomar el registro asociado con el TAG.
 37         input                   Cdb_branch,//: Indica si la instrucción que termino ejecución se trata de un branch.
 38         input                   Cdb_branch_taken,//: „1‟ indica que el branch debe de ser tomado, „0‟ no debe de ser tomado.

order_queue order_queue (
	.clock(clock),
	.reset(reset),
	.inData(Dispatch_Rd_tag),
	.new_data(OrderQueueNew_write),
	.out_data(OrderQueueNew_read),
	output	[4: 0] 	outData(),
	.full(OrderQueueFull)
	);

regfiletmp regfiletmp (
	.clock(clock),
	.reset(reset),
	.Data_In(NewEntryData),
	.Waddr(Dispatch_Rd_tag),
	.New_entry(NewEntry),
	input			Update_entry(),
	.Data_out1(Reg_File_Tmp_data_Rs),
	.Rd_Addr1(Rs_reg),
	.Data_out2(Reg_File_Tmp_data_Rt),
	.Rd_Addr2(Rt_reg)
);


endmodule 

