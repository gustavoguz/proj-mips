//Testbench: ICache

`timescale 1ns / 100ps

module testbench;

        reg                   clk;
        reg                   reset;
        reg   [ 31:0]         Pc_in;
        reg                   Rd_en;
        wire  [127:0]         Dout;
        wire                  Dout_valid;


i_cache i_cache  (
        .clk   (clk),
        .reset (reset),
        .Pc_in (Pc_in),
        .Rd_en (Rd_en),
        .Dout  (Dout),
        .Dout_valid (Dout_valid)
         );
always 
	#5 clk = ! clk;

initial 
begin
	clk=0;
	reset =1;
	Pc_in =0;
	Pc_in =Pc_in<<4;
	Rd_en =0;
	#24 Rd_en =1;	
	#20 Rd_en =0;
	    Pc_in =4;
	Pc_in =Pc_in<<4;
	#24 Rd_en =1;	
	#24 Rd_en =1;	
	#20 Rd_en =0;
	    Pc_in =8;
	Pc_in =Pc_in<<4;
	#24 Rd_en =1;	
		
end

initial 
	#200 $finish;





always @ (posedge Rd_en) 
begin
	#1
	if (Pc_in[31:4] == 0)
		if (Dout == {32'b0,32'b1,32'b10,32'b11})
			$display ("Test 1: PASS Pc_in %d , Dout %h",  Pc_in[31:4], Dout);
	        else
	                $display ("Test 1: FAIL Pc_in %d , Dout %h",  Pc_in[31:4], Dout);			
	#1
	if (Pc_in[31:4] == 4)
		if (Dout == {32'b100,32'b101,32'b110,32'b111})
			$display ("Test 2: PASS Pc_in %d , Dout %h",  Pc_in[31:4], Dout);
	        else
	                $display ("Test 2: FAIL Pc_in %d , Dout %h",  Pc_in[31:4], Dout);			
	#1
	if (Pc_in[31:4] == 8)
		if (Dout == {32'b1000,32'b1001,32'b1010,32'b1011})
			$display ("Test 3: PASS Pc_in %d , Dout %h",  Pc_in[31:4], Dout);
	        else
			$display ("Test 3: FAIL Pc_in %d , Dout %h",  Pc_in[31:4], Dout);			

end
endmodule
