/****************************************************************************************************/
// Title      : Issue Unit Verilog File
// File       : IssueUnit.v
/****************************************************************************************************/ 
// Author                : Alejandro Guerena
// E-Mail                : md679705@iteso.mx
// Date of last revision : Mar-2012 3:30am
// Notes                 : 
//
/****************************************************************************************************/  

module IssueUnit(

// Port Declarations
   input                Clk,
   input                Rst,
   // Interface with Queues (Ready/Issue Signals)
   input                Ready_Int0,
   input                Ready_Int1,
   input                Ready_Mult,
   input                Ready_LS,
   output reg           Issue_Int0,
   output reg           Issue_Int1,
   output reg           Issue_Mult,
   output reg           Issue_LS,
   // Interface with CDB
   output      [ 4:0]   CDB_Tag,
   output      [31:0]   CDB_Data,
   output               CDB_Valid,
   output               CDB_Branch,
   output               CDB_Branch_Taken,
   // Interface with Integer Issue Unit 0
   input       [ 4:0]   IntIssue0_Tag,
   input       [31:0]   IntIssue0_Result,
   input                IntIssue0_ALU_Branch,
   input                IntIssue0_ALU_Branch_Taken,
   // Interface with Integer Issue Unit 1
   input       [ 4:0]   IntIssue1_Tag,
   input       [31:0]   IntIssue1_Result,
   input                IntIssue1_ALU_Branch,
   input                IntIssue1_ALU_Branch_Taken,
    // Interface with LS Issue Unit
   input       [ 4:0]   LSIssue_Tag,
   input       [31:0]   LSIssue_Result,
   // Interface with Mult Issue Unit
   input       [ 4:0]   MultIssue_Tag,
   input       [31:0]   MultIssue_Result   

);


   // CDB Registers
   reg  [ 4:0]   CDB_Tag_reg;
   reg  [31:0]   CDB_Data_reg;
   reg           CDB_Valid_reg;
   reg           CDB_Branch_reg;
   reg           CDB_Branch_Taken_reg;

   // Internal Signals 
   wire       mult_done;
   reg [ 1:0] LRU_logic;
   
   // Issue Unit Registers
   reg [ 1:0] LRU_reg;
   reg [ 3:0] CDB_Slot_reg;
   
   // Mult Tag Registers
   reg [ 4:0] mult_tag_reg [0:2];
   
   // CDB Slot Sequential Logic
   always@(posedge Clk, posedge Rst) begin
   
      if(Rst) begin
         CDB_Slot_reg <= 4'b0000;
      end
      
      else begin      
         CDB_Slot_reg[3] <= Ready_Mult;  
         CDB_Slot_reg[2] <= CDB_Slot_reg[3];
         CDB_Slot_reg[1] <= CDB_Slot_reg[2];
         CDB_Slot_reg[0] <= CDB_Slot_reg[1] | Ready_Int0 | Ready_Int1 | Ready_LS; // Necesario?
      end
    
   end
   
   // LRU Sequential Logic
   always@(posedge Clk, posedge Rst) begin
   
      if(Rst) begin
         LRU_reg <= 2'b10;
      end    
      else begin
         LRU_reg <= LRU_logic;        
      end         
        
   end
   
   
    // Mult_Done logic
   assign mult_done = CDB_Slot_reg[1];
   
   // Mult_Tag Sequential Shift
   always@(posedge Clk, posedge Rst) begin
   
      if(Rst) begin
         mult_tag_reg [0] <= 5'b00000;  
         mult_tag_reg [1] <= 5'b00000;  
         mult_tag_reg [2] <= 5'b00000;   
      end 
      else begin
         mult_tag_reg [0] <= MultIssue_Tag;  
         mult_tag_reg [1] <= mult_tag_reg [0];  
         mult_tag_reg [2] <= mult_tag_reg [1]; 
      end  
     
   end
   
   // Issue Outputs to Queues Logic
   always@(*) begin 
   
      // Default values for Issue signals
      Issue_Int0 = 1'b0;
      Issue_Int1 = 1'b0;
      Issue_LS   = 1'b0;      
      Issue_Mult = Ready_Mult;
      LRU_logic  = LRU_reg;
      
      casex ({mult_done,LRU_reg})
         /*******************************************/
         /*{1'b1, 2'bXX, 1'bX}: begin
         
            Issue_Int0 = 1'b0;
            Issue_Int1 = 1'b0;
            Issue_LS   = 1'b0;      
            Issue_Mult = Ready_Mult;
            LRU_logic  = LRU_reg;       
           
         end*/
         /*******************************************/ 
         {1'b0, 2'b00}: begin
            /*if(Ready_LS == 1'b1) begin       
               Issue_LS   = 1'b1;
               LRU_logic  = 2'b10;
            end
            else if(Ready_Int1 == 1'b1) begin
               Issue_Int1 = 1'b1;
               LRU_logic  = 2'b01;
            end
            else if(Ready_Int0 == 1'b1) begin
               Issue_Int0 = 1'b1;
               LRU_logic  = 2'b00;
            end
            else LRU_logic  = LRU_reg;*/
            casex({Ready_LS, Ready_Int1, Ready_Int0})
            
               {1'b1,1'bX,1'bX}: begin
                  Issue_LS   = 1'b1;
                  LRU_logic  = 2'b10;   
               end
               {1'b0,1'b1,1'bX}: begin
                  Issue_Int1 = 1'b1;
                  LRU_logic  = 2'b01;   
               end 
               {1'b0,1'b0,1'b1}: begin
                  Issue_Int0 = 1'b1;
                  LRU_logic  = 2'b00;   
               end   
              
            endcase           
         end 
         /*******************************************/ 
         {1'b0, 2'b01}: begin       
            /*if(Ready_LS == 1'b1) begin       
               Issue_LS   = 1'b1;
               LRU_logic  = 2'b11;
            end
            else if(Ready_Int0 == 1'b1) begin
               Issue_Int0 = 1'b1;
               LRU_logic  = 2'b00;
            end
            else if(Ready_Int1 == 1'b1) begin
               Issue_Int1 = 1'b1;
               LRU_logic  = 2'b01;
            end
            else LRU_logic  = LRU_reg;*/
            casex({Ready_LS, Ready_Int0, Ready_Int1})
            
               {1'b1,1'bX,1'bX}: begin
                  Issue_LS   = 1'b1;
                  LRU_logic  = 2'b11;   
               end
               {1'b0,1'b1,1'bX}: begin
                  Issue_Int0 = 1'b1;
                  LRU_logic  = 2'b00;   
               end 
               {1'b0,1'b0,1'b1}: begin
                  Issue_Int1 = 1'b1;
                  LRU_logic  = 2'b01;   
               end   
              
            endcase       
         end
         /*******************************************/
         {1'b0, 2'b10}: begin       
            /*if(Ready_Int1 == 1'b1) begin       
               Issue_Int1 = 1'b1;
               LRU_logic  = 2'b01;
            end
            else if(Ready_Int0 == 1'b1) begin
               Issue_Int0 = 1'b1;
               LRU_logic  = 2'b00;
            end
            else if(Ready_LS == 1'b1) begin
               Issue_LS   = 1'b1;
               LRU_logic  = 2'b10;
            end
            else LRU_logic  = LRU_reg;*/
            casex({Ready_Int1, Ready_Int0, Ready_LS})
            
               {1'b1,1'bX,1'bX}: begin
                  Issue_Int1 = 1'b1;
                  LRU_logic  = 2'b01;   
               end
               {1'b0,1'b1,1'bX}: begin
                  Issue_Int0 = 1'b1;
                  LRU_logic  = 2'b00;   
               end 
               {1'b0,1'b0,1'b1}: begin
                  Issue_LS   = 1'b1;
                  LRU_logic  = 2'b10;   
               end   
              
            endcase
                    
         end
         /*******************************************/
         {1'b0, 2'b11}: begin       
            /*if(Ready_Int0 == 1'b1) begin       
               Issue_Int0 = 1'b1;
               LRU_logic  = 2'b00;
            end
            else if(Ready_Int1 == 1'b1) begin
               Issue_Int1 = 1'b1;
               LRU_logic  = 2'b01;
            end
            else if(Ready_LS == 1'b1) begin
               Issue_LS   = 1'b1;
               LRU_logic  = 2'b11;
            end
            else LRU_logic  = LRU_reg;*/
            casex({Ready_Int0, Ready_Int1, Ready_LS})
            
               {1'b1,1'bX,1'bX}: begin
                  Issue_Int0   = 1'b1;
                  LRU_logic  = 2'b00;   
               end
               {1'b0,1'b1,1'bX}: begin
                  Issue_Int1 = 1'b1;
                  LRU_logic  = 2'b01;   
               end 
               {1'b0,1'b0,1'b1}: begin
                  Issue_LS   = 1'b1;
                  LRU_logic  = 2'b11;   
               end   
              
            endcase    
         end
         /*******************************************/
         default begin       
            LRU_logic  = LRU_reg;        
         end
      
      endcase
              
   end
   
   // Outputs to CDB
   assign CDB_Tag          = CDB_Tag_reg;
   assign CDB_Data         = CDB_Data_reg;
   assign CDB_Valid        = CDB_Valid_reg;
   assign CDB_Branch       = CDB_Branch_reg;
   assign CDB_Branch_Taken = CDB_Branch_Taken_reg;
  
   
   // Outputs to CDB
   always@(posedge Clk, posedge Rst) begin
     
      if (Rst) begin
         CDB_Tag_reg          <= 5'b00000;
         CDB_Data_reg         <= 32'h00000000;
         CDB_Valid_reg        <= 1'b0;
         CDB_Branch_reg       <= 1'b0;
         CDB_Branch_Taken_reg <= 1'b0;   
        
      end
      
      else begin
        $display("MULT %0b, LS %0b, INT1 %0b, INT0 %0b at %0t", mult_done,Issue_LS,Issue_Int1,Issue_Int0,  $time);
        case({mult_done,Issue_LS,Issue_Int1,Issue_Int0})
      
      
         4'b0100: begin
            $display("INT_LS %0b at %0t", Issue_LS, $time);
            CDB_Tag_reg          <= LSIssue_Tag;
            CDB_Data_reg         <= LSIssue_Result;
            CDB_Valid_reg        <= 1'b1;
            CDB_Branch_reg       <= 1'b0;
            CDB_Branch_Taken_reg <= 1'b0;
         end
         4'b0001: begin
            $display("INT_ISSUE0 %0b at %0t", Issue_Int0, $time);
            CDB_Tag_reg          <= IntIssue0_Tag;
            CDB_Data_reg         <= IntIssue0_Result;
            CDB_Valid_reg        <= 1'b1;
            CDB_Branch_reg       <= IntIssue0_ALU_Branch;
            CDB_Branch_Taken_reg <= IntIssue0_ALU_Branch_Taken;     
         end
         4'b0010: begin
            $display("INT_ISSUE1 %0b at %0t", Issue_Int1, $time);
            CDB_Tag_reg          <= IntIssue1_Tag;
            CDB_Data_reg         <= IntIssue1_Result;
            CDB_Valid_reg        <= 1'b1;
            CDB_Branch_reg       <= IntIssue1_ALU_Branch;
            CDB_Branch_Taken_reg <= IntIssue1_ALU_Branch_Taken;
         end
         
         4'b1000: begin
            $display("INT_MULT %0b at %0t", Issue_Mult, $time);
            CDB_Tag_reg          <= mult_tag_reg [2];
            CDB_Data_reg         <= MultIssue_Result;
            CDB_Valid_reg        <= 1'b1;
            CDB_Branch_reg       <= 1'b0;
            CDB_Branch_Taken_reg <= 1'b0;   
         end
         default: begin
            CDB_Tag_reg          <= 5'b00000;
            CDB_Data_reg         <= 32'h00000000;
            CDB_Valid_reg        <= 1'b0;
            CDB_Branch_reg       <= 1'b0;
            CDB_Branch_Taken_reg <= 1'b0;  
         end  
        
        endcase
      end
      
   end
    

endmodule

      /*if(Rst) begin
         Issue_Int0 = 1'b0;
         Issue_Int1 = 1'b0;
         Issue_Mult = 1'b0;
         Issue_LS   = 1'b0;   
      end
      
      else begin*/
        
        /*if( mult_done == 1'b1 ) begin
         Issue_Mult = 1'b1;
         LRU_logic  = LRU_reg;   
      end
    
      else begin
      
             
         Issue_Int0 = 1'b1;
         LRU_logic  = LRU_reg; 
         
         
         Issue_Int1 = 1'b1;
         LRU_logic  = 2'b01;
         
         Issue_LS   = 1'b1;
         LRU_logic  = 2'b10;*/
        
