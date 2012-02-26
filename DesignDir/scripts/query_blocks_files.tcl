
proc showblockInfo {file_info DESIGN_DIR} {
	readfile $file_info $DESIGN_DIR

}

proc readfile {file_name DESIGN_DIR} {
   set f [open $file_name  r]
   set lineNumber 0
    while {[gets $f line] >= 0} {
    	incr lineNumber
	if {[string match "BLOCK_NAME*" $line ]} {
		set bl_name [string map { {BLOCK_NAME:} {} { } {}} $line]
	
		if {[file exist $DESIGN_DIR/blocks/$bl_name/tool_info/files]} {
			file delete $DESIGN_DIR/blocks/$bl_name/tool_info/files
		}
		
	        set ff [glob -nocomplain -directory $DESIGN_DIR/blocks/$bl_name/rtl_v "*.v"]
		set fp [open $DESIGN_DIR/blocks/$bl_name/tool_info/files w]
		puts "$DESIGN_DIR/blocks/$bl_name/tool_info/files"
		puts $fp $ff 
		puts $fp "$DESIGN_DIR/blocks/$bl_name/testbench/testbench.v"
		close $fp
	}
	if {[string match "SUB_LIST*" $line ]} {
		
#		puts "\t[join [string map { {SUB_LIST:} {}} $line] \n\t]"
			
		foreach bl $line {
		if {[file exist $DESIGN_DIR/blocks/$bl]} {
	        set ff [glob -nocomplain -directory $DESIGN_DIR/blocks/$bl/rtl_v "*.v"]
		set fp [open $DESIGN_DIR/blocks/$bl_name/tool_info/files a+]
		puts $fp $ff 
		close $fp
		} else {
			if {![string match "SUB_LIST*" $bl ]} {
			puts "WARN: subblock $bl does not exist"
			}
		}		
		}
	}
	
   }
   close $f
}
# Shows design blocks
set DesignDir $env(DESIGN_DIR)
#puts "-------------------------------------"
#puts "     BLOCK LIST :                    "
#puts [exec ls ${DesignDir}/blocks]

# Shows design blocks
set DIR [lindex $argv 0]
set SUBDIR ""
set TYPE "*.info"
set DesignDir $env(DESIGN_DIR)
set blocks [glob -nocomplain -directory ${DesignDir}/blocks $DIR]

#puts "-------------------------------------"
#puts "     BLOCK = $DIR : view = $SUBDIR type = $TYPE"
#puts "-------------------------------------"
foreach file_ ${blocks} {
	set f [glob -nocomplain -directory ${file_} $TYPE]
	if {$f != ""} {
		showblockInfo $f $DesignDir
	} else {
		if {$env(DEBUG) == "1"} {
		puts "WARN : file not found ${file_}/$TYPE"
		}
	}
}
#puts "\n-------------------------------------"

