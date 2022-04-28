//-----------------------------------------------------
// Design Name 	: Mux21
// File Name   	: mux21.v
// Function    	: Multiplexor de 2 a 1 y select de 1 bit
// Coder  	: 
// Other	:
//-----------------------------------------------------

module mux21 (
        input   sel,
        input   [31:0]  din_0,
        input   [31:0]  din_1,
        output reg [31:0]  dout
);

always @ (sel or din_0 or din_1)
begin
        case ( sel )
                1'b0: dout = din_0;
                1'b1: dout = din_1;
                default: dout = 0;
       endcase
end

endmodule
