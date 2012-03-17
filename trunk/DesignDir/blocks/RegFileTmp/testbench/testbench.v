//Testbench: RegFileTmp

`timescale 1ns / 100ps

module testbench;
	reg			clock;
	reg			reset;
	reg 	[41: 0]		Data_In;
	reg 	[ 4: 0]		Waddr;
	reg			New_entry;
	reg			Update_entry;
	wire	[41: 0]		Data_out1;
	reg	[ 4: 0]		Rd_Addr1;
	wire	[41: 0]		Data_out2;
	reg	[ 4: 0]		Rd_Addr2;

regfiletmp regfiletmp (
	.clock(clock),
	.reset(reset),
	.Data_In(Data_In),
	.Waddr(Waddr),
	.New_entry(New_entry),
	.Update_entry(Update_entry),
	.Data_out1(Data_out1),
	.Rd_Addr1(Rd_Addr1),
	.Data_out2(Data_out2),
	.Rd_Addr2(Rd_Addr2)
);

integer i;
// | rd_reg	| PC    | Inst_type | spec_data | spec_valid | valid |
// | [41:37]	|[36:5] | [4:3]	    |      [2]  |   [1]	     |  [0]  |
always begin
	#5 clock = !clock;
end

initial begin
	clock = 0;
	reset = 1;
#5	reset = 0;
	Update_entry=0;
	New_entry =0;
	Rd_Addr1 =0;
	Rd_Addr2 =0;

//write new entry
	for (i=0;i<33;i=i+1) begin
#10		Data_In = {i,32'b1000_0000_0000_0000_0000_0000_0000_0001,2'b10,1'b1,1'b0,1'b1};
		Waddr 	= i;
		New_entry = 1;
	end
	New_entry = 0;
//read status
	for (i=0;i<33;i=i+1) begin
#10		Rd_Addr1 = i;
		Rd_Addr2 = i+1;
	end	
// update entry
#20	
	Update_entry =1;
	Data_In = {5'b00000,32'b0000_0000_0000_0000_0000_0000_0000_0000,2'b11,1'b1,1'b1,1'b1};
	Waddr 	= 3;
#20
	Rd_Addr1 = 3;
		
# 20 $finish;
end

endmodule
