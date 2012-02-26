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
   input 		clock,
   input 		reset,
   input 	[4:0]  	RB_Tag,
   input 		RB_Tag_Valid,
   input 		Rd_en,
   output reg 	[4:0] 	Tag_Out,
   output reg 		tagFifo_full,
   output reg 		tagFifo_empty
);
   parameter DATA_WIDTH = 5;
   parameter DEPTH      = 32;

   function integer log2;
      input integer n;
      begin
         log2 = 0;
         while(2**log2 < n) begin
            log2 = log2 + 1;
         end
      end
   endfunction

   parameter ADDR_WIDTH = log2(DEPTH);
   reg  [ADDR_WIDTH   : 0]  rd_ptr; // note MSB is not really address
   reg  [ADDR_WIDTH   : 0]  wr_ptr; // note MSB is not really address
   wire [ADDR_WIDTH-1 : 0]  wr_loc;
   wire [ADDR_WIDTH-1 : 0]  rd_loc;
   reg  [DATA_WIDTH-1 : 0]  mem[DEPTH-1 : 0];

   assign wr_loc = wr_ptr[ADDR_WIDTH-1 : 0];
   assign rd_loc = rd_ptr[ADDR_WIDTH-1 : 0];

   always @(posedge clock) begin
      if (reset) begin
         wr_ptr <= 'h0;
         rd_ptr <= 'h0;
      end else begin
         if (RB_Tag_Valid & (~tagFifo_full))  wr_ptr <= wr_ptr + 1;
         if (Rd_en & (~tagFifo_empty)) rd_ptr <= rd_ptr + 1;
      end
   end

   // Empty if all the bits of rd_ptr and wr_ptr are the same.
   // Full if all bits except the MSB are equal and MSB differ.
   always @(rd_ptr or wr_ptr) begin
      //default catch-alls
      tagFifo_empty <= 1'b0;
      tagFifo_full  <= 1'b0;
		$display ("wr_ptr=%d, rd_ptr=%d ADDR_WIDTH=%d",wr_ptr,rd_ptr,ADDR_WIDTH);
      if (rd_ptr[ADDR_WIDTH-1:0] == wr_ptr[ADDR_WIDTH-1:0]) begin
         if(rd_ptr[ADDR_WIDTH] == wr_ptr[ADDR_WIDTH])
            begin
		tagFifo_empty <= 1'b1;
		$display ("wr_ptr=%d, rd_ptr=%d ADDR_WIDTH=%d",wr_ptr,rd_ptr,ADDR_WIDTH);
	    end
         else
            tagFifo_full  <= 1'b1;
      end
   end

   always @(posedge clock) begin
      if (RB_Tag_Valid) mem[wr_loc] <= RB_Tag;
   end

   // Comment out if you want a registered Tag_Out.
  // always @(*) begin
   //   Tag_Out = Rd_en ? mem[rd_loc]:'h0;
   //end
   // Uncomment if you want a registered Tag_Out.
   always @(posedge clock) begin
      if (reset)
         Tag_Out <= 'h0;
      else if (Rd_en)
         Tag_Out <= mem[rd_ptr];
      else
         Tag_Out <= Tag_Out;
   end
endmodule

