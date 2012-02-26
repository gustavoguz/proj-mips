if {![file exist my_program]} {
	set fp [open my_program.v w]
	for {set i 0} {$i<128} {incr i} {
		puts $fp "mem \[$i\] = $i;"
	}
	close $fp

}

