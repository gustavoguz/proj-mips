i_cache i_cache  (
        .clk   		(clk),
        .reset 		(reset),
        .Pc_in 		(Pc_in),
        .Rd_en 		(Rd_en_cache),
        .Dout  		(Dout),
        .Dout_valid 	(Dout_valid)
         );


ifq ifq (
   .clk 		(clk),
   .reset 		(reset),
   .Pc_in 		(Pc_in),
   .Rd_en_cache 	(Rd_en_cache),
   .Dout 		(Dout),
   .Dout_valid 		(Dout_valid),
   .Pc_out 		(Pc_out),
   .Inst 		(Inst),
   .Empty 		(Empty),
   .Rd_en 		(Rd_en),
   .Jmp_branch_address 	(Jmp_branch_address),
   .Jmp_branch_valid 	(Jmp_branch_valid)
);



dispatch_unit dispatch_unit (
	.clock			(),	// Senal de reloj.
	.reset			(),	// Señal de reset.
	// Interface con IFQ:
	.ifetch_pc_4		(),	// la instrucción es valida is ‘0’, invalida si ‘1’.
	.ifetch_intruction	(), 	// 32 bits de la instrucción.
	.ifetch_empty		(),	// la instrucción es valida is ‘0’, invalida si ‘1’.
	.Dispatch_jmp_addr	(),	// 32 bit dirección de salto.
	.Dispatch_jmp		(),	// ‘1’ la instrucción es un jump o un branch que fue tomado.
	.Dispatch_ren		(),	// si ‘1’ el IFQ incrementa el apuntador de lectura y muestra una nueva instruccion,
					// si ‘0’ el IFQ sigue mostrando la misma instrucción.
	// Interface con Colas de ejecucion:
	// - Señales comunes para todas las colas de ejecución.
	.dispatch_rs_data	(),	// operando rs
	.dispatch_rs_data_valid	(),	// es „1‟ si rs tiene el ultimo valor, si no „0‟.
	.dispatch_rs_tag	(),	// tag para rs.
	.dispatch_rt_data	(),	// operand rt
	.dispatch_rt_data_valid	(),	// es „1‟ si rt tiene el ultmo valor, si no „0‟.
	.dispatch_rt_tag	(),	// tag para rt
	.dispatch_rd_tag	(),	// TAG asignado al registro destino de la instrucción
	
	// - Señales especificas para la cola de ejecución de enteros.
	.dispatch_en_integer	(),	// unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	.issueque_integer_full	(),	// Bandera “llena” de la cola de ejecución de enteros.
	.dispatch_opcode	(),	// TODO:revisar si -> 3‐bit opcode para la ALU.
	.dispatch_shfamt	(),	// 5-bits en caso de una instrucción del tipo shift
	
	// - Señales especificas para la Cola de ejecución de acceso a memoria.
	.dispatch_en_ld_st	(),	// DU intenta escribir una instrucción en la cola LD/ST.
	.issueque_full_ld_st	(),	// Bandera “llena” de la cola de ejecución LD / ST.
	.dispatch_imm_ld_st	(),	// 16 ‐ bit del campo inmediato para calcular la dirección de memoria.

	// - Señales especificas para la Cola de ejecución de multiplicaciones.
	.dispatch_en_mul	(),	// DU intenta escribir una instrucción en la cola Multiplicación.
	.issueque_mul_full	()	// Bandera “llena” de la cola de ejecución Multiplicación.

	);

