/****************************************************************************************************/
// Title      : Issue Queue Load/Store Verilog File
// File       : IssueQueueLS.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : March-2012
// Notes                 : 
//
/****************************************************************************************************/  

module IssueQueueLS (

   // Port Declarations
   input                Clk,
   input                Rst,
   // Interface with Dispatch
   input       [ 4:0]   Dispatch_Rd_Tag,
   input       [31:0]   Dispatch_Rs_Data,
   input       [ 4:0]   Dispatch_Rs_Tag,
   input                Dispatch_Rs_Data_Val,   // '1' Data is valid; '0' Data is unknown
   input       [31:0]   Dispatch_Rt_Data,
   input       [ 4:0]   Dispatch_Rt_Tag,
   input                Dispatch_Rt_Data_Val,   // '1' Data is valid; '0' Data is unknown
   input                Dispatch_Opcode,
   input       [15:0]   Dispatch_Imm, ///// 16 o 32 bits?
   input                Dispatch_Enable,
   output reg           IssueQue_Full,
   // Interface with CDB
   input       [ 4:0]   CDB_Tag,
   input       [31:0]   CDB_Data,
   input                CDB_Valid,  // '1' Data and TAG are valid
   // Interface with Issue Unit
   output reg           IssueQue_Ready,
   output reg  [31:0]   IssueQue_Data,
   output reg  [31:0]   IssueQue_Address,
   output reg  [ 4:0]   IssueQue_Rd_Tag,
   output reg           IssueQue_Opcode,
   input                Issueblk_Issue,  // '1' Instruction has been issued
   // Interface with Retire Bus
   input                RB_Store_Ready,
   input                RB_Flush_Valid   // '1' Data inside queue must be flushed
);

   parameter N_QUEUE = 4;
   integer i;



   // Queue data-fields registers
   reg        opcode_reg  [0:N_QUEUE-1];
   reg [15:0] imm_reg     [0:N_QUEUE-1];
   reg [31:0] address_reg [0:N_QUEUE-1];
   reg [ 4:0] rd_tag_reg  [0:N_QUEUE-1];
   reg [ 4:0] rs_tag_reg  [0:N_QUEUE-1];
   reg [31:0] rs_data_reg [0:N_QUEUE-1];
   reg        rs_val_reg  [0:N_QUEUE-1];
   reg [ 4:0] rt_tag_reg  [0:N_QUEUE-1];
   reg [31:0] rt_data_reg [0:N_QUEUE-1];
   reg        rt_val_reg  [0:N_QUEUE-1];
   reg        valid_reg   [0:N_QUEUE-1];

   // Internal Signals
   reg valid_logic     [0:N_QUEUE-1];
   reg queue_add;
   reg queue_shift     [1:N_QUEUE-1];
   reg queue_rs_match  [0:N_QUEUE-1];
   reg queue_rt_match  [0:N_QUEUE-1];
   reg queue_ready     [0:N_QUEUE-1];
   reg queue_issue     [0:N_QUEUE-1];
   
   
   // Match(for Update) and Ready Queue Logic
   always@(*) begin : Match_Rdy_Logic
      //integer i;
      // Match CDB_TAG vs RS/RT TAG logic
      for(i = 0; i<N_QUEUE; i = i+1) begin
         queue_rt_match[i] = (CDB_Valid) ?  (CDB_Tag == rt_tag_reg[i]) : 1'b0;
         queue_rs_match[i] = (CDB_Valid) ?  (CDB_Tag == rs_tag_reg[i]) : 1'b0;
      end
     
      for(i = 0; i<N_QUEUE; i = i+1) begin
         queue_ready[i] =(RB_Store_Ready | opcode_reg[i]) & rs_val_reg[i] & (rt_val_reg[i] | opcode_reg[i]); // & valid_reg[i]; Not valid logic here
      end
            
   end
   
   // Add, Shift and Valid logic
   always@(*) begin
     
      queue_add      = (Dispatch_Enable) & ( ~(valid_reg[0]&valid_reg[1]&valid_reg[2]&valid_reg[3]) | (Issueblk_Issue & (queue_issue[0]|queue_issue[1]|queue_issue[2]|queue_issue[3]))  );
      queue_shift[1] = (valid_reg[1]) & (~(Issueblk_Issue & queue_issue[1])) & ( ~(valid_reg[0]                          ) | (Issueblk_Issue &  queue_issue[0]                               ) );
      queue_shift[2] = (valid_reg[2]) & (~(Issueblk_Issue & queue_issue[2])) & ( ~(valid_reg[0]&valid_reg[1]             ) | (Issueblk_Issue & (queue_issue[0]|queue_issue[1]               )) );
      queue_shift[3] = (valid_reg[3]) & (~(Issueblk_Issue & queue_issue[3])) & ( ~(valid_reg[0]&valid_reg[1]&valid_reg[2]) | (Issueblk_Issue & (queue_issue[0]|queue_issue[1]|queue_issue[2])) );   
   
      valid_logic[0] = (RB_Flush_Valid) ? 1'b0 : ( queue_shift[1] | (valid_reg[0] & (~(Issueblk_Issue & queue_issue[0]))      ) );
      valid_logic[1] = (RB_Flush_Valid) ? 1'b0 : ( queue_shift[2] | (valid_reg[1] & (~(Issueblk_Issue & queue_issue[1])) & (~queue_shift[1])) );
      valid_logic[2] = (RB_Flush_Valid) ? 1'b0 : ( queue_shift[3] | (valid_reg[2] & (~(Issueblk_Issue & queue_issue[2])) & (~queue_shift[2])) );
      valid_logic[3] = (RB_Flush_Valid) ? 1'b0 : ( queue_add      | (valid_reg[3] & (~(Issueblk_Issue & queue_issue[3])) & (~queue_shift[3])) );
           
   end

   //Output
   always@(*) begin

      // Default values for queue_issue
      for(i = 0; i<N_QUEUE; i = i+1) begin
         queue_issue[i] = 1'b0;
      end

      casex({queue_ready[3], valid_reg[3], queue_ready[2], valid_reg[2], queue_ready[1], valid_reg[1], queue_ready[0], valid_reg[0]})

         {2'bXX, 2'bXX, 2'bXX, 2'b11}: begin
            queue_issue[0]   = 1'b1; 
            IssueQue_Ready   = 1'b1;
            IssueQue_Opcode  = opcode_reg [0];           
            IssueQue_Data    = rt_data_reg[0];
            IssueQue_Address = address_reg[0];
            IssueQue_Rd_Tag  = rd_tag_reg [0];   
         end
         {2'bXX, 2'bXX, 2'b11, 2'b00}: begin
            queue_issue[1]   = 1'b1; 
            IssueQue_Ready   = 1'b1;
            IssueQue_Opcode  = opcode_reg [1];         
            IssueQue_Data    = rt_data_reg[1];
            IssueQue_Address = address_reg[1];
            IssueQue_Rd_Tag  = rd_tag_reg [1]; 
         end
         {2'bXX, 2'b11, 2'b00, 2'b00}: begin
            queue_issue[2]   = 1'b1;
            IssueQue_Ready   = 1'b1;
            IssueQue_Opcode  = opcode_reg [2];           
            IssueQue_Data    = rt_data_reg[2];
            IssueQue_Address = address_reg[2];
            IssueQue_Rd_Tag  = rd_tag_reg [2]; 
         end
         {2'b11, 2'b00, 2'b00, 2'b00}: begin
            queue_issue[3]   = 1'b1;
            IssueQue_Ready   = 1'b1;
            IssueQue_Opcode  = opcode_reg [3];           
            IssueQue_Data    = rt_data_reg[3];
            IssueQue_Address = address_reg[3];
            IssueQue_Rd_Tag  = rd_tag_reg [3];  
         end
         
         default: begin  // No necesario si se ponen default values al principio
            IssueQue_Ready   = 1'b0;
            IssueQue_Opcode  = opcode_reg [0];            
            IssueQue_Data    = rt_data_reg[0];
            IssueQue_Address = address_reg[0];
            IssueQue_Rd_Tag  = rd_tag_reg [0];        
         end  
        
      endcase
      
      IssueQue_Full = valid_reg[3] & valid_reg[2] & valid_reg[1] & valid_reg[0] & (~Issueblk_Issue);  
  
   end

   // Instruction Queues Sequential Logic
   always@(posedge Clk, posedge Rst) begin
   
      if(Rst) begin
         for(i = 0; i < N_QUEUE; i = i + 1) begin
            
            opcode_reg  [i] <= 1'b0;
            imm_reg     [i] <= 16'b0;
            address_reg [i] <= 32'h0;
            rd_tag_reg  [i] <= 5'b0;
            rs_tag_reg  [i] <= 5'b0;
            rs_data_reg [i] <= 32'h0;
            rs_val_reg  [i] <= 1'b0;
            rt_tag_reg  [i] <= 5'b0;
            rt_data_reg [i] <= 32'h0;
            rt_val_reg  [i] <= 1'b0;
            valid_reg   [i] <= 1'b0;
         end
      end
       
      else begin

         for(i = 0; i < N_QUEUE; i = i + 1) begin
            

            if(i == (N_QUEUE-1)) begin

               opcode_reg[i] <= (queue_add) ? Dispatch_Opcode : opcode_reg[i];
               imm_reg[i]    <= (queue_add) ? Dispatch_Imm    :    imm_reg[i];
               rd_tag_reg[i] <= (queue_add) ? Dispatch_Rd_Tag : rd_tag_reg[i];
               rs_tag_reg[i] <= (queue_add) ? Dispatch_Rs_Tag : rs_tag_reg[i];
               rt_tag_reg[i] <= (queue_add) ? Dispatch_Rt_Tag : rt_tag_reg[i];
               
               address_reg[i] <= (queue_rs_match[i]) ? (CDB_Data + {{16{imm_reg[i][15]}},imm_reg[i]}) : 
                                 (queue_add)  ?  (Dispatch_Rs_Data + {{16{Dispatch_Imm[15]}},Dispatch_Imm}) : address_reg[i]; 

               rs_data_reg[i] <= (queue_rs_match[i]) ? CDB_Data :  (queue_add)  ? Dispatch_Rs_Data     : rs_data_reg[i];
               rs_val_reg [i] <= (queue_rs_match[i]) ? 1'b1     :  (queue_add)  ? Dispatch_Rs_Data_Val : rs_val_reg [i];
               rt_data_reg[i] <= (queue_rt_match[i]) ? CDB_Data :  (queue_add)  ? Dispatch_Rt_Data     : rt_data_reg[i];
               rt_val_reg [i] <= (queue_rt_match[i]) ? 1'b1     :  (queue_add)  ? Dispatch_Rt_Data_Val : rt_val_reg [i];

               valid_reg [i] <=  valid_logic[i];

            end
            else begin

               opcode_reg[i] <= (queue_shift[i+1]) ? opcode_reg[i+1] : opcode_reg[i];
               imm_reg[i]    <= (queue_shift[i+1]) ? imm_reg[i+1]    :    imm_reg[i];
               rd_tag_reg[i] <= (queue_shift[i+1]) ? rd_tag_reg[i+1] : rd_tag_reg[i];
               rs_tag_reg[i] <= (queue_shift[i+1]) ? rs_tag_reg[i+1] : rs_tag_reg[i];
               rt_tag_reg[i] <= (queue_shift[i+1]) ? rt_tag_reg[i+1] : rt_tag_reg[i];
               
               address_reg[i] <= (queue_rs_match[i]) ? (CDB_Data + {{16{imm_reg[i][15]}},imm_reg[i]}) : (queue_shift[i+1])  ? address_reg[i+1] : address_reg[i];

               rs_data_reg[i] <= (queue_rs_match[i]) ? CDB_Data :  (queue_shift[i+1])  ? rs_data_reg[i+1] : rs_data_reg[i];
               rs_val_reg [i] <= (queue_rs_match[i]) ? 1'b1     :  (queue_shift[i+1])  ? rs_val_reg [i+1] : rs_val_reg [i];
               rt_data_reg[i] <= (queue_rt_match[i]) ? CDB_Data :  (queue_shift[i+1])  ? rt_data_reg[i+1] : rt_data_reg[i];
               rt_val_reg [i] <= (queue_rt_match[i]) ? 1'b1     :  (queue_shift[i+1])  ? rt_val_reg [i+1] : rt_val_reg [i];

               valid_reg [i] <=  valid_logic[i];

            end

         end
         
      end
     
  end
  
  

endmodule




