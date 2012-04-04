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
	output 			Dispatch_jmp,		// ‘1’ la instrucción es un jump o un branch que fue tomado.
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
	output reg [  4:  0]	dispatch_rd_tag,	// TAG asignado al registro destino de la instrucción
	
	// - Señales especificas para la cola de ejecución de enteros.
	output reg 		dispatch_en_integer_A,	// unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	output reg 		dispatch_en_integer_B,	// unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	input			issueque_integer_full_A,	// Bandera “llena” de la cola de ejecución de enteros.
	input			issueque_integer_full_B,	// Bandera “llena” de la cola de ejecución de enteros.
	output reg [  3:  0]	dispatch_opcode,	// TODO:revisar si -> 3‐bit opcode para la ALU.
	output reg [  4:  0]	dispatch_shfamt,	// 5-bits en caso de una instrucción del tipo shift
	
	// - Señales especificas para la Cola de ejecución de acceso a memoria.
	output reg		dispatch_en_ld_st,	// DU intenta escribir una instrucción en la cola LD/ST.
	input			issueque_full_ld_st,	// Bandera “llena” de la cola de ejecución LD / ST.
	output reg		dispatch_opcode_ld_st,	// 1 ‐ bit opcode para distinguir entre LD y ST.
	output reg [ 15:  0]	dispatch_imm_ld_st,	// 16 ‐ bit del campo inmediato para calcular la dirección de memoria.

	// - Señales especificas para la Cola de ejecución de multiplicaciones.
	output reg		dispatch_en_mul,	// DU intenta escribir una instrucción en la cola Multiplicación.
	input			issueque_mul_full,	// Bandera “llena” de la cola de ejecución Multiplicación.
	
	input 	[  4:  0]	Cdb_rd_tag,
	input			Cdb_valid,
	input	[ 31:  0]	Cdb_data,
	input 			Cdb_branch,
	input			Cdb_branch_taken,
	
	output			flush
	);

// REGISTER FILE :
reg 	[31: 0]		Data_In;
reg 	[ 4: 0]		Waddr;
reg			W_en;

wire	[31: 0]		RegFile_Rs_reg;
reg	[ 4: 0]		Rs_addr;
wire	[31: 0]		RegFile_Rt_reg;
reg	[ 4: 0]		Rt_addr;

// DECODER :
wire	[  3:  0]	dispatch_opcode_reg;
wire	[  4:  0]	dispatch_shfamt_reg;
wire 	[ 31:  0]	dispatch_imm_ld_st_reg;
wire			dispatch_en_ld_st_reg;
wire			dispatch_en_integer_reg;
wire 			dispatch_en_mul_reg;
wire 			Dispatch_Type_R;
wire 			Dispatch_Type_I;
wire 			Dispatch_Type_J;
wire 			Dispatch_Branch;

reg	[  3:  0]	opcode_reg;
reg	[  4:  0]	shfamt_reg;
reg 	[ 31:  0]	imm_ld_st_reg;
reg			en_ld_st_reg;
reg			en_integer_reg;
reg 			en_mul_reg;

//  ROB :

reg 			new_rd_tag;
reg			new_rd_tag_valid;
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
/*
reg 	[  4:  0]	Cdb_rd_tag;
reg			Cdb_valid;
reg	[ 31:  0]	Cdb_data;
reg 			Cdb_branch;
reg			Cdb_branch_taken;
*/
wire	[  4:  0]	Retire_rd_tag;
wire	[  4:  0]	Retire_rd_reg;
wire	[ 31:  0]	Retire_data;
wire	[ 31:  0]	Retire_pc;
wire			Retire_branch;
wire			Retire_branch_taken;
wire			Retire_store_ready;
wire			Retire_valid;

reg	[31:0]		rs_data;
reg			rs_data_valid;
reg	[4:0]		rs_tag;
reg	[31:0]		rt_data;
reg			rt_data_valid;
reg	[4:0]		rt_tag;
reg	[4:0]		rd_tag;
reg	[31:0]		rs_data_reg;
reg			rs_data_valid_reg;
reg	[4:0]		rs_tag_reg;
reg	[31:0]		rt_data_reg;
reg			rt_data_valid_reg;
reg	[4:0]		rt_tag_reg;
reg	[4:0]		rd_tag_reg;

// LRU

reg 			intfull_0;
reg			intfull_1;
reg			last;	
wire			next;

// TAG FIFO :

reg	[4:0]  		RB_Tag;
reg 			RB_Tag_Valid;
reg 			Rd_en;
reg			increment;
wire 	[4:0] 		Tag_Out;
wire 			tagFifo_full;
wire 			tagFifo_empty;

// BRANCH LOGIC :
//reg	 	        is_jump;
//reg	[31:0]		pc_plus4;  
//reg	[15:0]	 	immediate;
//reg	[25:0]		address;
wire	[31:0]		Jmp_branch_address;

reg	[31:0] 		ifetch_pc_4_reg;
reg new_instruction;
reg new_instruction_reg;

assign Dispatch_jmp = (Dispatch_Type_J | Retire_branch_taken);
assign Dispatch_jmp_addr = (Retire_branch)? Retire_pc : Jmp_branch_address;


reg [4:0] temp ;
/*
always @(posedge clock or posedge reset) begin
	if (reset) begin
		new_rd_tag <= 0;
	end else begin
		new_rd_tag <= new_instruction;
	end
end
*/

// Nueva instruccion al rob 
always @(posedge new_instruction or posedge reset) begin
	if (reset) begin
	end else if (new_instruction) begin
		$display("INFO : DISPATCHER :  NEW INSTRUCTION TO ROB");
		Dispatch_Rd_tag		<= Tag_Out;
		if (Dispatch_Type_R) begin
			Dispatch_Rd_reg		<= ifetch_intruction[15:11];
			Dispatch_inst_type	<= 2'b00;
		end
		if (Dispatch_Type_I) begin
			Dispatch_Rd_reg		<= ifetch_intruction[20:16];
			if (!dispatch_opcode_reg[0])
			Dispatch_inst_type	<= 2'b10;
			else
			Dispatch_inst_type	<= 2'b11;
		end
		if (Dispatch_Branch) begin
			Dispatch_pc		<= Jmp_branch_address;
			Dispatch_inst_type	<= 2'b01;
		end else begin
			Dispatch_pc		<= ifetch_pc_4;
		end
		new_rd_tag_valid	<= 1;
	end
end

// retirar 
always @(posedge clock or posedge reset) begin
	if (reset) begin
	end  else if (Retire_valid) begin 
	$display (" -------------RETIRE -----");
	$display (" -------------RETIRE -----");
	$display (" -------------RETIRE -----");
	$display (" -------------RETIRE -----");
	$display (" -------------RETIRE -----");
	RB_Tag_Valid		<= 1;
	W_en			<= 1;
	RB_Tag 			<= Retire_rd_tag;
	Waddr			<= Retire_rd_reg;
	Data_In 		<= Retire_data;
	// TODO: retirar el branch:
	//Retire_pc;
	//Retire_branch;
	//Retire_branch_taken;
	//Retire_store_ready;
	
	end else begin
	Waddr			<= 0;
	Data_In 		<= 0;
	//Rd_en			<= 0;
	W_en			<= 0;
	end
end 

always @(posedge clock or posedge reset) begin
	if (reset) begin
		new_instruction_reg <= 0;
	end else begin
		new_instruction_reg <= new_instruction;
	end
end

always @(posedge clock or posedge reset) begin
	if (reset) begin
		ifetch_pc_4_reg <= 100;
		new_instruction <= 0;
	end else begin
		ifetch_pc_4_reg <= ifetch_pc_4;
		if (ifetch_pc_4_reg != ifetch_pc_4) begin
			new_instruction <= 1;
		end else 
			new_instruction <= 0;
	end
end

always @* begin
 	Rs_reg_ren 	= new_instruction;
 	Rt_reg_ren 	= new_instruction;
	increment	= new_instruction;
	new_rd_tag 	= new_instruction;
	if(Dispatch_Type_R && !issueque_integer_full_A && !issueque_integer_full_B && !issueque_full_ld_st && !issueque_mul_full)	
		Rd_en		= new_instruction;
	else 
		Rd_en		= 0;
	// si las colas estan llenas no se piede una nueva instruccion,
	if (!issueque_integer_full_A && !issueque_integer_full_B && !issueque_full_ld_st && !issueque_mul_full)	
		Dispatch_ren	= 1;
	else 
		Dispatch_ren	= 0;

end

always @(posedge new_instruction) begin
	// Read Rs and Rt 
	$display ("INFO : DISPATCHER : Reading Registers: Rs %d and Rt %d", ifetch_intruction [25:21],ifetch_intruction [20:16]);
	Rs_addr 	<= ifetch_intruction [25:21]; // Rs; 
	Rt_addr 	<= ifetch_intruction [20:16]; // Rt;
	rd_tag 		<= Tag_Out;
end
	
always @(posedge new_instruction or posedge new_instruction_reg) begin
	
	if (Rs_Data_valid) begin
	rs_data <= Rs_Data_spec;
	rs_tag  <= Rs_token[5:1];
	rs_data_valid <= Rs_Data_valid;
	end else begin
	rs_data <= RegFile_Rs_reg;
	rs_tag  <= 0;
	rs_data_valid <=1;
	end

	if (Rt_Data_valid) begin
	rt_data <= Rt_Data_spec;
	rt_tag  <= Rt_token[5:1];
	rt_data_valid =Rt_Data_valid;
	end else begin
		if (Dispatch_Type_I) begin
			rt_data <=  ifetch_intruction [15:0];
		end else begin
			rt_data <= RegFile_Rt_reg;
			rt_tag  <= 0;
			rt_data_valid <=1;
		end
	end
end

always @* begin
		$display ("INFO : DISPATCHER : -------- Sending information to queue I ------------");	
		$display ("---> rs_data       %d",rs_data);
		$display ("---> rs_data_valid %d",rs_data_valid);
		$display ("---> rs_tag        %d",rs_tag);
		$display ("---> rt_data       %d",rt_data);
		$display ("---> rt_data_valid %d",rt_data_valid);
		$display ("---> rt_tag        %d",rt_tag);
		$display ("---> rd_tag        %d",rd_tag);
		
		dispatch_rs_data 	= rs_data;
		dispatch_rs_data_valid	= rs_data_valid;
		dispatch_rs_tag		= rs_tag;

		dispatch_rt_data	= rt_data;
		dispatch_rt_data_valid	= rt_data_valid;
		dispatch_rt_tag		= rt_tag;

		dispatch_rd_tag		= rd_tag;
end

always @ (posedge new_instruction_reg or posedge reset) begin
	// - Señales comunes para todas las colas de ejecución.
	if (reset) begin
		last <= 0;
	end else begin 
/*
		$display ("INFO : DISPATCHER : -------- Sending information to queue I ------------");	
		$display ("---> rs_data       %d",rs_data);
		$display ("---> rs_data_valid %d",rs_data_valid);
		$display ("---> rs_tag        %d",rs_tag);
		$display ("---> rt_data       %d",rt_data);
		$display ("---> rt_data_valid %d",rt_data_valid);
		$display ("---> rt_tag        %d",rt_tag);
		$display ("---> rd_tag        %d",rd_tag);
		
		dispatch_rs_data 	<= rs_data;
		dispatch_rs_data_valid	<= rs_data_valid;
		dispatch_rs_tag		<= rs_tag;

		dispatch_rt_data	<= rt_data;
		dispatch_rt_data_valid	<= rt_data_valid;
		dispatch_rt_tag		<= rt_tag;

		dispatch_rd_tag		<= rd_tag;
*/		
		// - Señales especificas para la cola de ejecución de enteros.
		//if (!issueque_integer_full_A && !issueque_integer_full_B) begin
			//dispatch_en_integer	<= dispatch_en_integer_reg;
			if (dispatch_en_integer_reg && (!issueque_integer_full_A && !issueque_integer_full_B)) begin	
				last			<= next;
				if (next)	begin
					dispatch_en_integer_A	<= 1;
					dispatch_en_integer_B	<= 0;
				end else begin
					dispatch_en_integer_A	<= 0;
					dispatch_en_integer_B	<= 1;
				end
			end else begin
				dispatch_en_integer_A	<= 0;
				dispatch_en_integer_B	<= 0;
			end
			dispatch_opcode		<= dispatch_opcode_reg;
			dispatch_shfamt		<= dispatch_shfamt_reg;
		//end
		// - Señales especificas para la Cola de ejecución de acceso a memoria.
		if (!issueque_full_ld_st) begin
			dispatch_en_ld_st	<= dispatch_en_ld_st_reg;
			dispatch_imm_ld_st	<= dispatch_imm_ld_st_reg;
			dispatch_opcode_ld_st	<= dispatch_opcode_reg[0];
		end
			// - Señales especificas para la Cola de ejecución de multiplicaciones.
		if (!issueque_mul_full) begin
			dispatch_en_mul		<= dispatch_en_mul_reg;
		end
		/*
		// si las colas estan llenas no se piede una nueva instruccion,
		if (!issueque_integer_full && !issueque_full_ld_st && !issueque_mul_full)	
			Dispatch_ren	<= 1;
		else 
			Dispatch_ren	<= 0;
		*/
	end 
end
/*
always @(posedge clock or posedge reset ) begin
	if (reset) begin 
	rs_data_reg		<= 0;
	rs_data_valid_reg	<= 0;
	rs_tag_reg		<= 0;
	rt_data_reg		<= 0;
	rt_data_valid_reg	<= 0;
	rt_tag_reg		<= 0;
	rd_tag_reg		<= 0;
	opcode_reg 		<= 0;
	shfamt_reg 		<= 0;
	en_ld_st_reg 		<= 0;
	imm_ld_st_reg 		<= 0;
	en_mul_reg		<= 0;
	en_integer_reg		<= 0;	
	
	end else begin

	rs_data_reg		<= rs_data;
	rs_data_valid_reg	<= rs_data_valid;
	rs_tag_reg		<= rs_tag;
	rt_data_reg		<= rt_data;
	rt_data_valid_reg	<= rt_data_valid;
	rt_tag_reg		<= rt_tag;
	rd_tag_reg		<= rd_tag;
	opcode_reg 		<= dispatch_opcode_reg;
	shfamt_reg 		<= dispatch_shfamt_reg;
	en_ld_st_reg 		<= dispatch_en_ld_st_reg;
	imm_ld_st_reg 		<= dispatch_imm_ld_st_reg;
	en_mul_reg		<= dispatch_en_mul_reg;
	en_integer_reg		<= dispatch_en_integer_reg;	
	end
end
*/
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
	.Dispatch_Imm_LS	(dispatch_imm_ld_st_reg), 
	.Dispatch_en_Int	(dispatch_en_integer_reg),
	.Dispatch_en_LS		(dispatch_en_ld_st_reg),
	.Dispatch_en_Mult	(dispatch_en_mul_reg),	
	.Dispatch_Type_R	(Dispatch_Type_R),
	.Dispatch_Type_I	(Dispatch_Type_I),
	.Dispatch_Type_J	(Dispatch_Type_J),
	.Dispatch_Branch	(Dispatch_Branch)
	);

tagfifo tagfifo(
	.clock			(clock),
	.reset			(!reset),
	.Tag_Out		(Tag_Out),
	.tagFifo_full		(tagFifo_full),
	.tagFifo_empty		(tagFifo_empty),
	.RB_Tag			(RB_Tag),
	.RB_Tag_Valid		(RB_Tag_Valid),
	.Rd_en			(Rd_en),
	.increment		(increment)
	);

branchlogic  branchlogic (
	.is_jump		(Dispatch_Type_J),
	.pc_plus4		(ifetch_pc_4),
	.immediate		(ifetch_intruction [15:0]),
	.address		(ifetch_intruction [25:0]),
	.Jmp_branch_address	(Jmp_branch_address)
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
	.Retire_valid		(Retire_valid),
	.flush_flag		(flush)
	/// TODO: el flush debe salir del rob +

	);

lru lru (
	.intfull_0		(issueque_integer_full_A),
	.intfull_1		(issueque_integer_full_B),
	.last			(last),
	.next			(next)
	);
endmodule 
