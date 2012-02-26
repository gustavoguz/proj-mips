
proc showblockInfo { file_info} {
	readfile $file_info
}

proc readfile {filename} {
   set f [open $filename]
   set lineNumber 0
    while {[gets $f line] >= 0} {
    	incr lineNumber
	if {[string match "BLOCK_NAME*" $line ]} {
		puts [string map { {BLOCK_NAME:} {}} $line]
	}
	if {[string match "SUB_LIST*" $line ]} {
		
		puts "\t[join [string map { {SUB_LIST:} {}} $line] \n\t]"
	}
	
   }
   close $f
}
# Shows design blocks
set DesignDir $env(DESIGN_DIR)
puts "-------------------------------------"
puts "     BLOCK LIST :                    "
puts [exec ls ${DesignDir}/blocks]

# Shows design blocks
set DIR [lindex $argv 0]
set SUBDIR ""
set TYPE "*.info"
set DesignDir $env(DESIGN_DIR)
set blocks [glob -nocomplain -directory ${DesignDir}/blocks $DIR]

puts "-------------------------------------"
puts "     BLOCK = $DIR : view = $SUBDIR type = $TYPE"
puts "-------------------------------------"
foreach file_ ${blocks} {
	set f [glob -nocomplain -directory ${file_} $TYPE]
	if {$f != ""} {
		showblockInfo $f
	} else {
		if {$env(DEBUG) == "1"} {
		puts "WARN : file not found ${file_}/$TYPE"
		}
	}
}
puts "\n-------------------------------------"

