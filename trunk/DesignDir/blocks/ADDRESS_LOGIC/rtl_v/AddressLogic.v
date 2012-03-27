/****************************************************************************************************/
// Title      : Address Logic and Calculation for Program Counter Verilog File
// File       : AddressLogic.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : Las instrucciones del tipo Jump son ejecutadas por la unidad de despacho a lo
//		  igual que el cálculo de las direcciones de salto tanto para Jumps como para
//		  Branches. En caso de un Jump, la dirección es calculada combinatoriamente
//		  (lógica combinacional) y presentada al IFQ ese mismo ciclo.
// Check IFQ PC OUT if +4 is added there or here
// PC  OUT + 4 is added at IFQ
//
/****************************************************************************************************/  

// Address Logic without register for branch address
module AddressLogic(
			input 		        is_jump,
			input           normal_addr,
			input	 [31:0]	  pc_plus4,  
			input	 [15:0]	  immediate,
			input  [25:0]   address,
			output	[31:0]   Jmp_branch_address
			);

// normal_addr = 1 : Normal PC+4 Address, 0 : Jump Address			
// is_jump = 1 : Normal PC+4 Address or Jump Address, 0 : Branch Address

                                          //should be pc_plus4 or pc?
assign Jmp_branch_address = (is_jump) ? (normal_addr) ? (pc_plus4) : ( { pc_plus4[31:28], address, 2'b00 } )  : ( pc_plus4 + ( { {14{immediate[15]}}, immediate, 2'b00 } ) );

endmodule

// Address Logic with register for branch address
module AddressLogic_r(
      input           clk,
      input           rst,
			input 		        is_jump,
			input           normal_addr,
			input	 [31:0]	  pc_plus4,  
			input	 [15:0]	  immediate,
			input  [25:0]   address,
			output	[31:0]   Jmp_branch_address
			);

// normal_addr = 1 : Normal PC+4 Address, 0 : Jump Address			
// is_jump = 1 : Normal PC+4 Address or Jump Address, 0 : Branch Address

   reg [31:0] branch_addr_reg;
	  
   always@(posedge clk, posedge rst) begin
   
      branch_addr_reg <= (rst) ? 32'h00000000 : ( pc_plus4 + ( { {14{immediate[15]}}, immediate, 2'b00 } ) ); 
      
   end	
                                          //should be pc_plus4 or pc?
   assign Jmp_branch_address = (is_jump) ? (normal_addr) ? (pc_plus4) : ( { pc_plus4[31:28], address, 2'b00 } )  : ( branch_addr_reg );

endmodule
