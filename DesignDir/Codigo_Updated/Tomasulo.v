/****************************************************************************************************/
// Title      : Tomasulo Module Declarations/Insts Verilog File
// File       : Tomasulo.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : Apr-3-2012
// Notes                 : 
//
/****************************************************************************************************/  


module Tomasulo( 
   // Port Declarations
   input                Clk,
   input                Rst     
  );
  
   /** Internal Signals **/ 
   // ICache--IFQ
   wire [ 31:0] ICacheIFQ_Pc_in;
   wire         ICacheIFQ_Rd_en;
   wire [127:0] ICacheIFQ_Dout;
   wire         ICacheIFQ_Dout_valid;
   // IFQ--Dispatch
   wire [ 31:0] IFQDispatch_Pc_out;
   wire [ 31:0] IFQDispatch_Inst;
   wire         IFQDispatch_Empty;
   wire         IFQDispatch_Rd_en;
   wire [ 31:0] IFQDispatch_Jmp_branch_address;
   wire         IFQDispatch_Jmp_branch_valid;
   // Dispatch--Queues Common Signals
   wire [ 31:0] DispatchQue_Rs_Data;
   wire [  4:0] DispatchQue_Rs_Tag;
   wire         DispatchQue_Rs_Data_Valid;
   wire [ 31:0] DispatchQue_Rt_Data;
   wire [  4:0] DispatchQue_Rt_Tag;
   wire         DispatchQue_Rt_Data_Valid;
   wire [  4:0] DispatchQue_Rd_Tag;
   // Dispatch--Queues Integer Signals (A=0, B=1)
   wire         DispatchQueInt0_Enable;
   wire         DispatchQueInt0_Full;
   wire         DispatchQueInt1_Enable;
   wire         DispatchQueInt1_Full;
   wire [  3:0] DispatchQueInt_Opcode;
   wire [  4:0] DispatchQueInt_Shfamt;
   // Dispatch--Queues LS Signals
   wire         DispatchQueLS_Enable;
   wire         DispatchQueLS_Full;
   wire         DispatchQueLS_Opcode;
   wire [ 15:0] DispatchQueLS_Imm;
   // Dispatch--Queues Mult Signals
   wire         DispatchQueMult_Enable;
   wire         DispatchQueMult_Full;   
   // Retire Bus Signals to Queues
   wire         QueRB_Flush_Valid;
   wire         QueRB_Store_Ready;
   // CDB Bus Signals
   wire [  4:0] CDB_Tag;
   wire [ 31:0] CDB_Data;
   wire         CDB_Valid;
   wire         CDB_Branch;
   wire         CDB_Branch_Taken;   
   // ALU Overflow-Carryout Signals
   wire         ALU0_Overflow;
   wire         ALU0_CarryOut;
   wire         ALU1_Overflow;
   wire         ALU1_CarryOut; 
  
   i_cache i_cache_inst0  (
   // Port Declarations
   .clk        (Clk),
   .reset      (Rst),
   // Inputs
   .Pc_in      (ICacheIFQ_Pc_in),
   .Rd_en      (ICacheIFQ_Rd_en),
   // Outputs
   .Dout       (ICacheIFQ_Dout),
   .Dout_valid (ICacheIFQ_Dout_valid)
   );
  
   ifq ifq_inst0 (
   // Port Declarations
   .clk                (Clk),
   .reset              (Rst),
   // Interface with I_Cache
   //--Outputs
   .Pc_in              (ICacheIFQ_Pc_in),
   .Rd_en_cache        (ICacheIFQ_Rd_en),
   //--Inputs
   .Dout               (ICacheIFQ_Dout),
   .Dout_valid         (ICacheIFQ_Dout_valid),
   // Interface with Dispatch
   //--Outputs
   .Pc_out             (IFQDispatch_Pc_out),
   .Inst               (IFQDispatch_Inst),
   .Empty              (IFQDispatch_Empty),
   //--Inputs
   .Rd_en              (IFQDispatch_Rd_en),
   .Jmp_branch_address (IFQDispatch_Jmp_branch_address),
   .Jmp_branch_valid   (IFQDispatch_Jmp_branch_valid)
   );
   
   
   dispatch_unit dispatch_unit_inst0(
	 .clock                    (Clk),
	 .reset                    (Rst),
	 // Interface con IFQ:
	 //--Inputs
	 .ifetch_pc_4              (IFQDispatch_Pc_out),		
	 .ifetch_intruction        (IFQDispatch_Inst), 	
	 .ifetch_empty             (IFQDispatch_Empty),
	 //--Outputs		
	 .Dispatch_jmp_addr        (IFQDispatch_Jmp_branch_address),	
	 .Dispatch_jmp             (IFQDispatch_Jmp_branch_valid),		
	 .Dispatch_ren             (IFQDispatch_Rd_en),									
	 // Interface con Colas de ejecucion:
	 // - Senales comunes para todas las colas de ejecucion.
	 //--Outputs	
	 .dispatch_rs_data         (DispatchQue_Rs_Data),	
	 .dispatch_rs_data_valid   (DispatchQue_Rs_Data_Valid),	
	 .dispatch_rs_tag          (DispatchQue_Rs_Tag),	
	 .dispatch_rt_data         (DispatchQue_Rt_Data),	
	 .dispatch_rt_data_valid   (DispatchQue_Rt_Data_Valid),	
	 .dispatch_rt_tag          (DispatchQue_Rt_Tag),	
	 .dispatch_rd_tag          (DispatchQue_Rd_Tag),	
	 // - Senales especificas para la cola de ejecucion de enteros.
	 //--Inputs
	 .issueque_integer_full_A  (DispatchQueInt0_Full),	
	 .issueque_integer_full_B  (DispatchQueInt1_Full),	
	 //--Outputs
	 .dispatch_en_integer_A    (DispatchQueInt0_Enable),	
	 .dispatch_en_integer_B    (DispatchQueInt1_Enable),		
	 .dispatch_opcode          (DispatchQueInt_Opcode),	
	 .dispatch_shfamt          (DispatchQueInt_Shfamt),		
	 // - Senales especificas para la Cola de ejecucion de acceso a memoria.
	 //--Inputs
	 .issueque_full_ld_st      (DispatchQueLS_Full),	
	 //--Outputs
	 .dispatch_en_ld_st        (DispatchQueLS_Enable),	
	 .dispatch_opcode_ld_st    (DispatchQueLS_Opcode),	
	 .dispatch_imm_ld_st       (DispatchQueLS_Imm),	
	 // - Senales especificas para la Cola de ejecucion de multiplicaciones.
	 //--Input
	 .issueque_mul_full        (DispatchQueMult_Full),
	 //--Outputs
	 .dispatch_en_mul          (DispatchQueMult_Enable),
	 // - CDB Bus Interface
	 //--Inputs
	 .Cdb_rd_tag               (CDB_Tag),
	 .Cdb_valid                (CDB_Valid),
	 .Cdb_data                 (CDB_Data),
	 .Cdb_branch               (CDB_Branch),
	 .Cdb_branch_taken         (CDB_Branch_Taken),
	 // Retire Bus Interface
	 //--Outputs
	 .Retire_store_ready       (QueRB_Store_Ready),	
	 .flush                    (QueRB_Flush_Valid)
	);
  
   BackEnd BackEnd_inst0(
   // Port Declarations
   .Clk                   (Clk),
   .Rst                   (Rst),  
   // Dispatch Common Signals for Queues (inputs)
   //--Inputs
   .Dispatch_Rd_Tag       (DispatchQue_Rd_Tag),
   .Dispatch_Rs_Data      (DispatchQue_Rs_Data),
   .Dispatch_Rs_Tag       (DispatchQue_Rs_Tag),
   .Dispatch_Rs_Data_Val  (DispatchQue_Rs_Data_Valid),
   .Dispatch_Rt_Data      (DispatchQue_Rt_Data),
   .Dispatch_Rt_Tag       (DispatchQue_Rt_Tag),
   .Dispatch_Rt_Data_Val  (DispatchQue_Rt_Data_Valid),     
   // Dispatch Signals Only for Int (inputs)
   //--Inputs
   .Dispatch_Opcode_Int   (DispatchQueInt_Opcode),
   .Dispatch_Shfamt_Int   (DispatchQueInt_Shfamt),   
   // Dispatch Signals Only for LS (inputs)
   //--Inputs
   .Dispatch_Opcode_LS    (DispatchQueLS_Opcode),
   .Dispatch_Imm_LS       (DispatchQueLS_Imm),   
   // Dispatch Enable Queues Signals (inputs)
   //--Inputs
   .Dispatch_Enable_Int0  (DispatchQueInt0_Enable),
   .Dispatch_Enable_Int1  (DispatchQueInt1_Enable),
   .Dispatch_Enable_Mult  (DispatchQueMult_Enable),
   .Dispatch_Enable_LS    (DispatchQueLS_Enable),   
   // Dispatch Full Queues Signals (outputs)
   //--Outputs
   .IssueQueInt0_Full     (DispatchQueInt0_Full),
   .IssueQueInt1_Full     (DispatchQueInt1_Full),
   .IssueQueMult_Full     (DispatchQueMult_Full),
   .IssueQueLS_Full       (DispatchQueLS_Full),
   // CDB Bus Interface (inputs/outputs)
   //--Inputs
   .CDB_Tag_In            (CDB_Tag),
   .CDB_Data_In           (CDB_Data),
   .CDB_Valid_In          (CDB_Valid),
   //--Outputs
   .CDB_Tag_Out           (CDB_Tag),
   .CDB_Data_Out          (CDB_Data),
   .CDB_Valid_Out         (CDB_Valid),
   .CDB_Branch_Out        (CDB_Branch),
   .CDB_Branch_Taken_Out  (CDB_Branch_Taken),
   // Retire Bus Interface (inputs)
   //--Inputs
   .RB_Store_Ready        (QueRB_Store_Ready),
   .RB_Flush_Valid        (QueRB_Flush_Valid),
   // ALU's Overflow and Carry Out (outputs)
   //--Outputs
   .ALU0_Overflow         (ALU0_Overflow),
   .ALU0_Carry_Out        (ALU0_CarryOut),
   .ALU1_Overflow         (ALU1_Overflow),
   .ALU1_Carry_Out        (ALU1_CarryOut) 
  );  







endmodule

  
  