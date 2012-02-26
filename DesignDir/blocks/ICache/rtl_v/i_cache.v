
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
	input 			reset,
        input   [ 31:0]         Pc_in,
        input                   Rd_en,
        output  [127:0]         Dout,
        output                  Dout_valid
        );

reg [31:0] mem [127:0];

assign Dout_valid = Rd_en;
assign Dout = {mem [Pc_in[31:4]], mem [Pc_in[31:4]+1],mem [Pc_in[31:4]+2],mem [Pc_in[31:4]+3]};

always @ (posedge clk, reset)
begin
	if (reset == 1'b0)
	`include "/home/gustavo/MDE/uP_Design/uP02032012/DesignDir/settings/programs/my_program.v"
end 

endmodule
