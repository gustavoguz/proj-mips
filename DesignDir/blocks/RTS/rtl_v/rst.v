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
  	input       	Wen_rst,
	input 	[31:0] 	Wen_rst 
	);

endmodule
