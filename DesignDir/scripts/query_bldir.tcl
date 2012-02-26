
# Shows design blocks
set DIR [lindex $argv 0]
set SUBDIR "/[lindex $argv 1]"
set DesignDir $env(DESIGN_DIR)
set blocks [glob -nocomplain -directory ${DesignDir}/blocks $DIR]
lappend blocks { }
puts "-------------------------------------\n"
puts "     BLOCK = $DIR : view = $SUBDIR "
puts [join $blocks $SUBDIR\n]
puts "-------------------------------------"
