//-----------------------------------------------------
// Design Name 	: RegFile
// File Name   	: regfile.v
// Function    	: 
// Coder  	: 
// Other	:
//-----------------------------------------------------


module regfile(
	input			clock,
	input			reset,
	input 	[31: 0]		Data_In,
	input 	[ 4: 0]		Waddr,
	input			W_en,
	output	[31: 0]		Data_out1,
	input	[ 4: 0]		Rd_Addr1,
	output	[31: 0]		Data_out2,
	input	[ 4: 0]		Rd_Addr2
);

reg 	[32: 0] RegFile [32: 0];
integer i;

always @ (posedge clock or posedge reset) 
begin
	if (reset) 
	begin
		for(i=0;i< 32;i=i+1)
		begin 
		if (i==0)
		RegFile[i] <= 0; 
		else if (i==1)
		RegFile[i] <= 1; 
		else if (i==2)
		RegFile[i] <= 2; 
		else if (i==3)
		RegFile[i] <= 3; 
		else if (i==4)
		RegFile[i] <= 4; 
		else if (i==5)
		RegFile[i] <= 5; 
		else if (i==31)
		RegFile[i] <= 31; 
		else
		RegFile[i] <= 0; 
		end	
	end else 
	begin
		if (W_en)
		begin
			RegFile [Waddr] <= Data_In; 
		end
	end
end

assign Data_out1 = RegFile[Rd_Addr1];
assign Data_out2 = RegFile[Rd_Addr2];
endmodule
