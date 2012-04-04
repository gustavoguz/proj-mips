`timescale 1ns/1ns

module tb_Mult();

  reg Clk;
  reg Rst;
  reg [15:0] Data_A;
  reg [15:0] Data_B;
  wire [31:0] Result;
  
  
  //Clock signal generation
  initial begin
  
    Clk = 1'b0;
    forever #5 Clk <= ~Clk;
  
  end
  
  //Reset signal generation
  initial begin
    
    Rst = 1'b1;
    #22; Rst = 1'b0; 
      
  end
  
  initial begin
  
    Data_A = 0;
    Data_B = 0;
    
    #42 Data_A = 10;
    Data_B = 50;
    
  end
  
  
  Mult mult_inst0(
     .Rst(Rst),
     .Clk(Clk),
     .OpA(Data_A),
     .OpB(Data_B),
     .Result(Result));

  
  
  
  
endmodule