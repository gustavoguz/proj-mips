//-----------------------------------------------------
// Design Name 	: TagFifo
// File Name   	: tagfifo.v
// Function    	: Los TAGs son generados por el TAG FIFO, la cual es una simple FIFO de
//		  tamanio 5 x 32. Tiene un apuntador de escritura y lectura de 6 bits (rp y wp
//		  respectivamente). WP es inicializado con el valor de “100000” y el RP es
//		  inicializado a “000000”. Las entradas del 0 al 31 son inicializadas con los
//		  números del 0 al 31. Entonces la FIFO inicialmente se encuentra llena.
//		  Cuando una instrucción es despachada, el apuntador de lectura es
//		  incrementado y el siguiente TAG es leído. Cuando el Retire BUS publica una
//		  TAG valido, el TAG es escrito y el WP es incrementado. La unidad de despacho
// 		  solo levanta la senial de lectura cuando una instrucción con registro destino
//		  puede ser despachada. La unidad de despacho no lee un TAG cuando la
//		  instrucción no tiene un registro destino o no puede ser despachada.
// Coder  	: 
// Other	:
//-----------------------------------------------------

module tagfifo(
   clock,
   reset,
   RB_Tag,
   RB_Tag_Valid,
   Rd_en,
   Tag_Out,
   tagFifo_full,
   tagFifo_empty
);

parameter DSIZE = 5;
parameter ASIZE = 6; // ASIZE = Max_number -1

output 	[DSIZE-1:0] 	Tag_Out;
output 			tagFifo_full;
output 			tagFifo_empty;
input 	[DSIZE-1:0] 	RB_Tag;
input 			RB_Tag_Valid;
input			clock;
input			reset;
input 			Rd_en;

reg [ASIZE:0] wptr;
reg [ASIZE:0] rptr;

parameter MEMDEPTH = 1<<ASIZE;

reg [DSIZE-1:0] ex_mem [0:MEMDEPTH-1];

always @(posedge clock or negedge reset)
        if (!reset) 
		wptr <= 0;
        else if (RB_Tag_Valid && !tagFifo_full) begin
                ex_mem[wptr[ASIZE-1:0]] <= RB_Tag;
                wptr <= wptr+1;
        end

always @(posedge clock or negedge reset)
        if (!reset) 
		rptr <= 0;
        else if (Rd_en && !tagFifo_empty) 
		rptr <= rptr+1;

assign Tag_Out = ex_mem[rptr[ASIZE-1:0]];
assign tagFifo_empty = (rptr == wptr);
assign tagFifo_full = ({~wptr[ASIZE-1], wptr[ASIZE-2:0]} == rptr);


endmodule
