//-----------------------------------------------------
// Design Name 	: Branch Logic
// File Name   	: branchlogic.v
// Function    	: Las instrucciones del tipo Jump son ejecutadas por la unidad de despacho a lo
//		  igual que el cálculo de las direcciones de salto tanto para Jumps como para
//		  Branches. En caso de un Jump, la dirección es calculada combinatoriamente
//		  (lógica combinacional) y presentada al IFQ ese mismo ciclo.
// Coder  	: 
// Other	: Check IFQ PC OUT if +4 is added there or here
//         PC  OUT + 4 is added at IFQ
//-----------------------------------------------------

// Branch Logic without register for branch address
module  branchlogic (
			input 		        is_jump,
			input	 [31:0]	  pc_plus4,  
			input	 [15:0]	  immediate,
			input  [25:0]   address,
			output	[31:0]   Jmp_branch_address
			);
			
// is_jump = 1 : Jump Address, 0 : Branch Address
                                           //should be pc_plus4 or pc?
assign Jmp_branch_address = (is_jump) ? ( { pc_plus4[31:28], address, 2'b00 } )  : ( pc_plus4 + ( { {14{immediate[15]}}, immediate, 2'b00 } ) );

endmodule


// Branch Logic with register for branch address
module  branchlogic_r (
      input           clk,
      input           rst,
			input 		        is_jump,
			input	 [31:0]	  pc_plus4,  
			input	 [15:0]	  immediate,
			input  [25:0]   address,
			output	[31:0]   Jmp_branch_address
			);
	 
	 
	 reg [31:0] branch_addr_reg;
	  
   always@(posedge clk, posedge rst) begin
   
      branch_addr_reg <= (rst) ? 32'h00000000 : ( pc_plus4 + ( { {14{immediate[15]}}, immediate, 2'b00 } ) ); 
      
   end	
			
   // is_jump = 1 : Jump Address, 0 : Branch Address
                                           //should be pc_plus4 or pc?
   assign Jmp_branch_address = (is_jump) ? ( { pc_plus4[31:28], address, 2'b00 } )  : ( branch_addr_reg );

endmodule
