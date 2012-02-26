// Pc_out: 32bits del program counter (PC) usado para calculo de direcciones de salto
// Inst: 32 bits del opcode de la instruccin a ser decodificada.
// Empty: Seal que indica que la IFQ esta vaca
// Rd_en: Seal de lectura de una instruccin de la IFQ
// Jmp_branch_address: Nuevo valor que debe tomar el PC, 32 bits
// Jmp_branch_valid: seal que indica que el valor de jmp_branch_address es vlido.

module ifq (
   input              clk,
   input              reset,
   output reg  [31:0] Pc_in,
   output reg         Rd_en_cache,
   input      [127:0] Dout,
   input              Dout_valid,
   output reg  [31:0] Pc_out,
   output reg  [31:0] Inst,
   output reg         Empty,
   input              Rd_en,
   input       [31:0] Jmp_branch_address,
   input              Jmp_branch_valid
);

   reg  [127:0] mem   	[3:0];
   reg  [127:0] mem_reg [3:0];

   reg  [  4:0] wptr;
   reg  [  4:0] wptr_reg;
   reg  [  4:0] rptr;
   reg  [  4:0] rptr_reg;

   reg  [ 31:0] pcin;
   reg  [ 31:0] pcin_reg;
   reg  [ 31:0] pcout;
   reg  [ 31:0] pcout_reg;

   reg is_full;
   reg is_empty;
   reg is_valid_read;
   reg do_inc_rptr;
   reg is_valid_write;
   reg do_inc_wptr;
   reg bypass_mux_sel;
   
 always @(*) begin : signals
      is_empty = (wptr_reg[4] == rptr_reg[4]) && (wptr_reg[3:2] == rptr_reg[3:2]);
      is_full  = (wptr_reg[4] != rptr_reg[4]) && (wptr_reg[3:2] == rptr_reg[3:2]);

      bypass_mux_sel = Jmp_branch_valid | is_empty;
      is_valid_read  = Rd_en      & ~is_empty;
      is_valid_write = Dout_valid & ~is_full;
      do_inc_rptr    = is_valid_read | bypass_mux_sel;
      do_inc_wptr    = is_valid_write;

      rptr = (Jmp_branch_valid) ? 'h0 : (do_inc_rptr) ? rptr_reg + 1 : rptr_reg;
      wptr = (Jmp_branch_valid) ? 'h0 : (do_inc_wptr) ? wptr_reg + 4 : wptr_reg;

      pcout = (Jmp_branch_valid) ? Jmp_branch_address +  4 : (do_inc_rptr) ? pcout_reg + 4 : pcout_reg;
      pcin  = (Jmp_branch_valid) ? Jmp_branch_address + 16 : (do_inc_wptr) ? pcin_reg + 16 : pcin_reg;
   end

   wire  [ 31:0] mem_mux_out, inst_mux_out, bypass_mux_out;
   reg   [127:0] mem_line_128, Dout_cache;

   always @(*) begin : bypass_func
      Dout_cache = Dout;
      mem_line_128 = mem_reg[rptr_reg[3:2]];
   end 
        mux42 Mux1 (.sel(rptr_reg[1:0]),
	.din_0(Dout_cache[127:96]),
	.din_1(Dout_cache[ 95:64]),
	.din_2(Dout_cache[ 63:32]),
	.din_3(Dout_cache[ 31: 0]),
	.dout(inst_mux_out));

	mux42 Mux2 (.sel(rptr_reg[1:0]),
       	.din_0	(mem_line_128[127:96]),	
       	.din_1 	(mem_line_128[ 95:64]),
       	.din_2	(mem_line_128[ 63:32]),
       	.din_3	(mem_line_128[ 31: 0]),
       	.dout	(mem_mux_out)	);
   
	mux21 bypass_mux (.sel	(bypass_mux_sel),
        	.din_0	(mem_mux_out),
        	.din_1	(inst_mux_out),
        	.dout	(bypass_mux_out)	);

   always @(*) begin :bypass_signal
      
      Pc_in = (Jmp_branch_valid) ? Jmp_branch_address : pcin_reg;
      Rd_en_cache   = ~(Jmp_branch_valid | is_full);

      Pc_out = (Jmp_branch_valid) ? pcout : pcout_reg;
      Inst        = bypass_mux_out;
      Empty       = is_empty;
   end

   always @(*) begin :mem_bl
      integer i;
      for(i = 0; i < 4; i = i + 1) mem[i] = mem_reg[i];

      mem[wptr_reg[3:2]] = (Dout_valid) ? Dout : mem_reg[wptr_reg[3:2]];
   end

   always @(posedge clk) begin :reset_ptr
      rptr_reg <= (reset) ? 5'b0 : rptr;
      wptr_reg <= (reset) ? 5'b0 : wptr;
   end

   always @(posedge clk) begin :reset_pc
      pcin_reg  <= (reset) ? 32'b0 : pcin;
      pcout_reg <= (reset) ? 32'b0 : pcout;
   end

   always @(posedge clk) begin :mem_reg_bl
      integer i;
      for(i = 0; i < 4; i = i + 1) begin
         mem_reg[i] <= (reset) ? 'h0 : mem[i];
      end
   end

endmodule

