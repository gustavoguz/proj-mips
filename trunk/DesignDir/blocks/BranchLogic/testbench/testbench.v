//Testbench: BranchLogic

`timescale 1ns / 100ps

module testbench;
reg 		is_jump;
reg	[32:0]	pc;
reg	[15:0]	immediate;
wire	[32:0]  Jmp_branch_address;

branchlogic branchlogic (
			.is_jump(is_jump),
			.pc(pc),
			.immediate(immediate),
			.Jmp_branch_address(Jmp_branch_address)
			);



initial begin
$monitor ("Is_Jump =%b, PC = %d, Immediate =%d, Jmp_branch_address =%d",is_jump,pc,immediate,Jmp_branch_address);

is_jump=1;
pc=0;
immediate =10;
#20
is_jump=1;
pc=4;
immediate =10;
#20
is_jump=0;
pc=4+pc;
immediate =10;
#20
is_jump=1;
pc=4+pc;
immediate =10;
#20
is_jump=0;
pc=4+pc;
immediate =10;
#20
is_jump=1;
pc=4+pc;
immediate =10;
#20
is_jump=0;
pc=4+pc;
immediate =10;

#20 $finish;
end

endmodule
