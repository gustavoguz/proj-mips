//BUBBLE SORT & SELECTION SORT
//
//Preconditions on Register file
//  Registers set to their register number
//  ex) $0 = 0, $1 = 1, $2 = 2 ...... $31 = 31 
//Preconditions on Data Memory
//  None. Any data in the first 5 locations will be sorted by Bubble sort.
//  The next 5 data will be sorted by Selection sort.

mem [ 0] = 32'h00000020 ; //add $0, $0, $0     //nop *** INITIALIZATION FOR BUBBLE SORT ***
mem [ 1] = 33'h0080F820 ; //add $31, $4, $0    //$31 = 4 
mem [ 2] = 32'h00BF1019 ; //mul $2, $5, $31    //ak = 4 * num_of_items
mem [ 3] = 32'h00000020 ; //add $0, $0, $0     //noop
//
mem [ 4] = 32'h00001820 ; //add $3, $0, $0     //ai = 0 *** BUBBLE SORT STARTS ***
mem [ 5] = 32'h007F2020 ; //add $4, $3, $31    //aj = ai + 4
mem [ 6] = 32'h0082302A ; //slt $6, $4, $2     //(aj < ak) ?
mem [ 7] = 32'h10C0000C ; //beq $6, $0, 12     //if no, program finishes. goto chcker
//
mem [ 8] = 32'h8C6D0000 ; // lw  $13, 0($3)     //mi = M(ai)       (LABEL: LOAD)
mem [ 9] = 32'h8C8E0000 ; // lw  $14, 0($4)     //mj = M(aj)
mem [10] = 32'h01CD302A ; // slt $6, $14, $13   //(mj < mi) ?
mem [11] = 32'h10C00002 ; // beq $6, $0, 2      //if no, skip swap
//
mem [12] = 32'hAC6E0000 ; // sw  $14, 0($3)     //M(ai) = mj // swap
mem [13] = 32'hAC8D0000 ; // sw  $13, 0($4)     //M(aj) = mi // swap
mem [14] = 32'h007F1820 ; //add $3, $3, $31    //ai = ai + 4      (LABEL: SKIP SWAP)
mem [15] = 32'h009F2020 ; //add $4, $4, $31    //aj = aj + 4
//
mem [16] = 32'h0082302A ; // slt $6, $4, $2     //(aj < ak) ?
mem [17] = 33'h10C1FFF6 ; // beq $6, $1, -10    //if yes, goto LOAD
mem [18] = 32'h005F1022 ; // sub $2, $2, $31    //ak = ak - 4
mem [19] = 32'h08000004 ; // jmp 4              //goto BEGIN
//
mem [20] = 32'h00000020 ; //add $0,  $0,  $0    //nop *** CHECKER FOR FIRST 5 ITEMS *** 
mem [21] = 32'h0000D020 ; //add $26, $0,  $0    //addr1 = 0
mem [22] = 32'h035FD820 ; //add $27, $26, $31   //addr2 = addr1 + 4
mem [23] = 32'h00BFE019 ; // mul $28, $5, $31    //addr3 = num_of_items * 4
//
mem [24] = 32'h039AE020 ; //add $28, $28, $26   //addr3 = addr3 + addr1
mem [25] = 32'h8F5D0000 ; // lw  $29, 0 ($26)    //maddr1 = M(addr1)
mem [26] = 32'h8F7E0000 ; // lw  $30, 0 ($27)    //maddr2 = M(addr2)
mem [27] = 32'h03DDC82A ; // slt $25, $30, $29   //(maddr2 < maddr1) ?
//
mem [28] = 32'h13200001 ; // beq $25, $0,  1     //if no, proceed to the next data
mem [29] = 32'h1000FFFF ; // beq $0,  $0, -1     //else, You're stuck here
mem [30] = 32'h035FD020 ; //add $26, $26, $31   //addr1 = addr1 + 4
mem [31] = 32'h037FD820 ; //add $27, $27, $31   //addr2 = addr2 + 4
//
mem [32] = 32'h137C0001 ; // beq $27, $28, 1     //if all tested, proceed to the next program
mem [33] = 32'h1000FFF7 ; // beq $0,  $0, -9     //else test next data 
mem [34] = 32'h00000020 ; //add $0, $0, $0      //noop
mem [35] = 32'h00000020 ; //add $0, $0, $0      //noop
//
mem [36] = 32'h00000020 ; //add $0, $0, $0    //nop *** INITIALIZATION FOR SELECTION SORT ***
mem [37] = 32'h00A01020 ; //add $2, $5, $0    //set min = 5
mem [38] = 32'h00BF4820 ; //add $9, $5, $31   //$9  = 9 
mem [39] = 32'h01215020 ; //add $10, $9, $1   //$10 = 10
//
mem [40] = 32'h00003020 ; //add $6, $0, $0    //slt_result = 0
mem [41] = 32'h00A01820 ; //add $3, $5, $0    //i = 5
mem [42] = 32'h00612020 ; //add $4, $3, $1    //j = i+1   *** SELECTION SORT STARTS HERE ***
mem [43] = 32'h007F6819 ; // mul $13, $3, $31  //ai = i*4   
//
mem [44] = 32'h8DB70000 ; // lw  $23, 0($13)   //mi = M(ai)
mem [45] = 32'h01A06020 ; //add $12, $13, $0  //amin = ai
mem [46] = 32'h02E0B020 ; //add $22, $23, $0  //mmin = mi
mem [47] = 32'h009F7019 ; // mul $14, $4, $31  //aj  = j*4
//
mem [48] = 32'h8DD80000 ; // lw  $24, 0($14)   //mj = M(aj)
mem [49] = 32'h0316302A ; // slt $6, $24, $22  //(mj < mmin)
mem [50] = 32'h10C00002 ; // beq $6, $0, 2     //if(no)
mem [51] = 32'h01C06020 ; //add $12, $14, $0  //amin = aj
//
mem [52] = 32'h0300B020 ; //add $22, $24, $0  //mmin = mj
mem [53] = 32'h00812020 ; //add $4, $4, $1    //j++
mem [54] = 32'h108A0001 ; // beq $4, $10, 1    //(j = 10)
mem [55] = 32'h1000FFF7 ; // beq $0, $0, -9    //if(no)
//
mem [56] = 32'h00000020 ; //add $0, $0, $0    //nop
mem [57] = 32'hADB60001 ; // sw  $22, 0 ($13)  //M(ai) = mmin // swap
mem [58] = 32'hAD970001 ; // sw  $23, 0 ($12)  //M(amin) = mi // swap
mem [59] = 32'h00611820 ; //add $3, $3, $1    //i++
//
mem [60] = 32'h00612020 ; //add $4, $3, $1    //j = i+1
mem [61] = 32'h10690001 ; // beq $3, $9, 1     //(i==9)
mem [62] = 32'h1000FFEC ; // beq $0, $0, -20   //if(no)
mem [63] = 32'h00000020 ; //add $0,  $0,  $0  //nop 
//
mem [64] = 32'h00000020 ; //add $0,  $0,  $0    //*** CHECKER FOR THE NEXT 5 ITEMS *** 
mem [65] = 32'h00BFD019 ; // mul $26, $5,  $31   //addr1 = num_of_items * 4
mem [66] = 32'h035FD820 ; //add $27, $26, $31   //addr2 = addr1 + 4
mem [67] = 32'h00BFE019 ; // mul $28, $5, $31    //addr3 = num_of_items * 4
//
mem [68] = 32'h039AE020 ; //add $28, $28, $26   //addr3 = addr3 + addr1
mem [69] = 32'h8F5D0000 ; // lw  $29, 0 ($26)    //maddr1 = M(addr1)
mem [70] = 32'h8F7E0000 ; // lw  $30, 0 ($27)    //maddr2 = M(addr2)
mem [71] = 32'h03BEC82A ; // slt $25, $29, $30   //(maddr1 < maddr2) ?
//
mem [72] = 32'h13390001 ; // beq $25, $25, 1     //if yes, proceed to the next data
mem [73] = 32'h1000FFFF ; // beq $0,  $0, -1     //else, You're stuck here
mem [74] = 32'h035FD020 ; //add $26, $26, $31   //addr1 = addr1 + 4
mem [75] = 32'h037FD820 ; //add $27, $27, $31   //addr2 = addr2 + 4
//
mem [76] = 32'h137C0001 ; // beq $27, $28, 1     //if all tested, proceed to the next program
mem [77] = 32'h1000FFF7 ; // beq $0,  $0, -9     //else test next data 
mem [78] = 32'h00000020 ; //add $0, $0, $0      //noop
mem [79] = 32'h00000020 ; //add $0, $0, $0      //noop
mem [80] = 32'h00000020 ; //add $0, $0, $0      //noop
/*
//
//
--REG FILE USED BY BUBBLE SORT
--Initilaly, the content of a register is assumed to be same as its register number.
//
--$0   ----> 0        constant
--$1   ----> 1        constant
--$2   ----> ak       address of k  
--$3   ----> ai       address of i
--$4   ----> aj       address of j
--$5   ----> 5        num_of_items (items at location 0~4 will be sorted)
--$6   ----> result_of_slt 
--$13  ----> mi       M(ai)
--$14  ----> mj       M(aj)
--$25~$30 -> RESERVED for the checker
--$31  ----> 4        conatant for calculating word address
//
--REG FILE USED BY SELECTION SORT
//
--$0   ----> 0       constant
--$1   ----> 1       constant
--$2   ----> min     index of the minimum value
--$3   ----> i       index i
--$4   ----> j       index j
--$5   ----> 5       num_of_items (items at location 5~9 will be sorted)     
--$6   ----> result of slt
--$9   ----> 9       constant
--$10  ----> 10      constant
--$12  ----> amin    address of min
--$13  ----> ai      address of i 
--$14  ----> aj      address of j 
--$15~$21 -> don't care
--$22  ----> mmin    M(amin)
--$23  ----> mi      M(ai)
--$24  ----> mj      M(aj)
--$25~$30 -> RESERVED for checker
--$31  ----> 4       for calculating word address 
//   
--REG FILE USED BY CHECKER
//
--$26  ----> addr1    starting point  
--$27  ----> addr2    ending point
--$28  ----> addr3    bound
--$29  ----> maddr1   M(addr1)
--$30  ----> maddr2   M(addr2)
*/
