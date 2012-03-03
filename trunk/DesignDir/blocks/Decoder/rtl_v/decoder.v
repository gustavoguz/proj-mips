//--------------------------------------------------------------------------------------------------------------------------
// Design Name 	: Decoder
// File Name   	: decoder.v
// Function    	: 
// Coder  	: 
// Other	:
//		+------+----------------------------------------------------------------------------------------+
//		| Type |	-31-                                 format (bits)                    -0-	|
//		+------+----------------------------------------------------------------------------------------+
//		| R    |	opcode (6)	rs (5)	rt (5)	rd (5)		shamt (5)	funct (6)	|
//		| I    |	opcode (6)	rs (5)	rt (5)	immediate (16)					|
//		| J    |	opcode (6)	address (26)							|
//		+------+----------------------------------------------------------------------------------------+
//		|      |	[31:26]		[25:21] [20:16] [15:11] [10:6] [5:0]
//		+------+----------------------------------------------------------------------------------------+
//
//		Set de instrucciones:
//		Add, And, Jmp, Ori, Stw, Mult, Addi, Andi, Ldw, Slt, sub, Addiu, Beq, Nor, Slti, Sll, Addu, Bnq, Or, Sltu, Srl
//
//		Mas informacion:
//		http://www.d.umn.edu/~gshute/spimsal/talref.html#rtype
//		http://www.mrc.uidaho.edu/mrc/people/jff/digital/MIPSir.html
//--------------------------------------------------------------------------------------------------------------------------


module decoder (
	input              	clock,
	input             	reset,
	input  		[31:0] 	Inst,
	output reg 	[ 2:0]	Dispatch_opcode,	//: 3‐bit opcode para la ALU. : 1 ‐ bit opcode para distinguir entre LD y ST.
	output reg	[ 4:0]	Dispatch_shfamt,	//:: 5-bits en caso de una instrucción del tipo shift
	output reg 		Dispatch_en_integer,	//: unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	output reg 		Dispatch_en_ld_st,	//: DU intenta escribir una instrucción en la cola LD/ST.
	output reg 	[15:0]	Dispatch_imm_ld_st,	//: 16 ‐ bit del campo inmediato para calcular la dirección de memoria
	output reg 		Dispatch_en_mult
		);

always @(posedge clock, posedge reset) begin
	if (!reset) begin
	//TODO
	Dispatch_opcode<=3'b000;
	Dispatch_en_integer	<= 1'b0;
	Dispatch_en_mult	<= 1'b0;
	Dispatch_en_ld_st	<= 1'b0;
	end else begin
	casez (Inst[31:26]) 
 		6'b000000 : begin //R-Type Instructions (Opcode 000000)
			$display("INFO : R-Type Instructions (Opcode 000000) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b000;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_en_integer	<= 1'b0;
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			end 
  		6'b00001? : begin //J-Type Instructions (Opcode 00001x)
			$display("INFO : J-Type Instructions (Opcode 00001x) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b001;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_en_integer	<= 1'b0;
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			end
  		6'b0100?? : begin //Coprocessor Instructions (Opcode 0100xx)
			$display("INFO : CoProc Instructions (Opcode 0100xx) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b010;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_en_integer	<= 1'b0;
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			end
  		default : begin //I-Type Instructions (All opcodes except 000000, 00001x, and 0100xx)
			$display("INFO : I-Type Instructions (All opcodes..) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b011;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_en_integer	<= 1'b1;
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
		end
	endcase 
	end
	
end 


endmodule

