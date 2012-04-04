/****************************************************************************************************/
// Title      : Full Adder 32 bits Verilog File
// File       : Full_Adder32.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module Full_Adder32(A,B,Cin,Mod,S,Cout,Overflow);

  input  [31:0] A, B;
  input         Cin, Mod;
  output [31:0] S;
  output        Cout;
  output        Overflow;
  
  wire [30:0] Cp;
  
  generate
  genvar i;
  
    for(i=0; i<32; i=i+1) begin: Adder_gen
      
      if(i == 0)
        Full_Adder Full_Adder_inst ( .A(A[i]), .B(B[i]^Mod), .Cin(Cin),     .S(S[i]), .Cout(Cp[i])   );
      
      else if(i<31)
        Full_Adder Full_Adder_inst ( .A(A[i]), .B(B[i]^Mod), .Cin(Cp[i-1]), .S(S[i]), .Cout(Cp[i])   );
      
      else  
        Full_Adder Full_Adder_inst ( .A(A[i]), .B(B[i]^Mod), .Cin(Cp[i-1]), .S(S[i]), .Cout(Cout)   );
        
    end
 
  endgenerate
  
  assign Overflow = Cout ^ Cp[30];
  
  
endmodule