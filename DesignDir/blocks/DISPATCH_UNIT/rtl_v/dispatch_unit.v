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
	input	[ 32:  0]	ifetch_pc_4,		// la instrucción es valida is ‘0’, invalida si ‘1’.
	input	[ 32:  0]	ifetch_intruction, 	// 32 bits de la instrucción.
	input			ifetch_empty,		// la instrucción es valida is ‘0’, invalida si ‘1’.
	output	[ 32:  0]	Dispatch_jmp_addr,	// 32 bit dirección de salto.
	output			Dispatch_jmp,		// ‘1’ la instrucción es un jump o un branch que fue tomado.
	output			Dispatch_ren,		// si ‘1’ el IFQ incrementa el apuntador de lectura y muestra una nueva instruccion,
							// si ‘0’ el IFQ sigue mostrando la misma instrucción.
	// Interface con Colas de ejecucion:
	// - Señales comunes para todas las colas de ejecución.
	output	[ 32:  0]	dispatch_rs_data,	// operando rs
	output			dispatch_rs_data_valid,	// es „1‟ si rs tiene el ultimo valor, si no „0‟.
	output	[  4:  0]	dispatch_rs_tag,	// tag para rs.
	output	[ 32:  0]	dispatch_rt_data,	// operand rt
	output			dispatch_rt_data_valid,	// es „1‟ si rt tiene el ultmo valor, si no „0‟.
	output	[  4:  0]	dispatch_rt_tag,	// tag para rt
	output	[  4:  0]	dispatch_rd_tag,	// TAG asignado al registro destino de la instrucción
	
	// - Señales especificas para la cola de ejecución de enteros.
	output  		dispatch_en_integer,	// unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	input			issueque_integer_full,	// Bandera “llena” de la cola de ejecución de enteros.
	output	[  2:  0]	dispatch_opcode,	// TODO:revisar si -> 3‐bit opcode para la ALU.
	output	[  4:  0]	dispatch_shfamt,	// 5-bits en caso de una instrucción del tipo shift
	
	// - Señales especificas para la Cola de ejecución de acceso a memoria.
	output			dispatch_en_ld_st,	// DU intenta escribir una instrucción en la cola LD/ST.
	input			issueque_full_ld_st,	// Bandera “llena” de la cola de ejecución LD / ST.
//	output			dispatch_opcode,	// 1 ‐ bit opcode para distinguir entre LD y ST.
	output	[ 15:  0]	dispatch_imm_ld_st,	// 16 ‐ bit del campo inmediato para calcular la dirección de memoria.

	// - Señales especificas para la Cola de ejecución de multiplicaciones.
	output			dispatch_en_mul,	// DU intenta escribir una instrucción en la cola Multiplicación.
	input			issueque_mul_full	// Bandera “llena” de la cola de ejecución Multiplicación.

	);

regfile regfile(
	.clock			(clock),
	.reset			(reset),
	.Data_In		(Data_In),
	.Waddr			(Waddr),
	.W_en			(W_en),
	.Data_out1		(Data_out1),
	.Rd_Addr1		(Rd_Addr1),
	.Data_out2		(Data_out2),
	.Rd_Addr2		(Rd_Addr2)
	);

decoder decoder (
	.clock			(clock),
	.reset			(reset),
	.Inst			(Inst),
	.Dispatch_opcode	(Dispatch_opcode),
	.Dispatch_shfamt	(Dispatch_shfamt),
	.Dispatch_en_integer	(Dispatch_en_integer),
	.Dispatch_en_ld_st	(Dispatch_en_ld_st),
	.Dispatch_imm_ld_st	(Dispatch_imm_ld_st),
	.Dispatch_en_mult	(Dispatch_en_mult)
	);

tagfifo tagfifo(
	.clock			(clock),
	.reset			(reset),
	.Tag_Out		(Tag_Out),
	.tagFifo_full		(tagFifo_full),
	.tagFifo_empty		(tagFifo_empty),
	.RB_Tag			(RB_Tag),
	.RB_Tag_Valid		(RB_Tag_Valid),
	.Rd_en			(Rd_en)
	);

branchlogic  branchlogic (
	.is_jump		(is_jump),
	.pc			(pc),
	.immediate		(immediate),
	.Jmp_branch_address	(Jmp_branch_address)
	);

rob rob (
	.Rs_reg			(Rs_reg),
	.Rs_reg_ren		(Rs_reg_ren),
	.Rs_token		(Rs_token),
	.Rs_Data_spec		(Rs_Data_spec),
	.Rs_Data_valid		(Rs_Data_valid),
	.Rt_reg			(Rt_reg),
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
