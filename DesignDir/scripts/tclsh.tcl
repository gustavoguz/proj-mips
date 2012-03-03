 set fp [open "Instr.v" r]
 set file_data [read $fp]
 close $fp
 
set filename "test2.txt"
set filename2 "test3.txt"
set fileId [open $filename "w"]
set fileId2 [open $filename2 "w"]


 #  Process data file
 set data [split $file_data "\n"]
set flag 0
 foreach line $data {
        #if {[string match "Description*" $line] || [string match "Operation*" $line] || [string match "Syntax*" $line]} {
	#	set flag 1
	#} elseif {[string match "Encoding*" $line]} {
#		set flag 0
#	} elseif {$flag} {
#		set flag 0
#	} else {
#		puts $fileId $line
#	}	
	#puts -nonewline $fileId $data
	if {[string match "0*" $line] || [string match "1*" $line]} {
		puts $fileId $line
		
	} else {
		puts $fileId2 $line
	}
 }
 
close $fileId
close $fileId2
