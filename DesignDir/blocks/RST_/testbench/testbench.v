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
	wire 	[31:0]	Wen1_rst;

rst rst (
  	.clock(clock),
  	.reset(reset),

  	.Rsaddr_rst	(Rsaddr_rst),
  	.Rstag_rst 	(Rstag_rst),
  	.Rsvalid_rst	(Rsvalid_rst),
  	
  	.Rtaddr_rst	(Rtaddr_rst),
	.Rttag_rst	(Rttag_rst),
  	.Rtvalid_rst	(Rtvalid_rst),
  
  	.RB_tag_rst(RB_tag_rst),
	.RB_valid_rst(RB_valid_rst),

 	.Wdata_rst(Wdata_rst),
  	.Waddr_rst(Waddr_rst),
	.Wen0_rst(Wen0_rst),
	.Wen_rst(Wen_rst),
	.Wen1_rst(Wen1_rst) 
	);

integer i;

always begin 
#5	clock=!clock;
end

initial  begin
	clock = 0;
	reset = 1;
#10	reset = 0;
	Wen0_rst=Wen1_rst;
	RB_tag_rst  =0;
	RB_valid_rst=1;
//write all registers
for (i=0; i<32; i=i+1) begin
#5  	Wen_rst=1;
	Wdata_rst=i;
	Waddr_rst=i;
$display ("Write -> $d",i);
end
#5  	Wen_rst=0;

// Read all registers 
for (i=0; i<32; i=i+1) begin
#5  	Rsaddr_rst=i;
$display ("$d",i);
end

for (i=0; i<32; i=i+1) begin
#10  	Rtaddr_rst=i;
end

for (i=0; i<32; i=i+1) begin
#10  	Rsaddr_rst=i;
  	Rtaddr_rst=i;
end
	RB_tag_rst  =1;
	RB_valid_rst=1;


#30	$finish;
end

endmodule
