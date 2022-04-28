//--------------------------------------------------------------------------------------------------------------------------
// Design Name 	: Dispatch Decoder
// File Name   	: Dispatch_Decoder.v
// Function    	: Combinational
// Coder  	: 
// Other	:
//		+------+----------------------------------------------------------------------------------------+
//		| Type |	-31-                                 format (bits)                    -0-	|
//		+------+----------------------------------------------------------------------------------------+
//		| R    |	opcode (6)	rs (5)	rt (5)	rd (5)		shamt (5)	funct (6)	|
//		| I    |	opcode (6)	rs (5)	rd (5)	immediate (16)					|
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

module Dispatch_Decoder (
	input  		[31:0] 	Inst,
	output reg 	[ 3:0]	Dispatch_Opcode,	//: 3?bit opcode para la ALU. : 1 ? bit opcode para distinguir entre LD y ST.
	output reg	[ 4:0]	Dispatch_Shfamt,	//:: 5-bits en caso de una instrucción del tipo shift  Necesario?
	output reg 	[31:0]	Dispatch_Imm_LS,	//: 32  bit del campo inmediato para calcular la dirección de memoria, 32 por las extensiones
	output reg 		Dispatch_en_Int,	//: unidad de despacho intenta escribir una instrucción en la cola de ejecución de enteros.
	output reg 		Dispatch_en_LS,	//: DU intenta escribir una instrucción en la cola LD/ST.
	output reg 		Dispatch_en_Mult,
	output reg         	Dispatch_Type_R,
	output reg         	Dispatch_Type_I,
	output reg         	Dispatch_Type_J,
	output reg         	Dispatch_Branch
		);


   parameter R_TYPE  = 6'b000000;
   parameter R_ADD   = 6'h20;
   parameter R_ADDU  = 6'h21;
   parameter R_AND   = 6'h24;
   parameter R_NOR   = 6'h27;
   parameter R_OR    = 6'h25;
   parameter R_SLT   = 6'h2A;
   parameter R_SLTU  = 6'h2B;
   parameter R_SUB   = 6'h22;
   parameter R_SLL   = 6'h00;
   parameter R_SRL   = 6'h02;
   parameter R_MULT  = 6'h19;
   parameter I_ADDI  = 6'h08;
   parameter I_ADDIU = 6'h09;
   parameter I_ANDI  = 6'h0C;
   parameter I_BEQ   = 6'h04;
   parameter I_BNQ   = 6'h05;
   parameter I_LDW   = 6'h23;
   parameter I_ORI   = 6'h0D;
   parameter I_SLTI  = 6'h0A;
   parameter I_STW   = 6'h2B;
   parameter J_JUMP  = 6'h02;
   
   parameter OP_AND  = 4'b0000;  //0
   parameter OP_OR   = 4'b0001;  //1
   parameter OP_ADD  = 4'b0010;  //2
   parameter OP_ADDU = 4'b0011;  //3
   parameter OP_SUB  = 4'b0110;  //6
   parameter OP_SLT  = 4'b0111;  //7
   parameter OP_SLTU = 4'b1010;  //A
   parameter OP_NOR  = 4'b1100;  //C
   parameter OP_SLL  = 4'b1000;  //8
   parameter OP_SRL  = 4'b1001;  //9    
   parameter OP_BEQ  = 4'b0100;  //4
   parameter OP_BNQ  = 4'b0101;  //5
   parameter OP_STW  = 4'b0000;  
   parameter OP_LDW  = 4'b0001; 

   always @(*) begin
	    	       
	       // Default values
	       Dispatch_Opcode      = 4'b0000;
	       Dispatch_Shfamt      = 5'b00000;
	       Dispatch_Imm_LS      = 32'h00000000; 
	       Dispatch_en_Int    	 = 1'b0;
	       Dispatch_en_Mult	    = 1'b0;
	       Dispatch_en_LS   	   = 1'b0;
	       Dispatch_Type_R      = 1'b0;
	       Dispatch_Type_I      = 1'b0;
	       Dispatch_Type_J      = 1'b0;
	       Dispatch_Branch      = 1'b0;
	           
	       case (Inst[31:26])
	          //R-Type Instructions (Opcode 000000) 
 		        R_TYPE : begin 
			         
			         $display("INFO : R-Type Instructions (Opcode 000000)");	
			         // Default values for R_Types
			         Dispatch_Shfamt      = Inst[10:6];
			         Dispatch_Type_R      = 1'b1;
			         		         	         			      
			         case (Inst[5:0])
			            R_ADD : begin 
			               	$display("INFO : Decoding Intruction = ADD");
			               	Dispatch_Opcode      = OP_ADD;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_ADDU : begin 
			               	$display("INFO : Decoding Intruction = ADDU");
			               	Dispatch_Opcode      = OP_ADDU;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_AND : begin 
			               	$display("INFO : Decoding Intruction = AND");
			               	Dispatch_Opcode      = OP_AND;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_NOR : begin 
			               	$display("INFO : Decoding Intruction = NOR");
			               	Dispatch_Opcode      = OP_NOR;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_OR : begin 
			               	$display("INFO : Decoding Intruction = OR");
			               	Dispatch_Opcode      = OP_OR;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_SLT : begin 
			               	$display("INFO : Decoding Intruction = SLT");
			               	Dispatch_Opcode      = OP_SLT;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_SLTU : begin 
			               	$display("INFO : Decoding Intruction = SLTU");
			               	Dispatch_Opcode      = OP_SLTU;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_SUB : begin 
			               	$display("INFO : Decoding Intruction = SUB");
			               	Dispatch_Opcode      = OP_SUB;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_SLL : begin 
			               	$display("INFO : Decoding Intruction = SLL at time %0t", $time);
			               	Dispatch_Opcode      = OP_SLL;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_SRL : begin 
			               	$display("INFO : Decoding Intruction = SRL");
			               	Dispatch_Opcode      = OP_SRL;                  
	                   		Dispatch_en_Int    	 = 1'b1;
			            end
			            R_MULT : begin 
			               	$display("INFO : Decoding Intruction = MULT");
			               	Dispatch_Opcode      = 4'b0000;                  
	                   		Dispatch_en_Mult    	= 1'b1;
			            end	            
			            default : begin
			               	$display("ERROR : Decoding Intruction type R = %d",Inst[5:0]);
			            end
			            
			         endcase
			         
			      end // End Instruction type R
			      
			      //I-Type Instructions 
			      I_ADDI : begin 
			         $display("INFO : Decoding Intruction = ADDI");
			         Dispatch_Opcode      = OP_ADD;
			         Dispatch_Imm_LS      = {{16{Inst[15:0]}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_ADDIU : begin 
			         $display("INFO : Decoding Intruction = ADDIU");
			         Dispatch_Opcode      = OP_ADDU;
			         Dispatch_Imm_LS      = {{16{Inst[15:0]}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_ANDI : begin 
			         $display("INFO : Decoding Intruction = ANDI");
			         Dispatch_Opcode      = OP_AND;
			         Dispatch_Imm_LS      = {{16{1'b0}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_BEQ : begin 
			         $display("INFO : Decoding Intruction = BEQ");
			         Dispatch_Opcode      = OP_BEQ;
			         Dispatch_Imm_LS      = {{16{1'b0}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
	             Dispatch_Branch      = 1'b1;
			      end
			      I_BNQ : begin 
			         $display("INFO : Decoding Intruction = BNQ");
			         Dispatch_Opcode      = OP_BNQ;
			         Dispatch_Imm_LS      = {{16{1'b0}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
	             Dispatch_Branch      = 1'b1;
			      end
			      I_LDW : begin 
			         $display("INFO : Decoding Intruction = LDW");
			         Dispatch_Opcode      = OP_LDW;
			         Dispatch_Imm_LS      = {{16{Inst[15:0]}},Inst[15:0]};                 
	             Dispatch_en_LS     	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_ORI : begin 
			         $display("INFO : Decoding Intruction = ORI");
			         Dispatch_Opcode      = OP_OR;
			         Dispatch_Imm_LS      = {{16{1'b0}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_SLTI : begin 
			         $display("INFO : Decoding Intruction = SLTI");
			         Dispatch_Opcode      = OP_SLT;
			         Dispatch_Imm_LS      = {{16{1'b0}},Inst[15:0]};                  
	             Dispatch_en_Int    	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      I_STW : begin 
			         $display("INFO : Decoding Intruction = STW");
			         Dispatch_Opcode      = OP_STW;
			         Dispatch_Imm_LS      = {{16{Inst[15:0]}},Inst[15:0]};                  
	             Dispatch_en_LS     	 = 1'b1;
	             Dispatch_Type_I      = 1'b1;
			      end
			      // End Instruction type I
			      
			      //J-Type Instructions
			      J_JUMP : begin 
			         $display("INFO : Decoding Intruction = JUMP");                  
	             Dispatch_Type_J      = 1'b1;
			      end
			      
			      default : begin
			         $display("ERROR : Decoding Instruction type I or J");
			      end
			      	
			   endcase
		  
   end //end always

endmodule
