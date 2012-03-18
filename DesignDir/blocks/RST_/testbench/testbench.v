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
/*
always @(posedge clock) begin
//for (i=0; i<32; i=i+1) begin
if (i<32) begin 
  	Wen_rst=1;
	Wdata_rst=i;
	Waddr_rst=i;
$display ("Write -> %d",i);
i=i+1;
end else begin
	i=0;
end
if (i== 31)
	Wen_rst=0;
end
*/
initial  begin
	clock = 0;
	reset = 1;
#10	reset = 0;
	i=0;
	Wen0_rst=0;
	RB_tag_rst  =0;
	RB_valid_rst=0;
//write all registers

for (i=0; i<32; i=i+1) begin
#10 if (clock) begin 
  	Wen_rst=1;
	Wdata_rst=i;
	Waddr_rst=i;
	$display ("Write -> %d",i);
end
end

#50  	Wen_rst=0;

// Read all registers 
for (i=0; i<32; i=i+1) begin
#10  	Rsaddr_rst=i;
$display ("Read Rs: %d, %d, %d , %d ",Rsaddr_rst,i,Rstag_rst, Rsvalid_rst);
end

for (i=0; i<32; i=i+1) begin
#10  	Rtaddr_rst=i;
$display ("Read Rt: %d, %d, %d , %d ",Rtaddr_rst,i,Rttag_rst, Rtvalid_rst);
end

for (i=0; i<32; i=i+1) begin
#10  	Rsaddr_rst=i;
  	Rtaddr_rst=i;
$display ("Read Rs: %d, %d, %d , %d ",Rsaddr_rst,i,Rstag_rst, Rsvalid_rst);
$display ("Read Rt: %d, %d, %d , %d ",Rtaddr_rst,i,Rttag_rst, Rtvalid_rst);
end
// borrar un tag
#20	RB_tag_rst  =2;
	RB_valid_rst=1;
  	Rsaddr_rst=2;
$display ("Clear tag 2: %d, %d, %d , %d ",Rsaddr_rst,i,Rstag_rst, Rsvalid_rst);


#30	$finish;
end

endmodule
