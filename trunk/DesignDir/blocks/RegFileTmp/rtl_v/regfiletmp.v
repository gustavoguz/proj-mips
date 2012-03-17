//-----------------------------------------------------
// Design Name 	: RegFileTmp
// File Name   	: regfileTmp.v
// Function    	: 
// Coder  	: 
// Other	:
//-----------------------------------------------------


module regfiletmp (
	input			clock,
	input			reset,
	input 	[41: 0]		Data_In,
	input 	[ 4: 0]		Waddr,
	input			New_entry,
	input			Update_entry,
	output	[41: 0]		Data_out1,
	input	[ 4: 0]		Rd_Addr1,
	output	[41: 0]		Data_out2,
	input	[ 4: 0]		Rd_Addr2
);

// | rd_reg	| PC    | Inst_type | spec_data | spec_valid | valid |
// | [41:38]	|[37:5] | [4:3]	    |      [2]  |   [1]	     |  [0]  |

reg 	[41: 0] RegFile [32: 0];
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
		if (New_entry)
		begin
			RegFile [Waddr] <= Data_In; 
		end else if (Update_entry)
		begin
			RegFile [Waddr][1] <= Data_In[1]; 
			RegFile [Waddr][2] <= Data_In[2]; 
		end
	end
end

assign Data_out1 = RegFile[Rd_Addr1];
assign Data_out2 = RegFile[Rd_Addr2];
endmodule
