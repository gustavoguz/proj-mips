//-----------------------------------------------------
// Design Name 	: Coder32_5
// File Name   	: coder32_5.v
// Function    	: 
// Coder  	: 
// Other	:
//-----------------------------------------------------

module coder32_5 (
		input 		[31:0]	wen1_rst,
  		output reg	[4:0] 	Addr	,
  		output reg		Clear_en
  		);
	
always @(wen1_rst) begin
    case (wen1_rst)
      32'h00000000 : begin 
        Addr	 	= 5'b11111;
        Clear_en 	= 1'b0;
      end    
      32'h00000001 : begin
        Addr	 	= 5'b00000;
        Clear_en 	= 1'b1;
      end
      32'h00000002 : begin
        Addr	 	= 5'b00001;
        Clear_en 	= 1'b1;
      end
      32'h00000004 : begin
        Addr	 	= 5'b00010;
        Clear_en 	= 1'b1;
      end
      32'h00000008 : begin
        Addr	 	= 5'b00011;
        Clear_en 	= 1'b1;
      end
      32'h00000010 : begin
        Addr	 	= 5'b00100;
        Clear_en 	= 1'b1;
      end
      32'h00000020 : begin
        Addr	 	= 5'b00101;
        Clear_en 	= 1'b1;
      end
      32'h00000040 : begin
        Addr	 	= 5'b00110;
        Clear_en 	= 1'b1;
      end
      32'h00000080 : begin
        Addr	 	= 5'b00111;
        Clear_en 	= 1'b1;
      end
      32'h00000100 : begin
        Addr	 	= 5'b01000;
        Clear_en 	= 1'b1;
      end
      32'h00000200 : begin
        Addr	 	= 5'b01001;
        Clear_en 	= 1'b1;
      end
      32'h00000400 : begin
        Addr	 	= 5'b01010;
        Clear_en 	= 1'b1;
      end
      32'h00000800 : begin
        Addr	 	= 5'b01011;
        Clear_en 	= 1'b1;
      end
      32'h00001000 : begin
        Addr	 	= 5'b01100;
        Clear_en 	= 1'b1;
      end
      32'h00002000 : begin
        Addr	 	= 5'b01101;
        Clear_en 	= 1'b1;
      end
      32'h00004000 : begin
        Addr	 	= 5'b01110;
        Clear_en 	= 1'b1;
      end
      32'h00008000 : begin
        Addr	 	= 5'b01111;
        Clear_en 	= 1'b1;
      end
      32'h00010000 : begin
        Addr	 	= 5'b10000;
        Clear_en 	= 1'b1;
      end
      32'h00020000 : begin
        Addr	 	= 5'b10001;
        Clear_en 	= 1'b1;
      end
      32'h00040000 : begin
        Addr	 	= 5'b10010;
        Clear_en 	= 1'b1;
      end
      32'h00080000 : begin
        Addr	 	= 5'b10011;
        Clear_en 	= 1'b1;
      end
      32'h00100000 : begin 
        Addr	 	= 5'b10100;
        Clear_en 	= 1'b1;
      end
      32'h00200000 : begin
        Addr	 	= 5'b10101;
        Clear_en 	= 1'b1;
      end
      32'h00400000 : begin
        Addr	 	= 5'b10110;
        Clear_en 	= 1'b1;
      end
      32'h00800000 : begin
        Addr	 	= 5'b10111;
        Clear_en 	= 1'b1;
      end
      32'h01000000 : begin 
        Addr	 	= 5'b11000;
        Clear_en 	= 1'b1;
      end
      32'h02000000 : begin
        Addr	 	= 5'b11001;
        Clear_en 	= 1'b1;
      end
      32'h04000000 : begin
        Addr	 	= 5'b11010;
        Clear_en 	= 1'b1;
      end
      32'h08000000 : begin
        Addr	 	= 5'b11011;
        Clear_en 	= 1'b1;
      end
      32'h10000000 : begin
        Addr	 	= 5'b11100;
        Clear_en 	= 1'b1;
      end
      32'h20000000 : begin
        Addr	 	= 5'b11101;
        Clear_en 	= 1'b1;
      end
      32'h40000000 : begin
        Addr	 	= 5'b11110;
        Clear_en 	= 1'b1;
      end
      32'h80000000 : begin 
        Addr	 	= 5'b11111;
        Clear_en 	= 1'b1;
      end      
      default : begin
        Addr	 	= 5'b11111;
        Clear_en 	= 1'b0;
    end         
    endcase         
  end
endmodule
