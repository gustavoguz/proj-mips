//-----------------------------------------------------
// Design Name 	: Deco5_32
// File Name   	: deco5_32.v
// Function    	: Decodes de address to one hot code (32bits)
// Coder  	: 
// Other	:
//-----------------------------------------------------

module deco5_32 (
	input 		[4:0]	Waddr_rst, 
  	input 			Wen_rst, 
  	output reg	[31:0]	Wen0_rst
	);
  
always @(Waddr_rst or Wen_rst) begin
  if(Wen_rst) begin   
  case(Waddr_rst)
    5'b00000 : begin         
    	Wen0_rst = 32'h00000001;     
    end
    5'b00001 : begin  
    	Wen0_rst = 32'h00000002;  
    end
    5'b00010 : begin 
    	Wen0_rst = 32'h00000004;
    end
    5'b00011 : begin
    	Wen0_rst = 32'h00000008;  
    end
    5'b00100 : begin
    	Wen0_rst = 32'h00000010;  
    end
    5'b00101 : begin 
    	Wen0_rst = 32'h00000020;  
    end
    5'b00110 : begin
    	Wen0_rst = 32'h00000040;  
    end
    5'b00111 : begin
    	Wen0_rst = 32'h00000080;  
    end
    5'b01000 : begin
    	Wen0_rst = 32'h00000100;  
    end
    5'b01001 : begin 
    	Wen0_rst = 32'h00000200;  
    end
    5'b01010 : begin
    	Wen0_rst = 32'h00000400;  
    end
    5'b01011 : begin
    	Wen0_rst = 32'h00000800;  
    end
    5'b01100 : begin
    	Wen0_rst = 32'h00001000;  
    end
    5'b01101 : begin
    	Wen0_rst = 32'h00002000; 
    end
    5'b01110 : begin
    	Wen0_rst = 32'h00004000;  
    end
    5'b01111 : begin
    	Wen0_rst = 32'h00008000; 
    end
    5'b10000 : begin        
    	Wen0_rst = 32'h00010000;    
    end
    5'b10001 : begin 
    	Wen0_rst = 32'h00020000;  
    end
    5'b10010 : begin
    	Wen0_rst = 32'h00040000;
    end
    5'b10011 : begin
    	Wen0_rst = 32'h00080000;  
    end
    5'b10100 : begin
    	Wen0_rst = 32'h00100000;  
    end
    5'b10101 : begin
    	Wen0_rst = 32'h00200000; 
    end
    5'b10110 : begin
    	Wen0_rst = 32'h00400000;  
    end
    5'b10111 : begin
    	Wen0_rst = 32'h00800000;  
    end
    5'b11000 : begin
    	Wen0_rst = 32'h01000000;  
    end
    5'b11001 : begin
    	Wen0_rst = 32'h02000000;  
    end
    5'b11010 : begin
    	Wen0_rst = 32'h04000000;  
    end
    5'b11011 : begin
    	Wen0_rst = 32'h08000000;  
    end
    5'b11100 : begin
    	Wen0_rst = 32'h10000000; 
    end
    5'b11101 : begin
    	Wen0_rst = 32'h20000000;   
    end
    5'b11110 : begin
    	Wen0_rst = 32'h40000000;   
    end
    5'b11111 : begin
    	Wen0_rst = 32'h80000000;   
    end
    default : begin
    	Wen0_rst = 32'h00000000;   
    end
  endcase
  end else begin
  	Wen0_rst = 32'h00000000;    
  end  
end
endmodule
