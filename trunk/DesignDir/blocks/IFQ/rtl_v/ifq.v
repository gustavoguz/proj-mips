//-----------------------------------------------------
// Design Name 	: IFQ
// File Name   	: ifq.v
// Function    	: 
// 		Pc_out: 32bits del program counter (PC) usado para calculo de direcciones de salto
// 		Inst: 32 bits del opcode de la instruccin a ser decodificada.
// 		Empty: Seal que indica que la IFQ esta vaca
// 		Rd_en: Seal de lectura de una instruccin de la IFQ
// 		Jmp_branch_address: Nuevo valor que debe tomar el PC, 32 bits
// 		Jmp_branch_valid: seal que indica que el valor de jmp_branch_address es vlido.
// Coder  	: 
// Other	:
//-----------------------------------------------------

module ifq (
	input [127:0]	Dout,
	input 		Dout_valid,
	input 		Rd_en,
	input [31:0]	Jmp_branch_address,
	input 		Jmp_branch_valid,
	input 		clk,
	input 		reset, 

	output reg  [31:0]	Pc_in,
	output 		Rd_en_cache,
	output reg [31:0]	Pc_out,
	output [31:0]	Inst,
	output 		Empty 
	);

reg BypassC;

reg [3:0]wp;
reg [3:0]rp; 
 
wire [31:0]Inst_w;
wire [127:0]QueueMux1;
wire [31:0]Mux1ByPass;
wire [31:0]DatMux2;
wire [2:0]flagPointer;

assign flagPointer = wp[3:2] - rp[3:2];
assign Empty = (flagPointer == 0)? 1'b1:1'b0;

assign full = (flagPointer > 2'b10) ? 1'b1 : 1'b0; 
assign Rd_en_cache = !full;

assign Inst = Inst_w;
always@(posedge clk or posedge reset)
begin 
 if (reset)begin
		Pc_in <= 32'b0;
		wp <= 4'b0000;
	end else begin
		if (Jmp_branch_valid)begin
			Pc_in <= {Jmp_branch_address[31:2],2'b00};  
			wp <= 5'b0;
		end else begin
			if (!full & Dout_valid)begin
				Pc_in <= Pc_in + 4;
				wp <= wp + 4;
			end
		end
	end    
 end 
 
 always @(posedge clk or posedge reset)begin 
	if (reset)begin
	   	BypassC <= 1'b1;
    		rp <= 4'b0000;
		  Pc_out <= 32'b0; 
	end else begin
		if (Jmp_branch_valid)begin
	  		BypassC <= 1'b1;
			rp <= {3'b000,Jmp_branch_address[1:0]};  
			Pc_out <= Jmp_branch_address;
		end else begin
			//if (Rd_en & Dout_valid)begin
			if (Rd_en)begin
				rp <= rp + 1'b1;
				Pc_out <= Pc_out + 1;
			  	BypassC <= 1'b0;
			end			  
		end
	end
end

IFQ_Queue Queue(
.Dout(QueueMux1),
.Din(Dout), 
.clk(clk),
.reset(reset),
.rp(rp[3:2]),
.wp(wp[3:2]),
.wvalid(Dout_valid)); 

IFQ_MuxA FromQueue(
.Din(QueueMux1),
.Dout(Mux1ByPass),
.rp(rp[1:0]));

IFQ_MuxA ByPassMX(
.Din(Dout),
.Dout(DatMux2),
.rp(rp[1:0]));

IFQ_Bypass Pass(
.InQueue(Mux1ByPass),
.InPass(DatMux2),
.Dout(Inst_w),
.ByPass(BypassC));

endmodule

module IFQ_MuxA(Din, Dout, rp);
  output [31:0] Dout;
  input [127:0] Din;
  input [1:0]rp;
  
  reg [31:0] Dout;
  
always @(*)
begin

 case (rp) 
    0 : Dout = Din[31:0]; 
    1 : Dout = Din[63:32]; 
    2 : Dout = Din[95:64]; 
    3 : Dout = Din[127:96]; 
  default : ; 
 endcase 
  
end
endmodule

module IFQ_Bypass(InQueue, InPass, Dout, ByPass);
  input [31:0]InQueue;
  input [31:0]InPass;
  input ByPass;
  output [31:0]Dout;
  reg [31:0]Dout;
  
  always @(*)
  begin
    if(ByPass)
      Dout=InPass;
    else
      Dout=InQueue;    
  end
  
endmodule


module IFQ_Queue(Dout, Din, clk, reset, rp, wp, wvalid);

  output [127:0]Dout; 
  input [127:0]Din;  
  input clk;
  input reset;
  input [1:0]rp; 
  input [1:0]wp;  
  input wvalid;

reg [127:0]Queue [0:3];

assign Dout = Queue[rp];

always @(posedge clk or posedge reset)
begin
if (reset)
  begin
  Queue[0] <= 128'b0;
  Queue[1] <= 128'b0;
  Queue[2] <= 128'b0;
  Queue[3] <= 128'b0; 
  end
else
  begin
    if (wvalid)
  Queue[wp] <= Din;
  end  
end
endmodule
