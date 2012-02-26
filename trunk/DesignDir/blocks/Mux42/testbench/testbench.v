//Testbench: Mux42

`timescale 1ns / 100ps

module testbench;

reg   [1:0]   sel;
reg   [31:0]  din_0;
reg   [31:0]  din_1;
reg   [31:0]  din_2;
reg   [31:0]  din_3;
wire  [31:0]  dout;

reg clk;
reg enable;
reg reset;
reg [1:0] count;
mux42 mux42 (
       .sel   (sel),
       .din_0 (din_0),
       .din_1 (din_1),
       .din_2 (din_2),
       .din_3 (din_3),
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
	din_2 = 32'b0000_0000_0000_0000_0000_0000_0000_0010;
	din_3 = 32'b0000_0000_0000_0000_0000_0000_0000_0011;
end

always @ (count) 
begin
sel = count;
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

always @ (sel or din_2 )
begin
	#1
	if (sel == 2 )
		if ( din_2 == dout) 
			$display ("Test 3: PASS");
		else 
			$display ("Test 3: FAIL sel =%d, din_2=%d, dout=%d", sel, din_2,dout);
end

always @ (sel or din_3)
begin
	#1
	if (sel == 3 )
		if (din_3 == dout)
			$display ("Test 4: PASS");
		else 
			$display ("Test 4: FAIL sel =%d, din_3=%d, dout=%d", sel, din_3,dout);
end

initial 
 #200 $finish;

endmodule
