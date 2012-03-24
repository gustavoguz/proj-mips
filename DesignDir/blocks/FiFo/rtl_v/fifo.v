//-----------------------------------------------------
// Design Name 	: Fifo
// File Name   	: tagfifo.v
// Function    	: 
// Coder  	: 
// Other	:
//-----------------------------------------------------

module fifo (
	rdata, 
	wfull, 
	rempty, 
	wdata,
	winc, 
	wclk, 
	wrst_n, 
	rinc, 
	rclk, 
	rrst_n,
	increment
	);

parameter DSIZE = 5;
parameter ASIZE_F = 6; // ASIZE = Max_number -1
parameter ASIZE = 31; // ASIZE = Max_number -1

output [DSIZE-1:0] rdata;
output wfull;
output rempty;
input [DSIZE-1:0] wdata;
input winc, wclk, wrst_n;
input rinc, rclk, rrst_n;
input increment;

reg [ASIZE_F-1:0] wptr;
reg [ASIZE_F-1:0] rptr;

parameter MEMDEPTH = ASIZE+1;

reg [DSIZE-1:0] ex_mem [0:MEMDEPTH-1];

always @(posedge wclk or negedge wrst_n) begin
//always @* begin  
       if (!wrst_n) begin
		wptr = 0;
	end else if (winc && !wfull) begin
                ex_mem[wptr[DSIZE-1:0]] = wdata;
                wptr = wptr+1;
		`ifdef DEBUG_OrderQueue $display("INFO : FIFO : write -> %b, %p",wptr,ex_mem); `endif
	end
	if (wfull) begin
		`ifdef DEBUG_OrderQueue $display("WARN : FIFO : FULL "); `endif
	end
end

always @(posedge rclk or negedge rrst_n) begin
//always @* begin
        if (!rrst_n) begin 
		rptr = 0;
        end else if (rinc && !rempty && !increment) begin
		rptr = rptr+1;
		`ifdef DEBUG_OrderQueue $display("INFO : FIFO : read -> %d, %p",rptr,ex_mem); `endif
	end else if (rinc && !rempty && increment) begin
		rptr = rptr;
		`ifdef DEBUG_OrderQueue $display("INFO : FIFO : read -> %d, %p",rptr,ex_mem); `endif
	end
	if (rempty) begin 
		`ifdef DEBUG_OrderQueue $display("WARN : FIFO : EMPTY "); `endif
	end
end
		
assign rdata = ex_mem[rptr[DSIZE-1:0]];

assign rempty = (!rrst_n)? 0 : (rptr == wptr);
assign wfull  = (!rrst_n)? 0 :({~wptr[ASIZE_F-1], wptr[ASIZE_F-2:0]} == rptr);

endmodule
