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
	output reg 	[  5:  0]	Rs_token,
	output reg 	[ 31:  0]	Rs_Data_spec,
	output reg 			Rs_Data_valid,
	input  	[  4:  0]	Rt_reg,
	input  			Rt_reg_ren,
	output reg	[  5:  0]	Rt_token,
	output reg	[ 31:  0]	Rt_Data_spec,
	output reg			Rt_Data_valid,

	input	[  4:  0]	Dispatch_Rd_tag,
	input	[  4:  0]	Dispatch_Rd_reg,
	input 	[ 31:  0]	Dispatch_pc,
	input	[  1:  0]	Dispatch_inst_type,

	input 	[  4:  0]	Cdb_rd_tag,//: TAG de 5 bits
	input			Cdb_valid,//: senial que indica si el TAG es válido.
	input	[ 31:  0]	Cdb_data,//: 32 bits del valor que debe de tomar el registro asociado con el TAG.
	input 			Cdb_branch,//: Indica si la instrucción que termino ejecución se trata de un branch.
	input			Cdb_branch_taken,//: „1‟ indica que el branch debe de ser tomado, „0‟ no debe de ser tomado.

	output reg	[  4:  0]	Retire_rd_tag,// (5) – out
	output reg	[  4:  0]	Retire_rd_reg,// (5) – out // registro que tiene ser actualizado en el banco de registros
	output reg	[ 31:  0]	Retire_data,// (32) – out
	output reg	[ 31:  0]	Retire_pc,// (32) – out // solo tiene sentido en caso de un branch mal predicho.
	output reg			Retire_branch,// (1) – out // si se trata de un branch la instruccion que fue retirada
	output reg			Retire_branch_taken,// (1) – out // se el branch tiene que ser tomado (prediccion equivocada)
	output reg			Retire_store_ready,// (1) – out // si se trata de un store la instruccion que fue retirada
	output reg			Retire_valid // (1) – out //indica si se esta retirando una instruccion.
	);


//Dispatch consulta estatus de los registros fuente.

wire [72:0] 	Reg_File_Tmp_data_Rs;
wire [72:0] 	Reg_File_Tmp_data_Rt;
wire [ 4:0]	Token_tag_rs;
wire 		Token_valid_rs;
wire [ 4:0]	Token_tag_rt;
wire 		Token_valid_rt;

always @ ( Rs_reg or Rt_reg) begin 
	if ( Rs_reg_ren ) begin 
		$display ("INFO : ROB : Consulta Rs_reg");
		Rs_token 	= { Token_tag_rs , Token_valid_rs };
		Rs_Data_spec  	= Reg_File_Tmp_data_Rs [33:2];
		Rs_Data_valid 	= Reg_File_Tmp_data_Rs [1];
	end
	if ( Rt_reg_ren)  begin 
		$display ("INFO : ROB : Consulta Rt_reg");
		Rt_token 	= { Token_tag_rt , Token_valid_rt };
		Rt_Data_spec  	= Reg_File_Tmp_data_Rt [33:2];
		Rt_Data_valid	= Reg_File_Tmp_data_Rt [1];
	end
end 

//Dispatch escribe nueva entrada en el ROB
reg [72:0] 	NewEntryData;
reg 		NewEntry;
reg 		Update_entry;
reg 		OrderQueueNew_read;
reg 		OrderQueueNew_write;
wire 		OrderQueueFull;
wire 		OrderQueueEmpty;
reg 		Wen_rst;
wire [31:0]	Wen1_rst;
wire [ 4:0] 	OrderQueue_data;
//Nuevo dato en cdb, se tiene que actualizar el RefFileTmp
always @(Cdb_data) begin
	if (Cdb_valid) begin
	Update_entry=1;//TODO: esta bandera se tiene que poner en 0 una vez que se completo el update
	NewEntryData = {Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,Cdb_data,Cdb_valid,1'b1};
	Update_entry=0;
	$display("INFO : ROB : UpdateEntry 
				{Dispatch_Rd_reg=%d,
				Dispatch_pc=%d,
				Dispatch_inst_type=%d,
				spec_data=%d,
				spec_valid=%d,
				valid=1'b1}",
				Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,Cdb_data,Cdb_valid);
	end else begin
	Update_entry =0;
	end
end
 
always @(Dispatch_Rd_tag) begin 
	if (!OrderQueueFull) begin
	NewEntry = 1;	
	OrderQueueNew_write = 1;
 	Wen_rst = 1;
	NewEntryData = {Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,32'b0,1'b0,1'b0}; 
			// | rd_reg	| PC     | Inst_type | spec_data | spec_valid | valid |
			// | [72:68]	|[67:36] | [35:34]   |   [33:2]  |   [1]      |  [0]  |
	$display ("INFO : ROB : NewEntryData 
				{Dispatch_Rd_reg=%d,
				Dispatch_pc=%d,
				Dispatch_inst_type=%d,
				spec_data=32'b0,
				spec_valid=1'b0,
				valid=1'b0}",Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type);
	end else begin
	$display ("INFO : Orderqueue is full");
	NewEntry = 0;   
	OrderQueueNew_write = 0;
 	Wen_rst = 0;
	end
end
// retirar 

always @(Reg_File_Tmp_data_Rs or Reg_File_Tmp_data_Rt) begin
	OrderQueueNew_read=0;
	if(Reg_File_Tmp_data_Rs[0] || Reg_File_Tmp_data_Rt[0]) begin 
		if ((OrderQueue_data == Rs_reg) || (OrderQueue_data==Rt_reg)) begin
 		Retire_rd_tag 	= OrderQueue_data;
 		Retire_rd_reg 	= Reg_File_Tmp_data_Rt[72:68];
 		Retire_data	= Reg_File_Tmp_data_Rt[33: 2];
		Retire_pc	= Reg_File_Tmp_data_Rt[67:36];
		Retire_branch	= Cdb_branch;
 		Retire_valid 	= 1'b1;
		Retire_branch_taken = Cdb_branch_taken;
 		Retire_store_ready  =  (Reg_File_Tmp_data_Rt[35:34]==2'b10)? 1: 0;
		end
	end
end

always @ (posedge clock or posedge reset) begin
	if (reset) begin
 		Wen_rst 	<= 0;
		NewEntry 	<= 0;	
		Update_entry 	<= 0;	
		NewEntryData	<= 0;
		OrderQueueNew_read	<= 0;
		OrderQueueNew_write	<= 0;
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
	.Wen0_rst(0),
	.Wen_rst(Wen_rst),
	.Wen1_rst(Wen1_rst) 
	);



order_queue order_queue (
	.clock		(clock),
	.reset		(reset),
	.inData		(Dispatch_Rd_tag),
	.new_data	(OrderQueueNew_write),
	.out_data	(OrderQueueNew_read),
	.outData	(OrderQueue_data),
	.full		(OrderQueueFull),
	.empty		(OrderQueueEmpty)
	);

regfiletmp regfiletmp (
	.clock(clock),
	.reset(reset),
	.Data_In(NewEntryData),
	.Waddr(Dispatch_Rd_tag),
	.New_entry(NewEntry),
	.Update_entry(Update_entry),
	.Data_out1(Reg_File_Tmp_data_Rs),
	.Rd_Addr1(Rs_reg),
	.Data_out2(Reg_File_Tmp_data_Rt),
	.Rd_Addr2(Rt_reg)
);

endmodule 
