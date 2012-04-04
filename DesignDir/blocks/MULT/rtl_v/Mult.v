/****************************************************************************************************/
// Title      : Multipler Functional Model Verilog File
// File       : Mult.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module Mult(
  
   // Port Declarations
   input                Clk,
   input                Rst,
   input       [15:0]   OpA,
   input       [15:0]   OpB,
   output      [31:0]   Result
   
   );
   
   reg [31:0] result_reg [0:2];
  
   always@(posedge Clk, posedge Rst) begin
     
      if(Rst) begin
      
         result_reg[0] <= 32'h00000000;
         result_reg[1] <= 32'h00000000;
         result_reg[2] <= 32'h00000000;
      
      end
      
      else begin
        
         result_reg[0] <= OpA*OpB;
         result_reg[1] <= result_reg[0];
         result_reg[2] <= result_reg[1];

      end    
     
    
   end
  
  
   assign Result = result_reg[2];
  
  
  
endmodule
