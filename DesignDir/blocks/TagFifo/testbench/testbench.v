//Testbench: TagFifo

`timescale 1ns / 100ps

module testbench;
   reg 			clock;
   reg 			reset;
   reg 		[4:0]  	RB_Tag;
   reg 			RB_Tag_Valid;
   reg 			Rd_en;
   wire 	[4:0] 	Tag_Out;
   wire 		tagFifo_full;
   wire 		tagFifo_empty;

integer i;

tagfifo tagfifo(
   .clock(clock),
   .reset(reset),
   .RB_Tag(RB_Tag),
   .RB_Tag_Valid(RB_Tag_Valid),
   .Rd_en(Rd_en),
   .Tag_Out(Tag_Out),
   .tagFifo_full(tagFifo_full),
   .tagFifo_empty(tagFifo_empty)
);

always begin
	#5	clock=!clock;
end


initial 
begin
	clock=0;
	reset=1;
#10	reset=0;
	for (i=0;i<33;i=i+1)
	begin
#10		RB_Tag_Valid=1;
		RB_Tag=i;
		Rd_en=0;
	end
#30
	for (i=0;i<35;i=i+1)
	begin
#10		RB_Tag_Valid=0;
		RB_Tag=i;
		Rd_en=1;
	end
#20
	for (i=0;i<35;i=i+1)
	begin
#10		RB_Tag_Valid=1;
		RB_Tag=i;
		Rd_en=1;
	end

#50
$finish;
end


endmodule
