

module testbench;

parameter WIDTH = 5;
parameter DEPTH = 32;
parameter ADDRESSWIDTH = 6;

reg clock;
reg reset;
reg [WIDTH-1 : 0] inData;
reg new_data;
reg out_data;
wire [WIDTH-1 : 0] outData;
wire full;

integer i;
order_queue order_queue (clock, reset, inData, new_data, out_data, outData, full);

initial 
begin
clock=0;
reset=0;
end

always 
	#5 clock=!clock;

initial
begin
	#30
	reset=1;
	$display ("START: writing 32 elements");
	for(i = 0; i<DEPTH+10; i=i+1)
	begin
	#10
	inData=i;
	new_data=1;
	out_data=0;
	end
	$display ("END: writing 32 elements");
	$display ("START: Reading 32 elements");
	for(i = 0; i<DEPTH+10; i=i+1)
	begin
	#10
	inData=0;
	new_data=0;
	out_data=1;
	if (outData==i)
		$display ("outData=%d",outData);
	else 
		$display ("ERROR: outData=%d i=%d",outData,i);
	end
	$display ("END: Reading 32 elements");
	
	#30
	for(i = 0; i<DEPTH+100; i=i+1)
	begin
	#10
	inData=4;
	new_data=1;
	out_data=1;
	end

	new_data=0;
	out_data=0;
$finish;

end

always  @ * 
begin
if (i== 33 && full == 1)
	$display ("Test 1: PASS: fifo= full: i=%d, new_data=%d",i, new_data);


end
endmodule
