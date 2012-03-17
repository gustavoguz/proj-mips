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
