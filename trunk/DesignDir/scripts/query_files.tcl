
# Shows design blocks
set DIR [lindex $argv 0]
set SUBDIR "/[lindex $argv 1]"
set TYPE [lindex $argv 2]
set DesignDir $env(DESIGN_DIR)
set blocks [glob -nocomplain -directory ${DesignDir}/blocks $DIR]

puts "-------------------------------------\n"
puts "     BLOCK = $DIR : view = $SUBDIR type = $TYPE"
foreach file_ ${blocks} {
	set f [glob -nocomplain -directory ${file_}${SUBDIR} $TYPE]
	if {$f != ""} {
		puts $f
	} else {
		if {$env(DEBUG) == "1"} {
		puts "WARN : file not found ${file_}${SUBDIR}/$TYPE"
		}
	}
}
puts "\n-------------------------------------"
