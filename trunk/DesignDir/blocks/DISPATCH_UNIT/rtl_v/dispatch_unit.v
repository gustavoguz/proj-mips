//--------------------------------------------------------------------------------------------------------------------------
// Design Name 	: Dispatch Unit
// File Name   	: dispatch_unit.v
// Function    	: La unidad de despacho es responsable de leer instrucciones del IFQ y enviarlas
//		  a las respectivas colas de ejecución. Dentro de la unidad de despacho las
//		  instrucciones son procesadas una a la vez y en orden de programa. La unidad
//		  de despacho es responsable de las siguientes tareas.
//		  	- Leer la instrucción de la IFQ.
//			- Decodificar las instrucciones.
//			- “Despachar” la instrucciones a la correspondiente cola de ejecución.
//			- Actualizar la tabla de estado de los registros (RST) y el banco de registros.
//			- Calcula las direcciones de brinco para las instrucciones Jump y Branch.
//			- Ejecuta las instrucciones Jump.
//			- Reservar una localidad en el Re-order Buffer
// Coder  	: 
// Other	:
//--------------------------------------------------------------------------------------------------------------------------

module dispatch_unit (
	input			clock,			// Senal de reloj.
	input 			reset,			// Señal de reset.
	// Interface con IFQ:
	input	[ 31:  0]	ifetch_pc_4,		// la instrucción es valida is ‘0’, invalida si ‘1’.
	input	[ 31:  0]	ifetch_intruction, 	// 32 bits de la instrucción.
	input			ifetch_empty,		// la instrucción es valida is ‘0’, invalida si ‘1’.
	output  [ 31:  0]	Dispatch_jmp_addr,	// 32 bit dirección de salto.
	output reg		Dispatch_jmp,		// ‘1’ la instrucción es un jump o un branch que fue tomado.
	output reg		Dispatch_ren,		// si ‘1’ el IFQ incrementa el apuntador de lectura y muestra una nueva instruccion,
							// si ‘0’ el IFQ sigue mostrando la misma instrucción.
	// Interface con Colas de ejecucion:
	// - Señales comunes para todas las colas de ejecución.
	output reg [ 31:  0]	dispatch_rs_data,	// operando rs
	output reg		dispatch_rs_data_valid,	// es „1‟ si rs tiene el ultimo valor, si no „0‟.
	output reg [  4:  0]	dispatch_rs_tag,	// tag para rs.
	output reg [ 31:  0]	dispatch_rt_data,	// operand rt
	output reg 		dispatch_rt_data_valid,	// es „1‟ si rt tiene el ultmo valor, si no „0‟.
	output reg [  4:  0]	dispatch_rt_tag,	// tag para rt
	output  [  4:  0]	dispatch_rd_tag,	// TAG asignado al registro destino de la instrucción
	
	// - Señales especificas para la cola de ejecución de enteros.
	output reg 		dispatch_en_integer,	// unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	input			issueque_integer_full,	// Bandera “llena” de la cola de ejecución de enteros.
	output reg [  3:  0]	dispatch_opcode,	// TODO:revisar si -> 3‐bit opcode para la ALU.
	output reg [  4:  0]	dispatch_shfamt,	// 5-bits en caso de una instrucción del tipo shift
	
	// - Señales especificas para la Cola de ejecución de acceso a memoria.
	output reg		dispatch_en_ld_st,	// DU intenta escribir una instrucción en la cola LD/ST.
	input			issueque_full_ld_st,	// Bandera “llena” de la cola de ejecución LD / ST.
//	output			dispatch_opcode,	// 1 ‐ bit opcode para distinguir entre LD y ST.
	output reg [ 15:  0]	dispatch_imm_ld_st,	// 16 ‐ bit del campo inmediato para calcular la dirección de memoria.

	// - Señales especificas para la Cola de ejecución de multiplicaciones.
	output reg		dispatch_en_mul,	// DU intenta escribir una instrucción en la cola Multiplicación.
	input			issueque_mul_full	// Bandera “llena” de la cola de ejecución Multiplicación.

	);
wire	[  4:  0]	dispatch_shfamt_reg;
wire	[  3:  0]	dispatch_opcode_reg;
wire			dispatch_en_integer_reg;
wire			dispatch_en_ld_st_reg;
wire 	[ 15:  0]	dispatch_imm_ld_st_reg;
wire 			dispatch_en_mul_reg;


reg 	[31: 0]		Data_In;
reg 	[ 4: 0]		Waddr;
reg			W_en;

wire	[31: 0]		RegFile_Rs_reg;
reg	[ 4: 0]		Rs_addr;
wire	[31: 0]		RegFile_Rt_reg;
reg	[ 4: 0]		Rt_addr;
reg 	[25: 0]		address;
reg 			Rs_reg_ren;
reg 			Rt_reg_ren;
reg 	[15: 0]		inmediato;

//wire 	[ 3: 0]		Dispatch_opcode;
//wire	[ 4: 0]		Dispatch_shfamt;
//wire	[31: 0]		Dispatch_Imm_LS;


wire 			Dispatch_Type_R;
wire 			Dispatch_Type_I;
wire 			Dispatch_Type_J;
reg 			Dispatch_Type_R_reg;
reg 			Dispatch_Type_I_reg;
reg 			Dispatch_Type_J_reg;

wire	[31:0]		Jmp_branch_address_br_logic;
wire	[31:0]		Jmp_branch_address_addr_logic;
	
reg 			Rd_en_reg;

wire 	[ 4: 0]		Tag_Out;
wire 			Rs_Data_valid;
wire			Rt_Data_valid;
wire    [31: 0]		Rs_Data_spec;
wire	[31 :0]		Rt_Data_spec;
wire    [ 5: 0]		Rs_token;
wire    [ 5: 0]		Rt_token;

assign Rd_en	= Rd_en_reg;
assign dispatch_rd_tag	= Tag_Out; 
assign Dispatch_jmp_addr = Jmp_branch_address_addr_logic ; // TODO: revisar cunado sea un branch o jmp

always @(posedge clock or posedge reset) begin
	if (reset) begin
	end else begin
	// Lectura de los registros Rs y Rt:
	// -- Del banco de registros.
	Rs_addr		<= ifetch_intruction [25:21]; // Rs
	Rt_addr		<= ifetch_intruction [20:16]; // Rt
	Rs_reg_ren	<= 1;
	Rt_reg_ren	<= 1;
	inmediato	<= ifetch_intruction [15:0]; //TODO: Valor inediato para instrucciones de tipo I se debe hacer extencion de signo
	address		<= ifetch_intruction [25:0]; //26 bits de dirrecion.
	// TODO : Agregar un nuevo dato al rob	
	// señales para todas las colas de ejecusion:
	if (Rs_Data_valid) begin
		dispatch_rs_data 	<= Rs_Data_spec;
		dispatch_rs_data_valid	<= Rs_Data_valid;
		dispatch_rs_tag		<= Rs_token[5:1]; //TODO: validar este dato, puede ser que  no exista el tag
	end else begin
		dispatch_rs_data 	<= RegFile_Rs_reg;
		dispatch_rs_data_valid	<= Rs_Data_valid;
		dispatch_rs_tag		<= Rs_token[5:1]; //TODO: validar este dato, puede ser que  no exita el tag
	end
	
	if (Rt_Data_valid) begin
		dispatch_rt_data 	<= Rt_Data_spec;
		dispatch_rt_data_valid	<= Rt_Data_valid;
		dispatch_rt_tag		<= Rt_token[5:1]; //TODO: validar este dato, puede ser que  no exista el tag
	end else begin
		dispatch_rt_data 	<= RegFile_Rt_reg;
		dispatch_rt_data_valid	<= Rt_Data_valid;
		dispatch_rt_tag		<= Rt_token[5:1]; //TODO: validar este dato, puede ser que  no exista el tag
	end

	if (Dispatch_Type_R) begin
		Rd_en_reg	<= 1;
	end else begin
		Rd_en_reg	<= 0;
	end

	// Señales para cada cola:
	if (!issueque_integer_full) 	begin 
		dispatch_shfamt		<= dispatch_shfamt_reg;
		dispatch_opcode		<= dispatch_opcode_reg;
		dispatch_en_integer	<= dispatch_en_integer_reg;
		Dispatch_ren		<= 1'b1;
		// TODO : Actualizar el rob	
	end else begin
		Dispatch_ren		<= 1'b0;
		// TODO: retener el los datos hasta que haya espacio en las colas
	end
	if (!issueque_full_ld_st) 	begin
		dispatch_en_ld_st	<= dispatch_en_ld_st_reg;
		dispatch_imm_ld_st	<= dispatch_imm_ld_st_reg;
		Dispatch_ren		<= 1'b1;
		// TODO : Actualizar el rob	
	end else begin
		Dispatch_ren		<= 1'b0;
		// TODO: retener el los datos hasta que haya espacio en las colas
	end
	if (!issueque_mul_full) 	begin
		dispatch_en_mul		<= dispatch_en_mul_reg;
		Dispatch_ren		<= 1'b1;
		// TODO : Actualizar el rob	
	end else begin
		Dispatch_ren		<= 1'b0;
		// TODO: retener el los datos hasta que haya espacio en las colas
	end

	end
end


regfile regfile(
	.clock			(clock),
	.reset			(reset),
	.Data_In		(Data_In),
	.Waddr			(Waddr),
	.W_en			(W_en),
	.Data_out1		(RegFile_Rs_reg),
	.Rd_Addr1		(Rs_addr),
	.Data_out2		(RegFile_Rt_reg),
	.Rd_Addr2		(Rt_addr)
	);

Dispatch_Decoder Dispatch_Decoder (
	.Inst			(ifetch_intruction),
	.Dispatch_Opcode	(dispatch_opcode_reg),
	.Dispatch_Shfamt	(dispatch_shfamt_reg),
	.Dispatch_Imm_LS	(dispatch_imm_ld_st_reg), // cuantos bit deberian deser ?
	.Dispatch_en_Int	(dispatch_en_integer_reg),
	.Dispatch_en_LS		(dispatch_en_ld_st_reg),
	.Dispatch_en_Mult	(dispatch_en_mul_reg),	
	.Dispatch_Type_R	(Dispatch_Type_R),
	.Dispatch_Type_I	(Dispatch_Type_I),
	.Dispatch_Type_J	(Dispatch_Type_J)
	);




tagfifo tagfifo(
	.clock			(clock),
	.reset			(!reset),
	.Tag_Out		(Tag_Out),
	.tagFifo_full		(tagFifo_full),
	.tagFifo_empty		(tagFifo_empty),
	.RB_Tag			(RB_Tag),
	.RB_Tag_Valid		(RB_Tag_Valid),
	.Rd_en			(Rd_en)
	);

AddressLogic AddressLogic(
	.is_jump		(Dispatch_Type_J),
	.normal_addr		(normal_addr), /// TODO: que significa esta señal? de donde proviene?
	.pc_plus4		(ifetch_pc_4),  
	.immediate		(immediate),
	.address		(address),
	.Jmp_branch_address	(Jmp_branch_address_addr_logic)
	);

branchlogic  branchlogic (
	.is_jump		(Dispatch_Type_J),
	.pc_plus4		(ifetch_pc_4),
	.immediate		(immediate),
	.address		(address),
	.Jmp_branch_address	(Jmp_branch_address_br_logic)
	);

rob rob (
  	.clock			(clock),
  	.reset			(reset),
	.new_rd_tag		(new_rd_tag),
	.new_rd_tag_valid	(new_rd_tag_valid),
	.Rs_reg			(Rs_addr),
	.Rs_reg_ren		(Rs_reg_ren),
	.Rs_token		(Rs_token),
	.Rs_Data_spec		(Rs_Data_spec),
	.Rs_Data_valid		(Rs_Data_valid),
	.Rt_reg			(Rt_addr),
	.Rt_reg_ren		(Rt_reg_ren),
	.Rt_token		(Rt_token),
	.Rt_Data_spec		(Rt_Data_spec),
	.Rt_Data_valid		(Rt_Data_valid),
	.Dispatch_Rd_tag	(Dispatch_Rd_tag),
	.Dispatch_Rd_reg	(Dispatch_Rd_reg),
	.Dispatch_pc		(Dispatch_pc),
	.Dispatch_inst_type	(Dispatch_inst_type),
	.Cdb_rd_tag		(Cdb_rd_tag),
	.Cdb_valid		(Cdb_valid),
	.Cdb_data		(Cdb_data),
	.Cdb_branch		(Cdb_branch),
	.Cdb_branch_taken	(Cdb_branch_taken),
	.Retire_rd_tag		(Retire_rd_tag),
	.Retire_rd_reg		(Retire_rd_reg),
	.Retire_data		(Retire_data),
	.Retire_pc		(Retire_pc),
	.Retire_branch		(Retire_branch),
	.Retire_branch_taken	(Retire_branch_taken),
	.Retire_store_ready	(Retire_store_ready),
	.Retire_valid		(Retire_valid)
	);

endmodule 
