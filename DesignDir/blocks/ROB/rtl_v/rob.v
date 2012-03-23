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
//
//		Notas: "Estructura del Reg_File_Tmp:"
//			 | rd_reg	| PC     | Inst_type | spec_data | spec_valid | valid |
//			 | [72:68]	|[67:36] | [35:34]   |   [33:2]  |   [1]      |  [0]  |
//-----------------------------------------------------

module rob (
  	input        	clock,
  	input        	reset,
	input 		new_rd_tag,
	input 		new_rd_tag_valid,
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

//Dispatch escribe nueva entrada en el ROB
reg [72:0] 	NewEntryData;
reg 		NewEntry;
reg 		Update_entry;
reg 		OrderQueueNew_read;
reg 		OrderQueueNew_write;
reg  [ 4:0]	OrderQueueDataIn;
wire 		OrderQueueFull;
wire 		OrderQueueEmpty;
reg 		Wen_rst;
wire [31:0]	Wen1_rst;
wire [ 4:0] 	OrderQueue_data;
reg  [ 4:0] 	AddrRFT;
reg  [ 4:0] 	Retire_rd_tag_reg;
reg 		Retire_valid_reg;

reg RequestQueryRs;
reg RequestQueryRt;
reg RequestUpdate;
reg RequestAddNew;
reg RequestRetire;

reg RequestAddNew_reg;
reg RequestQueryRs_reg;
reg RequestQueryRt_reg;
reg RequestUpdate_reg;
reg OrderQueueNew_write_reg; 

//always @ ( Rs_reg or Rt_reg) begin 
always @ * begin 
	if ( Rs_reg_ren ) begin 
		RequestQueryRs = 1;
		`ifdef DEBUG_ROB $display ("INFO : ROB : Request Query Rs"); `endif
	end else
		RequestQueryRs = RequestQueryRs_reg;
	

	if ( Rt_reg_ren)  begin 
		RequestQueryRt = 1;
		`ifdef DEBUG_ROB $display ("INFO : ROB : Request Query Rt"); `endif
	end else 
		RequestQueryRt = RequestQueryRt_reg;
end

always @* begin 
	if (!OrderQueueFull && new_rd_tag && new_rd_tag_valid) begin
		RequestAddNew = 1;
		`ifdef DEBUG_ROB $display ("INFO : ROB : Request Add New R"); `endif
	end else begin
		RequestAddNew = RequestAddNew_reg;
	end
end

always @* begin
	if (Cdb_valid) begin // check si tiene que validarse este bit.
		RequestUpdate=1;
		OrderQueueNew_read=0;
		`ifdef DEBUG_ROB $display ("INFO : ROB : Request Update R"); `endif
	end else begin
		RequestUpdate=RequestUpdate_reg;
		OrderQueueNew_read=0;
	end
end

always @(Reg_File_Tmp_data_Rs or Reg_File_Tmp_data_Rt) begin
	if(Reg_File_Tmp_data_Rs[0] || Reg_File_Tmp_data_Rt[0]) begin 
		RequestRetire=1;
		`ifdef DEBUG_ROB $display ("INFO : ROB : Request Retire"); `endif
	end else begin
		RequestRetire=0;
		//OrderQueueNew_read=0;
	end
end

// Control del ROB
always @ (posedge clock or posedge reset) begin
	if (reset) begin
/* 		Wen_rst 	<= 0;
		NewEntry 	<= 0;	
		Update_entry 	<= 0;	
		NewEntryData	<= 0;
		OrderQueueNew_read	<= 0;
		OrderQueueNew_write	<= 0;
		RequestQueryRs <= 0;
		RequestQueryRt <= 0;
		RequestAddNew  <= 0;
		Retire_rd_tag_reg <= 0; // de dondse obtienen estos valores ? para retirar
		Retire_valid_reg  <= 0; // 
*/	end else begin
		if (RequestQueryRt) begin
		`ifdef DEBUG_ROB $display("INFO : ROB : Request Query Rt "); `endif
		Rt_token 	<= { Token_tag_rt , Token_valid_rt };
		Rt_Data_spec  	<= Reg_File_Tmp_data_Rt [33:2];
		Rt_Data_valid	<= Reg_File_Tmp_data_Rt [1];
		RequestQueryRt_reg	<= 0;
		OrderQueueNew_write  <= 0; // Order queue : write enable
		end
		if (RequestQueryRs) begin
		`ifdef DEBUG_ROB $display("INFO : ROB : Request Query Rs "); `endif
		Rs_token 	<= { Token_tag_rs , Token_valid_rs };
		Rs_Data_spec  	<= Reg_File_Tmp_data_Rs [33:2];
		Rs_Data_valid 	<= Reg_File_Tmp_data_Rs [1];
		RequestQueryRs_reg	<= 0;
		OrderQueueNew_write  <= 0; // Order queue : write enable
		end
		if (RequestUpdate) begin
		`ifdef DEBUG_ROB $display("INFO : ROB : Update_entry %d %d", Cdb_rd_tag,Cdb_data); `endif
 		Wen_rst 	<= 0; // RST : write enable
		NewEntry	<= 0; // Register file temp : write enable
		OrderQueueNew_write  <= 0; // Order queue : write enable
		Update_entry 	<=1;
		AddrRFT		<= Cdb_rd_tag;	
		NewEntryData <= {Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,Cdb_data,Cdb_valid,1'b1};
		RequestUpdate_reg <= 0;
		RequestAddNew_reg	<= 0;
		end else if (RequestAddNew) begin 
		`ifdef DEBUG_ROB $display("INFO : ROB : Add new entry"); `endif
 		Wen_rst 	<= 1; // RST : write enable
		NewEntry	<= 1; // Register file temp : write enable
		OrderQueueNew_write <= 1; // Order queue : write enable
		Update_entry 	<= 0;
		AddrRFT		<= Dispatch_Rd_tag;	
		NewEntryData  	<= {Dispatch_Rd_reg,Dispatch_pc,Dispatch_inst_type,32'b0,1'b0,1'b1}; // nuevo valor para le regsiter file temp 
		OrderQueueDataIn<= Dispatch_Rd_tag; // nuevo valor para la rder queue;
		RequestAddNew_reg	<= 0;
		RequestUpdate_reg <= 0;
		$display ("+++++++++++++++++++++++++++++++++++++++++++++>dispatch tag = %d <",Dispatch_Rd_tag);
		end
		if (RequestRetire) begin 
		OrderQueueNew_read<=0;
		//OrderQueueNew_read<=1;
		/*if (OrderQueue_data == Rt_reg) begin
		`ifdef DEBUG_ROB $display("INFO : ROB : Retire tag %d ", OrderQueue_data); `endif
 		Retire_rd_tag 	<= OrderQueue_data;
 		Retire_rd_reg 	<= Reg_File_Tmp_data_Rt[72:68];
 		Retire_data	<= Reg_File_Tmp_data_Rt[33: 2];
		Retire_pc	<= Reg_File_Tmp_data_Rt[67:36];
		Retire_branch	<= Cdb_branch;
 		Retire_valid 	<= 1'b1;
		Retire_branch_taken <= Cdb_branch_taken;
 		Retire_store_ready  <=  (Reg_File_Tmp_data_Rt[35:34]==2'b10)? 1: 0;
		Retire_rd_tag_reg <=  Reg_File_Tmp_data_Rt[72:68];
		Retire_valid_reg  <= 1; 
		OrderQueueNew_write  <= 0; // Order queue : write enable
		end*/
	/*	if (OrderQueue_data == Rs_reg) begin
		`ifdef DEBUG_ROB $display("INFO : ROB : Retire tag %d ", OrderQueue_data); `endif
 		Retire_rd_tag 	<= OrderQueue_data;
 		Retire_rd_reg 	<= Reg_File_Tmp_data_Rs[72:68];
 		Retire_data	<= Reg_File_Tmp_data_Rs[33: 2];
		Retire_pc	<= Reg_File_Tmp_data_Rs[67:36];
		Retire_branch	<= Cdb_branch;
 		Retire_valid 	<= 1'b1;
		Retire_branch_taken <= Cdb_branch_taken;
 		Retire_store_ready  <=  (Reg_File_Tmp_data_Rs[35:34]==2'b10)? 1: 0;
		Retire_rd_tag_reg <=  Reg_File_Tmp_data_Rs[72:68]; 
		Retire_valid_reg  <= 1; 
		OrderQueueNew_write  <= 0; // Order queue : write enable
		end
	*/	end
	end
end

rst rst (
	.clock		(clock),
  	.reset		(reset),
  	.Rsaddr_rst	(Rs_reg),
  	.Rstag_rst	(Token_tag_rs),
  	.Rsvalid_rst	(Token_valid_rs),
  	.Rtaddr_rst	(Rt_reg),
  	.Rttag_rst	(Token_tag_rt),
  	.Rtvalid_rst	(Token_valid_rt),
  	.RB_tag_rst(Retire_rd_tag_reg),
	.RB_valid_rst(Retire_valid_reg),
 	.Wdata_rst	(Dispatch_Rd_tag),
  	.Waddr_rst	(Dispatch_Rd_reg), // TODO: checkar si se direcciona con el registro.
	.Wen0_rst	(0),
	.Wen_rst	(Wen_rst),
	.Wen1_rst	(Wen1_rst) 
	);

order_queue order_queue (
	.clock		(clock),
	.reset		(reset),
	.inData		(OrderQueueDataIn),
	.new_data	(OrderQueueNew_write), 
	.out_data	(OrderQueueNew_read),
	.outData	(OrderQueue_data),
	.full		(OrderQueueFull),
	.empty		(OrderQueueEmpty)
	);

regfiletmp regfiletmp (
	.clock		(clock),
	.reset		(reset),
	.Data_In	(NewEntryData),
	.Waddr		(AddrRFT),
	.New_entry	(NewEntry),
	.Update_entry	(Update_entry),
	.Data_out1	(Reg_File_Tmp_data_Rs),
	.Rd_Addr1	(Rs_reg),
	.Data_out2	(Reg_File_Tmp_data_Rt),
	.Rd_Addr2	(Rt_reg)
);

endmodule 
