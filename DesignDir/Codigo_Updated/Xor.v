/****************************************************************************************************/
// Title      : Xor 1bit Verilog File
// File       : Xor.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module Xor(Z,A,B);

  input  A, B;
  output Z;
  
  
  not  xor_not0 (A_neg,  A);
  not  xor_not1 (B_neg,  B);
  and  xor_and0 (S0, A,  B_neg);
  and  xor_and1 (S1, B,  A_neg);
  or   xor_or0  (Z , S0, S1);
  
  
endmodule
