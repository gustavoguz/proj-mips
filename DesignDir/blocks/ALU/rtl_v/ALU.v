/****************************************************************************************************/
// Title      : ALU Verilog File
// File       : ALU.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module ALU( 
  
   // Port Declarations
   input       [31:0]   Operand1, 
   input       [31:0]   Operand2,
   input       [ 4:0]   Shfamt,
   input       [ 4:0]   Tag_In,
   input       [ 3:0]   ALU_Opcode,  // Va a ser de 4 bits, no de 3
   
   output reg  [31:0]   Result,
   output      [ 4:0]   Tag_Out,
   output reg           ALU_Branch,
   output reg           ALU_Branch_Taken,
   output reg           Carry_Out,
   output reg           Overflow   
   );
   
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
  
   wire [31:0] FA_Result;
   wire        FA_Cout;
   wire        FA_Overflow;
   wire        FA_Mod;
   
   assign FA_Mod = (ALU_Opcode == OP_SUB);
   
   Full_Adder32 Full_Adder32_inst0(
      .A        (Operand1),
      .B        (Operand2),
      .Cin      (FA_Mod),
      .Mod      (FA_Mod),
      .S        (FA_Result),   
      .Cout     (FA_Cout),
      .Overflow (FA_Overflow)
    );
  
  
   always@(*) begin
      
      //Default Values
      ALU_Branch       = 1'b0;
      ALU_Branch_Taken = 1'b0;
      Carry_Out        = 1'b0;
      Overflow         = 1'b0;
      Result           = 32'h00000000;
      
      case(ALU_Opcode)
         OP_AND:  Result =   Operand1 & Operand2;
         OP_OR:   Result =   Operand1 | Operand2;        
         OP_ADDU: {Carry_Out,Result} =  {FA_Cout,FA_Result};          
         OP_SLTU: Result =  (Operand1 < Operand2) ? 32'h00000001:32'b00000000;
         OP_NOR:  Result = ~(Operand1 | Operand2);
         OP_SLL:  Result =   Operand1 << Shfamt;
         OP_SRL:  Result =   Operand1 >> Shfamt;
         OP_BEQ:  {ALU_Branch, ALU_Branch_Taken} = {1'b1, (Operand1 == Operand2)} ;
         OP_BNQ:  {ALU_Branch, ALU_Branch_Taken} = {1'b1, (Operand1 != Operand2)} ;
         OP_ADD:  {Overflow, Carry_Out, Result} =  {FA_Overflow, FA_Cout, FA_Result};
         OP_SUB:  {Overflow, Carry_Out, Result} =  {FA_Overflow, FA_Cout, FA_Result};             
         OP_SLT: begin
            //Result =  ($signed(Operand1) < $signed(Operand2)) ? 32'h00000001:32'b00000000;
            if(Operand1[31] != Operand2[31]) begin
               Result = (Operand2[31]) ? 32'b00000000:32'h00000001; 
            end
            else begin
               if(Operand1[31] == 1'b0) Result =  (Operand1 < Operand2) ? 32'h00000001:32'b00000000;      
               else Result =  ( (~(Operand1)+1'b1) > (~(Operand2)+1'b1) ) ? 32'h00000001:32'b00000000;       
            end     
         end
           
         default: Result = 32'h00000000;
       endcase
   
   end 
   
   // Tag Output
   assign Tag_Out = Tag_In;  
   
endmodule