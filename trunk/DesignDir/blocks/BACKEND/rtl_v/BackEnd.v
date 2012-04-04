
module BackEnd(
   // Port Declarations
   input                Clk,
   input                Rst,  
   // Dispatch Common Signals for Queues
   input       [ 4:0]   Dispatch_Rd_Tag,
   input       [31:0]   Dispatch_Rs_Data,
   input       [ 4:0]   Dispatch_Rs_Tag,
   input                Dispatch_Rs_Data_Val,
   input       [31:0]   Dispatch_Rt_Data,
   input       [ 4:0]   Dispatch_Rt_Tag,
   input                Dispatch_Rt_Data_Val,     
   // Dispatch Signals Only for Int
   input       [ 3:0]   Dispatch_Opcode_Int,
   input       [ 4:0]   Dispatch_Shfamt_Int,   
   // Dispatch Signals Only for LS
   input                Dispatch_Opcode_LS,
   input       [15:0]   Dispatch_Imm_LS,   
   // Dispatch Enable Queues Signals
   input                Dispatch_Enable_Int0,
   input                Dispatch_Enable_Int1,
   input                Dispatch_Enable_Mult,
   input                Dispatch_Enable_LS,   
   // Dispatch Full Queues Signals
   output               IssueQueInt0_Full,
   output               IssueQueInt1_Full,
   output               IssueQueMult_Full,
   output               IssueQueLS_Full,
   // CDB Bus Interface
   input       [ 4:0]   CDB_Tag_In,
   input       [31:0]   CDB_Data_In,
   input                CDB_Valid_In,
   output      [ 4:0]   CDB_Tag_Out,
   output      [31:0]   CDB_Data_Out,
   output               CDB_Valid_Out,
   output               CDB_Branch_Out,
   output               CDB_Branch_Taken_Out,
   // Retire Bus Interface 
   input                RB_Store_Ready,
   input                RB_Flush_Valid,
   // ALU's Overflow and Carry Out  
   output               ALU0_Overflow,
   output               ALU0_Carry_Out,
   output               ALU1_Overflow,
   output               ALU1_Carry_Out   
  );

   /** Internal Signals **/   
   // IssueQueueInt0-ALU0-IssueUnit
   wire        IssueQueInt0_Ready;
   wire [31:0] IssueQueInt0_Rs_Data;
   wire [31:0] IssueQueInt0_Rt_Data;
   wire [ 4:0] IssueQueInt0_Rd_Tag;
   wire [ 3:0] IssueQueInt0_Opcode;
   wire [ 4:0] IssueQueInt0_Shfamt;
   wire        IssueblkInt0_Issue;
   wire [31:0] ALU0_Result;
   wire [ 4:0] ALU0_Tag_Out;
   wire        ALU0_Branch;
   wire        ALU0_Branch_Taken;  
   // IssueQueueInt1-ALU1-IssueUnit
   wire        IssueQueInt1_Ready;
   wire [31:0] IssueQueInt1_Rs_Data;
   wire [31:0] IssueQueInt1_Rt_Data;
   wire [ 4:0] IssueQueInt1_Rd_Tag;
   wire [ 3:0] IssueQueInt1_Opcode;
   wire [ 4:0] IssueQueInt1_Shfamt;
   wire        IssueblkInt1_Issue;
   wire [31:0] ALU1_Result;
   wire [ 4:0] ALU1_Tag_Out;
   wire        ALU1_Branch;
   wire        ALU1_Branch_Taken;
   // IssueQueueMult-Multiplier-IssueUnit
   wire        IssueQueMult_Ready;
   wire [15:0] IssueQueMult_Rs_Data;
   wire [15:0] IssueQueMult_Rt_Data;
   wire [ 4:0] IssueQueMult_Rd_Tag;
   wire        IssueblkMult_Issue;
   wire [31:0] Multiplier_Result; 
   // IssueQueueLS-DCache-IssueUnit
   wire        IssueQueLS_Ready;
   wire [31:0] IssueQueLS_Data;
   wire [31:0] IssueQueLS_Address;
   wire [ 4:0] IssueQueLS_Rd_Tag;
   wire        IssueQueLS_Opcode;
   wire        IssueblkLS_Issue;
   wire [31:0] DCache_Data;
   wire [ 4:0] DCache_Tag_Out;
   wire        DCache_Ready_Out;
   wire        DCache_Issue_In;
    

   IssueQueueInt IssueQueueInt_inst0(

   // Port Declarations (inputs)
   .Clk                   (Clk),
   .Rst                   (Rst),
   // Interface with Dispatch (inputs / full-output)
   .Dispatch_Rd_Tag       (Dispatch_Rd_Tag),
   .Dispatch_Rs_Data      (Dispatch_Rs_Data),
   .Dispatch_Rs_Tag       (Dispatch_Rs_Tag),
   .Dispatch_Rs_Data_Val  (Dispatch_Rs_Data_Val), 
   .Dispatch_Rt_Data      (Dispatch_Rt_Data),
   .Dispatch_Rt_Tag       (Dispatch_Rt_Tag),
   .Dispatch_Rt_Data_Val  (Dispatch_Rt_Data_Val), 
   .Dispatch_Opcode       (Dispatch_Opcode_Int),
   .Dispatch_Shfamt       (Dispatch_Shfamt_Int),
   .Dispatch_Enable       (Dispatch_Enable_Int0),
   .IssueQue_Full         (IssueQueInt0_Full),
   // Interface with CDB (inputs)
   .CDB_Tag               (CDB_Tag_In),
   .CDB_Data              (CDB_Data_In),
   .CDB_Valid             (CDB_Valid_In),
   // Interface with Issue Unit (outputs / blk-input)
   .IssueQue_Ready        (IssueQueInt0_Ready),
   .IssueQue_Rs_Data      (IssueQueInt0_Rs_Data),
   .IssueQue_Rt_Data      (IssueQueInt0_Rt_Data),
   .IssueQue_Rd_Tag       (IssueQueInt0_Rd_Tag),
   .IssueQue_Opcode       (IssueQueInt0_Opcode),
   .IssueQue_Shfamt       (IssueQueInt0_Shfamt),
   .Issueblk_Issue        (IssueblkInt0_Issue),  
   // Interface with Retire Bus (input)
   .RB_Flush_Valid        (RB_Flush_Valid)
);


   ALU ALU_inst0( 
  
   // Port Declarations (inputs)
   .Operand1          (IssueQueInt0_Rs_Data), 
   .Operand2          (IssueQueInt0_Rt_Data),
   .Shfamt            (IssueQueInt0_Shfamt),
   .Tag_In            (IssueQueInt0_Rd_Tag),
   .ALU_Opcode        (IssueQueInt0_Opcode),
   // (outputs)
   .Result            (ALU0_Result),
   .Tag_Out           (ALU0_Tag_Out),
   .ALU_Branch        (ALU0_Branch),
   .ALU_Branch_Taken  (ALU0_Branch_Taken),
   .Carry_Out         (ALU0_Carry_Out),
   .Overflow          (ALU0_Overflow)
   );

   IssueQueueInt IssueQueueInt_inst1(

   // Port Declarations (inputs)
   .Clk                   (Clk),
   .Rst                   (Rst),
   // Interface with Dispatch (inputs / full-output)
   .Dispatch_Rd_Tag       (Dispatch_Rd_Tag),
   .Dispatch_Rs_Data      (Dispatch_Rs_Data),
   .Dispatch_Rs_Tag       (Dispatch_Rs_Tag),
   .Dispatch_Rs_Data_Val  (Dispatch_Rs_Data_Val), 
   .Dispatch_Rt_Data      (Dispatch_Rt_Data),
   .Dispatch_Rt_Tag       (Dispatch_Rt_Tag),
   .Dispatch_Rt_Data_Val  (Dispatch_Rt_Data_Val), 
   .Dispatch_Opcode       (Dispatch_Opcode_Int),
   .Dispatch_Shfamt       (Dispatch_Shfamt_Int),
   .Dispatch_Enable       (Dispatch_Enable_Int1),
   .IssueQue_Full         (IssueQueInt1_Full),
   // Interface with CDB (inputs)
   .CDB_Tag               (CDB_Tag_In),
   .CDB_Data              (CDB_Data_In),
   .CDB_Valid             (CDB_Valid_In),
   // Interface with Issue Unit (outputs / blk-input)
   .IssueQue_Ready        (IssueQueInt1_Ready),
   .IssueQue_Rs_Data      (IssueQueInt1_Rs_Data),
   .IssueQue_Rt_Data      (IssueQueInt1_Rt_Data),
   .IssueQue_Rd_Tag       (IssueQueInt1_Rd_Tag),
   .IssueQue_Opcode       (IssueQueInt1_Opcode),
   .IssueQue_Shfamt       (IssueQueInt1_Shfamt),
   .Issueblk_Issue        (IssueblkInt1_Issue),  
   // Interface with Retire Bus (input)
   .RB_Flush_Valid        (RB_Flush_Valid)
);

   ALU ALU_inst1( 
  
   // Port Declarations (inputs)
   .Operand1          (IssueQueInt1_Rs_Data), 
   .Operand2          (IssueQueInt1_Rt_Data),
   .Shfamt            (IssueQueInt1_Shfamt),
   .Tag_In            (IssueQueInt1_Rd_Tag),
   .ALU_Opcode        (IssueQueInt1_Opcode),
   // (outputs)
   .Result            (ALU1_Result),
   .Tag_Out           (ALU1_Tag_Out),
   .ALU_Branch        (ALU1_Branch),
   .ALU_Branch_Taken  (ALU1_Branch_Taken),
   .Carry_Out         (ALU1_Carry_Out),
   .Overflow          (ALU1_Overflow)
   );


  
   IssueQueueMult IssueQueueMult_inst0 (

   // Port Declarations( inputs)
   .Clk                   (Clk),
   .Rst                   (Rst),
   // Interface with Dispatch (inputs / full-output) // 15:0 FOR RS/RT Data
   .Dispatch_Rd_Tag       (Dispatch_Rd_Tag),
   .Dispatch_Rs_Data      (Dispatch_Rs_Data[15:0]),
   .Dispatch_Rs_Tag       (Dispatch_Rs_Tag),
   .Dispatch_Rs_Data_Val  (Dispatch_Rs_Data_Val), 
   .Dispatch_Rt_Data      (Dispatch_Rt_Data[15:0]),
   .Dispatch_Rt_Tag       (Dispatch_Rt_Tag),
   .Dispatch_Rt_Data_Val  (Dispatch_Rt_Data_Val), 
   .Dispatch_Enable       (Dispatch_Enable_Mult),
   .IssueQue_Full         (IssueQueMult_Full),
   // Interface with CDB (inputs)
   .CDB_Tag               (CDB_Tag_In),
   .CDB_Data              (CDB_Data_In[15:0]),
   .CDB_Valid             (CDB_Valid_In),  
   // Interface with Issue Unit (outputs / blk-input)
   .IssueQue_Ready        (IssueQueMult_Ready),
   .IssueQue_Rs_Data      (IssueQueMult_Rs_Data),
   .IssueQue_Rt_Data      (IssueQueMult_Rt_Data),
   .IssueQue_Rd_Tag       (IssueQueMult_Rd_Tag),
   .Issueblk_Issue        (IssueblkMult_Issue),  
   // Interface with Retire Bus (input)
   .RB_Flush_Valid        (RB_Flush_Valid)
); 

   Mult Mult_inst0(
  
   // Port Declarations (inputs)
   .Clk     (Clk),
   .Rst     (Rst),
   .OpA     (IssueQueMult_Rs_Data),
   .OpB     (IssueQueMult_Rt_Data),
   // (output)
   .Result  (Multiplier_Result)
   );


   IssueQueueLS IssueQueueLS_inst0 (

   // Port Declarations (inputs)
   .Clk                    (Clk),
   .Rst                    (Rst),
   // Interface with Dispatch (inputs / full-output) 
   .Dispatch_Rd_Tag        (Dispatch_Rd_Tag),
   .Dispatch_Rs_Data       (Dispatch_Rs_Data),
   .Dispatch_Rs_Tag        (Dispatch_Rs_Tag),
   .Dispatch_Rs_Data_Val   (Dispatch_Rs_Data_Val),
   .Dispatch_Rt_Data       (Dispatch_Rt_Data),
   .Dispatch_Rt_Tag        (Dispatch_Rt_Tag),
   .Dispatch_Rt_Data_Val   (Dispatch_Rt_Data_Val),
   .Dispatch_Opcode        (Dispatch_Opcode_LS),
   .Dispatch_Imm           (Dispatch_Imm_LS),
   .Dispatch_Enable        (Dispatch_Enable_LS),
   .IssueQue_Full          (IssueQueLS_Full),
   // Interface with CDB (inputs)
   .CDB_Tag                (CDB_Tag_In),
   .CDB_Data               (CDB_Data_In),
   .CDB_Valid              (CDB_Valid_In), 
   // Interface with Issue Unit (outputs / blk-input)
   .IssueQue_Ready         (IssueQueLS_Ready),
   .IssueQue_Data          (IssueQueLS_Data),
   .IssueQue_Address       (IssueQueLS_Address),
   .IssueQue_Rd_Tag        (IssueQueLS_Rd_Tag),
   .IssueQue_Opcode        (IssueQueLS_Opcode),
   .Issueblk_Issue         (IssueblkLS_Issue), 
   // Interface with Retire Bus (inputs)
   .RB_Store_Ready         (RB_Store_Ready),
   .RB_Flush_Valid         (RB_Flush_Valid)  
);

   DCache DCache_inst0 ( 

   // Port Declarations (inputs)
   .Clk                  (Clk),
   .Rst                  (Rst),
   // Interface with Issue Queue LS (inputs /output issue_out)
   .IssueQue_Data_In     (IssueQueLS_Data),
   .IssueQue_Address     (IssueQueLS_Address),
   .IssueQue_Tag_In      (IssueQueLS_Rd_Tag),
   .IssueQue_Opcode      (IssueQueLS_Opcode),
   .IssueQue_Ready_In    (IssueQueLS_Ready),
   .IssueQue_Issue_Out   (IssueblkLS_Issue),                        
   // Interface with Issue Unit (input issue_in / outputs)
   .IssueUnit_Issue_In   (DCache_Issue_In),
   .IssueUnit_Data_Out   (DCache_Data),
   .IssueUnit_Tag_Out    (DCache_Tag_Out), 
   .IssueUnit_Ready_Out  (DCache_Ready_Out)
   );



   IssueUnit IssueUnit_inst0(
   // Port Declarations (inputs)
   .Clk                         (Clk),
   .Rst                         (Rst),
   // Interface with Queues (Ready (Input)/Issue (Output) Signals)
   .Ready_Int0                  (IssueQueInt0_Ready),
   .Ready_Int1                  (IssueQueInt1_Ready),
   .Ready_Mult                  (IssueQueMult_Ready),
   .Ready_LS                    (DCache_Ready_Out),
   .Issue_Int0                  (IssueblkInt0_Issue),
   .Issue_Int1                  (IssueblkInt1_Issue),
   .Issue_Mult                  (IssueblkMult_Issue),
   .Issue_LS                    (DCache_Issue_In),
   // Interface with CDB (outputs)
   .CDB_Tag                     (CDB_Tag_Out),
   .CDB_Data                    (CDB_Data_Out),
   .CDB_Valid                   (CDB_Valid_Out),
   .CDB_Branch                  (CDB_Branch_Out),
   .CDB_Branch_Taken            (CDB_Branch_Taken_Out),
   // Interface with Integer Issue Unit 0 (inputs)
   .IntIssue0_Tag               (ALU0_Tag_Out),
   .IntIssue0_Result            (ALU0_Result),
   .IntIssue0_ALU_Branch        (ALU0_Branch),
   .IntIssue0_ALU_Branch_Taken  (ALU0_Branch_Taken),
   // Interface with Integer Issue Unit 1 (inputs)
   .IntIssue1_Tag               (ALU1_Tag_Out),
   .IntIssue1_Result            (ALU1_Result),
   .IntIssue1_ALU_Branch        (ALU1_Branch),
   .IntIssue1_ALU_Branch_Taken  (ALU1_Branch_Taken),
    // Interface with LS Issue Unit (inputs)
   .LSIssue_Tag                 (DCache_Tag_Out),
   .LSIssue_Result              (DCache_Data),
   // Interface with Mult Issue Unit (inputs)
   .MultIssue_Tag               (IssueQueMult_Rd_Tag),
   .MultIssue_Result            (Multiplier_Result)
);
      
  
endmodule
