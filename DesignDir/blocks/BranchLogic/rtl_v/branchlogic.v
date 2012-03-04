//-----------------------------------------------------
// Design Name 	: Branch Logic
// File Name   	: branchlogic.v
// Function    	: Las instrucciones del tipo Jump son ejecutadas por la unidad de despacho a lo
//		  igual que el cálculo de las direcciones de salto tanto para Jumps como para
//		  Branches. En caso de un Jump, la dirección es calculada combinatoriamente
//		  (lógica combinacional) y presentada al IFQ ese mismo ciclo.
// Coder  	: 
// Other	:
//-----------------------------------------------------

module  branchlogic (
			input 		is_jump,
			input	[32:0]	pc,
			input	[15:0]	immediate,
			output	[32:0]  Jmp_branch_address
			);

assign Jmp_branch_address = (is_jump) ? pc + (immediate << 2) : pc;
endmodule
