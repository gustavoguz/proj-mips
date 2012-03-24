
module testbench ();
        parameter DSIZE = 5;
        parameter ASIZE = 31;

        wire [DSIZE-1:0] rdata;
        wire wfull;
        wire rempty;

        reg [DSIZE-1:0] wdata;
        reg winc, wclk, wrst_n;
        reg rinc, rclk, rrst_n;
	reg increment;

integer i;

fifo fifo (
        .rdata (rdata),
        .wfull (wfull),
        .rempty (rempty),
        .wdata (wdata),
        .winc(winc),
        .wclk (wclk), 
        .wrst_n(wrst_n),
        .rinc(rinc), 
        .rclk(rclk), 
        .rrst_n(rrst_n),
        .increment(increment)
        );
always begin
#5      wclk = !wclk;
end
always begin
#5       rclk = !rclk;
end
always begin
//#10	increment=!increment;
#10	increment=1;
end
initial begin

        wclk=1;
        rclk=1;
        rrst_n=0;
        wrst_n=0;
	increment =0;
#10         
        rrst_n=1;
        wrst_n=1;


#1
        for (i=0;i<40;i=i+1) begin
#10             wdata=i;
                winc=1;
                rinc=0;
        end
        for (i=0;i<40;i=i+1) begin
#10             wdata=1;
                winc=0;
                rinc=1;
        end

#20
        for (i=0;i<40;i=i+1) begin
#10             wdata=i;
                winc=1;
                rinc=0;
        end
        for (i=0;i<40;i=i+1) begin
#10             wdata=1;
                winc=0;
                rinc=1;
        end
#20        
        for (i=0;i<40;i=i+1) begin
#10             wdata=i;
                winc=1;
                rinc=1;
        end
$finish; 

end 


always @* begin
 $display("wdata=%d,winc+%d,rinc+%d,rdata+%d,full+%d,empty+%d", wdata,winc, rinc,rdata,wfull,rempty);


end 


endmodule
