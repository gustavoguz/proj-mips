module i_cache ( Dout, Dout_valid, Pc_in, Rd_en, reset, clk);
input 		clk; 
input 		reset;
input [31:0]	Pc_in; 
input 		Rd_en; 
output [127:0]	Dout; 
output 	 reg    Dout_valid; 
 
reg [127:0] mem [0:63];
//reg 		Dout_valid; 
 
assign Dout = mem [Pc_in>>2];   

always @(posedge clk or posedge reset) begin
	if(reset) begin
		`include "bubble.txt"
		Dout_valid <= 1'b0;   
	end else begin
		if(Rd_en)
			Dout_valid <= 1'b1;       
	end

end

endmodule
