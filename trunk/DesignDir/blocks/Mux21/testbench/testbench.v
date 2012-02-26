//Testbench: Mux42

`timescale 1ns / 100ps

module testbench;

reg   sel;
reg   [31:0]  din_0;
reg   [31:0]  din_1;
wire  [31:0]  dout;

reg clk;
reg enable;
reg reset;
reg [1:0] count;
mux21 mux21 (
       .sel   (sel),
       .din_0 (din_0),
       .din_1 (din_1),
       .dout  (dout)
);

   
always 
      #5  clk =  ! clk; 

always @ (posedge clk)
if (reset == 1'b1) begin
  count <= 0;
end else if ( enable == 1'b1) begin
  count <= count + 1;
end


initial begin
     clk = 0; 
     reset = 0; 
     enable = 0;
 
	enable=1'b1;
	reset =1'b1;
	#15  reset =1'b0;
	din_0 = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	din_1 = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
end

always @ (count) 
begin
sel = count[0];
end

always @ (sel or din_0)
begin
	#1
	if (sel == 0)
		if (din_0 == dout)
			$display ("Test 1: PASS");
		else 
			$display ("Test 1: FAIL sel =%d, din_0=%d, dout=%d", sel, din_0,dout );
end

always @ (sel or din_1)
begin
	#1
	if (sel == 1 )
		if (din_1 == dout) 
			$display ("Test 2: PASS");
		else 
			$display ("Test 2: FAIL sel =%d, din_1=%d, dout=%d", sel, din_1,dout);
end

initial 
 #200 $finish;

endmodule
