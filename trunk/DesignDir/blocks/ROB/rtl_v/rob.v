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
	input 	[  4:  0]	Rs_reg,// (5) – in
	input 			Rs_reg_ren,// (1) – in
	input  	[  5:  0]	Rs_token,//(6) -- out
	output 	[ 31:  0]	Rs_Data_spec,// (32) -- out
	output 			Rs_Data_valid,// (1) – out // si Rs_Data_valid es „1‟ especulativa en el ROB
	input  	[  4:  0]	Rt_reg,// (5) -- in
	input  			Rt_reg_ren,// (1) – in
	output	[  5:  0]	Rt_token,// (6) -- out
	output	[ 31:  0]	Rt_Data_spec,// (32) -- out
	output			Rt_Data_valid,// (1) – out // si Rt_Data_valid es „1‟ especulativa en el ROB

	input	[  4:  0]	Dispatch_Rd_tag,// (5) – in // el tag asignado por el TAG FIFO, ahora TODAS las instrucciones llevan un TAG.
	input	[  4:  0]	Dispatch_Rd_reg,// (5) – in
	input 	[ 31:  0]	Dispatch_pc,// (32) – in //Ver info arriba
	input	[  1:  0]	Dispatch_inst_type,// (2) – in //Ver info arriba.

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



endmodule 

