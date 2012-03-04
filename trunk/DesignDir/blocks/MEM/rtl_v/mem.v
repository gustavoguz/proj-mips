
module mem (
	input 		clk,
	input 		reset,
	input  [127:0] 	dataIn,
	output [127:0] 	dataOut,
	input  [1:0] 	Wrp,
	input 		Wr_en,
	input  [1:0]	Rdp
);

reg [127:0] ram [3:0]; 
assign dataOut = ram [Rdp]; 

always @(posedge clk or posedge reset) begin
	if(reset) begin
	
	end else begin
		if (Wr_en) begin
			ram [Wrp] <= dataIn [ 31: 0];
			ram [Wrp] <= dataIn [ 63:32];
			ram [Wrp] <= dataIn [ 95:64];
			ram [Wrp] <= dataIn [127:96];
		end	
	end
end

endmodule 

// +----+----+----+----+
// |    |    |    |    |  wrp = 0 11 00
// +----+----+----+----+
// |    |    |    |    |  wrp = 0 10 00
// +----+----+----+----+
// |    |    |    |    |  wrp = 0 01 00
// +----+----+----+----+
// |    |    |    |    |  wrp = 0 00 00 
// +----+----+----+----+
