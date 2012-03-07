//Testbench: RTS

`timescale 1ns / 100ps

module testbench;
  	reg        	clock;
  	reg        	reset;

  	reg  	[ 4:0] 	Rsaddr_rst;
  	wire 	[ 4:0] 	Rstag_rst;
  	wire       	Rsvalid_rst;

  	reg  	[ 4:0] 	Rtaddr_rst;
  	wire 	[ 4:0] 	Rttag_rst;
  	wire       	Rtvalid_rst;
  
  	reg  	[ 4:0] 	RB_tag_rst;
	reg        	RB_valid_rst;

 	reg  	[ 4:0] 	Wdata_rst;
  	reg  	[ 4:0] 	Waddr_rst;
	reg 	[31:0] 	Wen0_rst;
	reg 		Wen_rst;
	wire 		Wen1_rst;

rst rst (
  	.clock(clock),
  	.reset(reset),

  	.Rsaddr_rst(Rsaddr_rst),
  	.Rstag_rst(Rstag_rst),
  	.Rsvalid_rst(Rsvalid_rst),
  	
	.Rttag_rst(Rttag_rst),
  	.Rtvalid_rst(Rtvalid_rst),
  
  	.RB_tag_rst(RB_tag_rst),
	.RB_valid_rst(RB_valid_rst),

 	.Wdata_rst(Wdata_rst),
  	.Waddr_rst(Waddr_rst),
	.Wen0_rst(Wen0_rst),
	.Wen_rst(Wen_rst),
	.Wen1_rst(Wen1_rst) 
	);
always begin 
#5	clock=!clock;
end

initial  begin
	clock = 0;
	reset = 1;
#10	reset = 0;
#30	$finish;
end

endmodule
