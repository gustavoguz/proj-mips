//Testbench: RegFile

`timescale 1ns / 100ps

module testbench;
	reg			clock;
	reg			reset;
	reg 	[31: 0]		Data_In;
	reg 	[ 4: 0]		Waddr;
	reg			W_en;
	wire	[31: 0]		Data_out1;
	reg	[ 4: 0]		Rd_Addr1;
	wire	[31: 0]		Data_out2;
	reg	[ 4: 0]		Rd_Addr2;

integer i;

regfile regfile(
	.clock(clock),
	.reset(reset),
	.Data_In(Data_In),
	.Waddr(Waddr),
	.W_en(W_en),
	.Data_out1(Data_out1),
	.Rd_Addr1(Rd_Addr1),
	.Data_out2(Data_out2),
	.Rd_Addr2(Rd_Addr2)
);

always 
begin
	#5 clock=!clock;
end

initial begin
	clock=0;
	reset=1;
#10	reset=0;
// write 
	for (i=0;i<33;i=i+1)
	begin
#10		Data_In=i;
		Waddr=i;
		W_en=1;
	end
//read
	for (i=0;i<33;i=i+1)
	begin	
#10		if( i % 2 == 0) 
		begin
			Rd_Addr1=i;
		end else begin
			Rd_Addr2=i;
		end
	end
//read the same addr
#10 
		Rd_Addr1=10;
		Rd_Addr2=10;
// read and write
#10
		Rd_Addr1=10;
		Rd_Addr2=10;
		Waddr=10;
		W_en=1;
		Data_In=1;
end

endmodule
