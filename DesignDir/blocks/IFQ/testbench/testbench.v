//Testbench: dummy

`timescale 1ns / 100ps

module testbench;


   reg clk;
   reg reset;

   wire [31:0] 	Pc_in;
   wire        	Rd_en_cache;
   wire [127:0] Dout;
   wire 	Dout_valid;
   wire  [31:0] Pc_out;
   wire  [31:0] Inst;
   wire         Empty;
   reg 		Rd_en;
   reg [31:0] 	Jmp_branch_address;
   reg 		Jmp_branch_valid;

i_cache i_cache  (
        .clk   (clk),
        .reset (reset),
        .Pc_in (Pc_in),
        .Rd_en (Rd_en_cache),
        .Dout  (Dout),
        .Dout_valid (Dout_valid)
         );


ifq ifq (
   .clk (clk),
   .reset (reset),
   .Pc_in (Pc_in),
   .Rd_en_cache (Rd_en_cache),
   .Dout (Dout),
   .Dout_valid (Dout_valid),
   .Pc_out (Pc_out),
   .Inst (Inst),
   .Empty (Empty),
   .Rd_en (Rd_en),
   .Jmp_branch_address (Jmp_branch_address),
   .Jmp_branch_valid (Jmp_branch_valid)
);


always 
	#5 clk= !clk;

initial begin
	clk=0;
	reset =1;
	Rd_en=0;
	#10 reset =0;
	Rd_en=1;
	#40 
	Rd_en=1;
	#50 
	Rd_en=1;
end

initial begin	
	Jmp_branch_address=0;
	Jmp_branch_valid=0;
	#80 Jmp_branch_address=320;//|8'b10100_0000;
	#80 Jmp_branch_valid=0;
end

initial 
#400 $finish;

endmodule
