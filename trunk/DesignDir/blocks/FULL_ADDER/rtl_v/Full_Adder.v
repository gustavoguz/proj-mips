/****************************************************************************************************/
// Title      : Full Adder 1bit Verilog File
// File       : Full_Adder.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module Full_Adder(A, B, Cin, S, Cout);

  input  A, B, Cin;
  output S, Cout;
  
  Xor  fa_xor0 (X0, A,  B);
  Xor  fa_xor1 (S , X0, Cin);
  and  fa_and0 (S0, A,    B);
  and  fa_and1 (S1, Cin,  X0);
  or   fa_or0  (Cout, S0, S1);
       
  
endmodule