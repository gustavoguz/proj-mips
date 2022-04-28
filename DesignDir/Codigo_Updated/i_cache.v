
// La I-Cache la vamos a implementar utilizando una BRAM de 32 x 128,
// entonces podemos almacenar 128 instrucciones. 
// La BRAM en nuestro diseo mas bien se comporta como una ROM ya que 
// el contenido es pre-cargado durante la sntesis o al inicio de la simulacin.


// Pc_in: la direccin de entrada de 32 bits.
// Rd_en: senal de control de lectura activa en alto.
// Dout: la linea de cache de 128 bits
// Dout_valid: seal que indica que los datos en Dout son validos.

module i_cache  (
        input                   clk,
	      input 			               reset,
        input   [ 31:0]         Pc_in,
        input                   Rd_en,
        output  [127:0]         Dout,
        output                  Dout_valid
        );

reg [31:0] mem [127:0]; 

reg Dout_valid_reg;
reg [127:0] Dout_reg;

assign Dout_valid = Rd_en;
//assign Dout_valid = Dout_valid_reg;
//assign Dout = {mem [Pc_in[31:4]+3], mem [Pc_in[31:4]+2],mem [Pc_in[31:4]+1],mem [Pc_in[31:4]]};
assign Dout = {mem [Pc_in[31:4]], mem [Pc_in[31:4]+1],mem [Pc_in[31:4]+2],mem [Pc_in[31:4]+3]};
//assign Dout = Dout_reg;

always@(posedge clk, posedge reset) begin

   if(reset) begin
      Dout_valid_reg <= 1'b0;
      //Dout_reg <= 128'h0;
   end
   else begin
      Dout_valid_reg <= Rd_en;
      //Dout_reg <= {mem [Pc_in[31:4]], mem [Pc_in[31:4]+1],mem [Pc_in[31:4]+2],mem [Pc_in[31:4]+3]};   
   end   
end 


always @ (posedge clk, posedge reset)
begin
	if (reset == 1'b1) begin
	`include "bubble.txt"
	end
end 

endmodule
