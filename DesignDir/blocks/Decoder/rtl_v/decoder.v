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
			//$display("INFO : R-Type Instructions (Opcode 000000) == %b",Inst[31:26]);
				Dispatch_opcode 	<= 3'b000;
				Dispatch_shfamt 	<= Inst[10:6];
				Dispatch_imm_ld_st	<= Inst[15:0];
				Dispatch_en_integer	<= 1'b0;
				Dispatch_en_mult	<= 1'b0;
				Dispatch_en_ld_st	<= 1'b0;
			case (Inst[5:0])
			6'b100000 : begin 
			$display("INFO : Decoding Intruction = ADD");
			end
			6'b100001 : begin 
			$display("INFO : Decoding Intruction = ADDU");
			end
			6'b100100 : begin 
			$display("INFO : Decoding Intruction = AND");
			end
			6'b011010 : begin 
			$display("INFO : Decoding Intruction = DIV");
			end
			6'b011011 : begin 
			$display("INFO : Decoding Intruction = DIVU");
			end
			6'b001000 : begin 
			$display("INFO : Decoding Intruction = JR");
			end
			6'b000000 : begin 
			$display("INFO : Decoding Intruction = SLL");
			end
			6'b010000 : begin 
			$display("INFO : Decoding Intruction = MFHI");
			end
			6'b010010 : begin 
			$display("INFO : Decoding Intruction = MFLO");
			end
			6'b011000 : begin 
			$display("INFO : Decoding Intruction = MULT");
			end
			6'b011001 : begin 
			$display("INFO : Decoding Intruction = MULTU");
			end
			6'b100101 : begin 
			$display("INFO : Decoding Intruction = OR");
			end
			6'b000100 : begin 
			$display("INFO : Decoding Intruction = SLLV");
			end
			6'b101010 : begin 
			$display("INFO : Decoding Intruction = SLT");
			end
			6'b101011 : begin 
			$display("INFO : Decoding Intruction = SLTU");
			end
			6'b000011 : begin 
			$display("INFO : Decoding Intruction = SRA");
			end
			6'b000010 : begin 
			$display("INFO : Decoding Intruction = SRL");
			end
			6'b000110 : begin 
			$display("INFO : Decoding Intruction = SRLV");
			end
			6'b100010 : begin 
			$display("INFO : Decoding Intruction = SUB");
			end
			6'b100011 : begin 
			$display("INFO : Decoding Intruction = SUBU");
			end
			6'b001100 : begin 
			$display("INFO : Decoding Intruction = SYSCALL");
			end
			6'b100110 : begin 
			$display("INFO : Decoding Intruction = XOR");
			end
			default : $display("ERROR : Decoding Intruction type R");
			endcase
			end // End Instruction type R
  		6'b00001? : begin //J-Type Instructions (Opcode 00001x)
			//$display("INFO : J-Type Instructions (Opcode 00001x) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b001;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_integer	<= 1'b0;
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			case (Inst[31:26]) 
			6'b000010 : begin
			$display("INFO : Decoding Intruction = J");
			end
			6'b000011 : begin
			$display("INFO : Decoding Intruction = JAL");
			end
			default : $display("ERROR : Decoding Instruction type J");
			endcase
			end // End Intruction type J
  		6'b0100?? : begin //Coprocessor Instructions (Opcode 0100xx)
			//$display("INFO : CoProc Instructions (Opcode 0100xx) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b010;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_integer	<= 1'b0;
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			case (Inst[31:26]) 
			default : $display("ERROR : Decoding Instruction type CI");
			endcase
			end
  		default : begin //I-Type Instructions (All opcodes except 000000, 00001x, and 0100xx)
			//$display("INFO : I-Type Instructions (All opcodes..) == %b",Inst[31:26]);
			Dispatch_opcode 	<= 3'b011;
			Dispatch_shfamt 	<= Inst[10:6];
			Dispatch_imm_ld_st	<= Inst[15:0];
			Dispatch_en_integer	<= 1'b1;
			Dispatch_en_mult	<= 1'b0;
			Dispatch_en_ld_st	<= 1'b0;
			case (Inst[31:26]) 
			6'b001000 : begin
			$display("INFO : Decoding Intruction = ADDI");
			end
			6'b001001 : begin
			$display("INFO : Decoding Intruction = ADDIU");
			end
			6'b001100 : begin
			$display("INFO : Decoding Intruction = ANDI");
			end
			6'b000100 : begin
			$display("INFO : Decoding Intruction = BEQ");
			end
			6'b000001 : begin
			$display("INFO : Decoding Intruction = BGEZ");
			end
			6'b000111 : begin
			$display("INFO : Decoding Intruction = BGTZ");
			end
			6'b000110 : begin
			$display("INFO : Decoding Intruction = BLEZ");
			end
			6'b000101 : begin
			$display("INFO : Decoding Intruction = BNE");
			end
			6'b001111 : begin
			$display("INFO : Decoding Intruction = LUI");
			end
			6'b001101 : begin
			$display("INFO : Decoding Intruction = ORI");
			end
			6'b001010 : begin
			$display("INFO : Decoding Intruction = SLTI");
			end
			6'b001011 : begin
			$display("INFO : Decoding Intruction = SLTIU");
			end
			6'b001110 : begin
			$display("INFO : Decoding Intruction = XORI");
			end
			6'b101011: begin
			$display("INFO : Decoding Intruction = SW");
			end
			6'b100011 : begin
			$display("INFO : Decoding Intruction = LW");
			end
			6'bxxxxxx : begin
			$display("INFO : Decoding Intruction = XXXX");
			end
			default : $display("ERROR : Decoding Instruction type I");
			endcase
		end
	endcase 
	end
end 
endmodule
