//-----------------------------------------------------
// Design Name 	: Mux42
// File Name   	: mux42.v
// Function    	: Multiplexor de 4  a 1  y select 2 bits
// Coder  	: 
// Other	:
//-----------------------------------------------------

module mux42 (
        input   [1:0]   sel,
        input   [31:0]  din_0,
        input   [31:0]  din_1,
        input   [31:0]  din_2,
        input   [31:0]  din_3,
        output reg [31:0]  dout
);

always @ (sel or din_0 or din_1 or din_2 or din_3)
begin
        case ( sel )
                2'b00: dout = din_0;
                2'b01: dout = din_1;
                2'b10: dout = din_2;
                2'b11: dout = din_3;
                default: dout = 0;
       endcase
end

endmodule
