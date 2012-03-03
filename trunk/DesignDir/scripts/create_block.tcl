
# Shows design blocks
set BLOCK_NAME 	[lindex $argv 0]
set SUB_LIST 	[lindex $argv 1]

set DesignDir $env(DESIGN_DIR)


puts "-------------------------------------"
puts "INFO: mkdir = $DesignDir/blocks/$BLOCK_NAME"
file mkdir $DesignDir/blocks/$BLOCK_NAME

puts "INFO: mkdir = $DesignDir/blocks/$BLOCK_NAME/rtl_v"
file mkdir $DesignDir/blocks/$BLOCK_NAME/rtl_v

puts "INFO: mkdir = $DesignDir/blocks/$BLOCK_NAME/testbench"
file mkdir $DesignDir/blocks/$BLOCK_NAME/testbench

puts "INFO: mkdir = $DesignDir/blocks/$BLOCK_NAME/tool_info"
file mkdir $DesignDir/blocks/$BLOCK_NAME/tool_info

puts "INFO: mkfile = $DesignDir/blocks/$BLOCK_NAME/block.info"
if {![file exist  $DesignDir/blocks/$BLOCK_NAME/block.info]} {
	set fp [open $DesignDir/blocks/$BLOCK_NAME/block.info w]
	puts $fp "BLOCK_NAME: $BLOCK_NAME"
	puts $fp "SUB_LIST: $SUB_LIST"
	close $fp
}
if {![file exist  $DesignDir/blocks/$BLOCK_NAME/testbench/testbench.v]} {
	puts "INFO: mkfile = $DesignDir/blocks/$BLOCK_NAME/testbench/testbench.v"
	set fp [open $DesignDir/blocks/$BLOCK_NAME/testbench/testbench.v w]
	puts $fp "//Testbench: $BLOCK_NAME"
	puts $fp "\n`timescale 1ns / 100ps"
	puts $fp "\nmodule testbench;\n"
	puts $fp "\nendmodule"
	close $fp
}

puts "INFO: mkfile = $DesignDir/blocks/$BLOCK_NAME/tool_info/files"
set fp [open $DesignDir/blocks/$BLOCK_NAME/tool_info/files w]
	set f [glob -nocomplain -directory  $DesignDir/blocks/$BLOCK_NAME/rtl_v "*.v" ]
	if {$f != ""} {
		puts $fp "$f"
	}
	set f [glob -nocomplain -directory  $DesignDir/blocks/$BLOCK_NAME/testbench "*.v" ]
	if {$f != ""} {
		puts $fp "$f"
	}
close $fp
puts "INFO: mkfile = $DesignDir/blocks/$BLOCK_NAME/tool_info/runall.sh"
set fp [open $DesignDir/blocks/$BLOCK_NAME/tool_info/runall.sh w]

puts $fp "cd $DesignDir/blocks/$BLOCK_NAME/tool_info/"
puts $fp "vlib.exe work"
puts  $fp "vlog.exe -f $DesignDir/blocks/$BLOCK_NAME/tool_info/files"
puts $fp "vsim.exe testbench -do do.tcl"
close $fp

puts "INFO: mkfile = $DesignDir/blocks/$BLOCK_NAME/tool_info/do.tcl"
set fp [open $DesignDir/blocks/$BLOCK_NAME/tool_info/do.tcl w]
puts $fp "add wave -position anchor sim:/testbench/*"
puts $fp "\nrun -all"
close $fp

puts "-------------------------------------"
