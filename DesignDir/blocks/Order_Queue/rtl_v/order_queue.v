//-------------------------------------------------------------------------
// Design Name 	: Order Queue
// File Name   	: order_queue.v
// Function    	: El oreder queue es de 32 entradas, y se comporta 
//		  como una FIFO circular majada por un auntador de
//		  de lectura y uno de escritura. En esta cola se 
//		  lleva el orden en el que las intrucciones son
//		  despachadas y lso Rd tags son asignados.
//		  Data_in  = Rd_tag
//		  Data_out = Rd_tag apuntado por el Rd_ptr, siempre
//		  presete.
// Coder  	: 
// Other	:
//-------------------------------------------------------------------------

module order_queue (clock, reset, inData, new_data, out_data, outData, full, empty, increment, flush);

parameter WIDTH = 5;

input clock;
input reset;
input [WIDTH-1 : 0] inData;
input new_data;
input out_data;
input increment;
input flush;
output [WIDTH-1 : 0] outData;
output full;
output empty;

fifo fifo (
	.rdata	(outData), 
	.wfull	(full), 
	.rempty	(empty), 
	.wdata	(inData),
	.winc	(new_data), 
	.wclk	(clock), 
	.wrst_n	(!reset), 
	.rinc	(out_data), 
	.rclk	(clock), 
	.rrst_n	(!reset),
	.increment (increment),
	.flush(flush)
	);

endmodule
