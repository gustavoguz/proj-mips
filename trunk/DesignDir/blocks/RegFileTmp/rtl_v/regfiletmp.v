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
	input 	[72: 0]		Data_In,
	input 	[ 4: 0]		Waddr,
	input			New_entry,
	input			Update_entry,
	output	[72: 0]		Data_out1,
	input	[ 4: 0]		Rd_Addr1,
	output	[72: 0]		Data_out2,
	input	[ 4: 0]		Rd_Addr2,
	input			flush
);

// | rd_reg	| PC     | Inst_type | spec_data | spec_valid | valid |
// | [72:68]	|[67:36] | [35:34]   |   [33:2]  |   [1]      |  [0]  |

reg 	[72: 0] RegFile [31: 0];
integer i;

always @ (posedge clock or posedge reset or posedge flush) 
begin
	if (reset | flush) 
	begin
		for(i=0;i< 32;i=i+1)
		begin
		RegFile[i] <= 0; 
		`ifdef DEBUG_RegFileTmp $display ("INFO : RegFileTmp : REGFILETEMP = %p",RegFile); `endif
		end	
	end else 
	begin
		if (New_entry)
		begin
			RegFile [Waddr] <= Data_In; 
			`ifdef DEBUG_RegFileTmp $display ("INFO : RegFileTmp : New Entry addr %d = %d REGFILETEMP=%p",Waddr,Data_In,RegFile); `endif
		end else if (Update_entry)
		begin
			`ifdef DEBUG_RegFileTmp $display ("INFO : RegFileTmp : Update Entry addr=%d Spec_data=%d spec_valid=%d",Waddr,Data_In[33:2],Data_In[1]); `endif
			RegFile [Waddr][1] <= Data_In[1]; 
			RegFile [Waddr][33:2] <= Data_In[33:2]; 
		end
	end
end

assign Data_out1 = RegFile[Rd_Addr1];
assign Data_out2 = RegFile[Rd_Addr2];
endmodule
