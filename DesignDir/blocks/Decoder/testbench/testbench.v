//Testbench: Decoder

`timescale 1ns / 100ps

module testbench;


	reg            	clock;
	reg            	reset;
	reg  	[31:0] 	Inst;
	wire 	[ 2:0]	Dispatch_opcode;	//: 3‐bit opcode para la ALU. : 1 ‐ bit opcode para distinguir entre LD y ST.
	wire	[ 4:0]	Dispatch_shfamt;	//:: 5-bits en caso de una instrucción del tipo shift
	wire 		Dispatch_en_integer;	//: unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	wire 		Dispatch_en_ld_st;	//: DU intenta escribir una instrucción en la cola LD/ST.
	wire 	[15:0]	Dispatch_imm_ld_st;	//: 16 ‐ bit del campo inmediato para calcular la dirección de memoria
	wire 		Dispatch_en_mult;


decoder decoder (
	.clock(clock),
	.reset(reset),
	.Inst(Inst),
	.Dispatch_opcode(Dispatch_opcode),	//: 3‐bit opcode para la ALU. : 1 ‐ bit opcode para distinguir entre LD y ST.
	.Dispatch_shfamt(Dispatch_shfamt),	//:: 5-bits en caso de una instrucción del tipo shift
	.Dispatch_en_integer(Dispatch_en_integer),
	.Dispatch_en_ld_st(Dispatch_en_ld_st),	//: DU intenta escribir una instrucción en la cola LD/ST.
	.Dispatch_imm_ld_st(Dispatch_imm_ld_st),	//: 16 ‐ bit del campo inmediato para calcular la dirección de memoria
	.Dispatch_en_mult(Dispatch_en_mult)
		);

always begin
#5	clock=!clock;
end 



initial begin
	clock=0;
	reset=0;
#15	reset=1; 

#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0000;
#10 Inst = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0010_0100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0001;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0100;
#10 Inst = 32'b0011_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0001_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0100_0000_0001_0000_0000_0000_0000;
#10 Inst = 32'b0000_0100_0001_0001_0000_0000_0000_0000;
#10 Inst = 32'b0001_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0001_1000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0100_0001_0000_0000_0000_0000_0000;
#10 Inst = 32'b0001_0100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_1010;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_1011;
#10 Inst = 32'b0000_1000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0011_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_0010;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_1000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0001_1001;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0101;
#10 Inst = 32'b0011_0100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_1010;
#10 Inst = 32'b0010_1000_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0010_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_1011;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0010;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_0110;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0010;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0011;
#10 Inst = 32'b0010_1100_0000_0000_0000_0000_0000_0000;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0000_1100;
#10 Inst = 32'b0000_0000_0000_0000_0000_0000_0010_0110;
#10 Inst = 32'b0011_1000_0000_0000_0000_0000_0000_0000;

#10 $finish;
end
/*
always @* begin
	casez (Inst[31:26]) 
 		6'b000000 : begin //R-Type Instructions (Opcode 000000)
			if (Dispatch_opcode 	== 3'b000 &&
				Dispatch_en_integer	== 1'b0 &&
				Dispatch_en_mult	== 1'b0 &&
				Dispatch_en_ld_st	== 1'b0)
				$display("INFOMSG : R-Type Instructions");
			end 
  		6'b00001? : begin //J-Type Instructions (Opcode 00001x)
			if (Dispatch_opcode 	== 3'b001 &&
				Dispatch_en_integer	== 1'b0 &&
				Dispatch_en_mult	== 1'b0 &&
				Dispatch_en_ld_st	== 1'b0)
				$display("INFOMSG : J-Type Instructions");
			end
  		6'b0100?? : begin //Coprocessor Instructions (Opcode 0100xx)
			if (Dispatch_opcode 	== 3'b010 &&
				Dispatch_en_integer	== 1'b0 &&
				Dispatch_en_mult	== 1'b0 &&
				Dispatch_en_ld_st	== 1'b0)
				$display("INFOMSG : CP-Type Instructions");
			end
  		default : begin //I-Type Instructions (All opcodes except 000000, 00001x, and 0100xx)
			if (Dispatch_opcode 	== 3'b001 &&
				Dispatch_en_integer	== 1'b1&&
				Dispatch_en_mult	== 1'b0 &&
				Dispatch_en_ld_st	== 1'b0)
				$display("INFOMSG : I-Type Instructions");
		end
	endcase 
end
*/
endmodule
