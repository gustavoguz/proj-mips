//-----------------------------------------------------
// Design Name 	: RST
// File Name   	: rst.v
// Function    	: 

// Coder  	: 
// Other	:
//-----------------------------------------------------

module rst (
  	input        	clock,
  	input        	reset,

  	input  	[ 4:0] 	Rsaddr_rst,
  	output 	[ 4:0] 	Rstag_rst,
  	output       	Rsvalid_rst,

  	input  	[ 4:0] 	Rtaddr_rst,
  	output 	[ 4:0] 	Rttag_rst,
  	output       	Rtvalid_rst,
  
  	input  	[ 4:0] 	RB_tag_rst,
	input        	RB_valid_rst,

 	input  	[ 4:0] 	Wdata_rst,
  	input  	[ 4:0] 	Waddr_rst,
	input 	[31:0] 	Wen0_rst,
	input 		Wen_rst,
	output reg [31:0] 	Wen1_rst 
	);

reg 	[ 5:0] 	RST_reg 	[31:0];

wire 	[ 5:0]	CDB_Token;
reg 	[31:0]	Comparator;

integer i;
integer j;
integer k;


always@(posedge clock or posedge reset) begin
	if(reset) begin
		for (i=0; i< 32;i=i+1) begin
      			RST_reg [i] <= 6'b0_00000; //se ponen todos los registros como no validos.
		end
    	end else begin   
      		if(Wen_rst) begin
        		RST_reg [Waddr_rst] <= {1'b1, Wdata_rst};
      		end 
     /*  falta borrar los tags 
*/
    	end
end

always @* begin
	for (j=0; j< 32;j=j+1) begin
	 	Comparator [j] = (RST_reg[j] ~^ CDB_Token);
	end
end 

always @* begin
	for (k=0; k< 32;k=k+1) begin
	 	Wen1_rst [k] = Comparator[k] & (~Wen0_rst[k]);
	end
end 

assign CDB_Token = {RB_valid_rst,RB_tag_rst};

endmodule
