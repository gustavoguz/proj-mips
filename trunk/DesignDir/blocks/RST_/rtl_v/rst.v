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
	input 		Wen_rst,
	
	input 		[31:0] 	Wen0_rst,
	output  	[31:0] 	Wen1_rst 
	);

reg 	[ 5:0] 	RST_reg 	[31:0];

wire 	[ 5:0]	CDB_Token;
reg 	[31:0]	Comparator;

wire 	[31:0]	Wen0_rst_dec;
reg 	[31:0]	Wen1_rst_cod;

wire 	[ 4:0] 	Addr;
wire 		Clear_en;

integer i;
integer j;
integer k;
integer l;

always@(posedge clock or posedge reset) begin
	if(reset) begin
		for (i=0; i < 32; i=i+1 ) begin
      			RST_reg [i] <= 6'b0_00000; //se ponen todos los registros como no validos.
			//Wen1_rst[i] <= 0;
		end
    	end else begin   
      		if(Wen_rst) begin
        		RST_reg [Waddr_rst] <= {1'b1, Wdata_rst};
      		end 
		if(Clear_en) begin
        		RST_reg [Addr] <= {1'b0, 5'b0};
		end 
    	end
end

always @ (RST_reg or CDB_Token) begin
	for (j=0; j< 32;j=j+1) begin
	 	Comparator [j] = (RST_reg[j] == CDB_Token);
	end
end 

always @ (Comparator or Wen0_rst_dec) begin
	for (k=0; k< 32;k=k+1) begin
	 	Wen1_rst_cod [k] = Comparator[k] & (~Wen0_rst_dec[k]);
	end
end 

deco5_32 deco5_32 (
	.Waddr_rst 	(Waddr_rst), 
  	.Wen_rst 	(Wen_rst), 
  	.Wen0_rst	(Wen0_rst_dec)
	);
  
coder32_5 coder32_5 (
	.wen1_rst	(Wen1_rst_cod),
  	.Addr		(Addr),
  	.Clear_en	(Clear_en)
  	);

assign CDB_Token = {RB_valid_rst,RB_tag_rst};
assign Wen1_rst	 = Comparator;

// Read Rs and Rt
assign Rstag_rst 	= RST_reg[Rsaddr_rst][4:0];
assign Rttag_rst 	= RST_reg[Rtaddr_rst][4:0];
assign Rsvalid_rst 	= RST_reg[Rsaddr_rst][  5];
assign Rtvalid_rst 	= RST_reg[Rtaddr_rst][  5];

endmodule
