set RUN_UNIT_TEST_IN_LIB_GYLIB 1


namespace eval gylib {
	variable NULL ""
	variable TRUE 1
	variable FALSE 0
} ; 
proc gylib::isProc {args} {
	variable NULL
	variable TRUE
	variable FALSE
	if { $NULL != [uplevel eval "info proc $args"] } {
		return $TRUE
    } else {
	    return $FALSE
    }
}

proc gylib::isNamespace { args } {
	return [uplevel eval "namespace exists $args"]
}
proc gylib::printLine { str "" } {
	if { [isNamespace "aetest"] } {
		aetest::action -info $str
    } else {
	    puts $str
    }    
}

proc gylib::printArray {args} {
	if { [isArray $args] } {

    }
}
proc gylib::isVariable {args} {
	return [uplevel eval "info exists $args"]
}
proc gylib::isArray {args} {
	return [uplevel eval "array exists $args"]
}

proc gylib::typeOf {args} {
	set typeList {}
	if { [uplevel eval "gylib::isProc $args"] } {
		lappend typeList proc
    } 
    if {[uplevel eval "gylib::isArray $args"]} {
	    lappend typeList array
    } 
    if { [uplevel eval "gylib::isNamespace $args"] } {
	    lappend typeList namespace
    } 
    if { [uplevel eval "gylib::isVariable $args"] } {
	    lappend typeList variable
    }
    if {[llength $typeList] == 0} {
	    lappend typeList unknown
    }
    return $typeList
}
proc gylib::assertEqual {arg1value arg2Value} {
	if { $arg1value != $arg2Value } {
		error "assert failed expected $arg1value but got $arg2Value" 
    } 
} 
proc stacktrace {args} {

	for {set i 1 ; set n [info level]} {$i<$n} {incr i} {
		set indent [string repeat " " $i]
		puts [format "%d:%s%s" $i $indent [info level $i]]
    }
}
proc unit_test {args} {

	puts "
    -------------------------
    start runing unit test
    -------------------------
	"
	set total 0
	set passed 0
	set failed 0
	set passedCase {}
	set failedCase {}

	foreach testProc $args {
		puts "
        --------
        runing unit_test $testProc
        --------"
		if { [catch "$testProc" err] } {
			puts "
        **********
        error found in $testProc
        testcase $testProc failed
        the message is $err
        **********"
			incr total
			incr failed
			lappend failedCase $testProc
        } else {
            puts "
        **********
        testcase $testProc passed
        **********
		    "
		    incr total
		    incr passed
		    lappend passedCase $testProc
        }
    }
    #end of foreach case
    ##end of runing unit_test

    puts "
    +++++++
    runing result
    +++++++

    ====
    summy
    ====
    total:$total
    passed:$passed
    failed:$failed

    "
    if { [llength $failedCase] != 0} {
        puts "
    ---
    failed Cases
    ---"
        foreach fail $failedCase {
            puts "      $fail"
        }
    }

}
if { $RUN_UNIT_TEST_IN_LIB_GYLIB } {
	proc testAssertEqualCase1 {} {
		set a b
		set c b
		gylib::assertEqual $a $c 
    }
    proc testAssertEqualCase2 {} {
	    set a a
	    set c b
	    if { ![catch "gylib::assertEqual $a $c" err] } {
		    error "assert failed"
        }
    }
    unit_test testAssertEqualCase1 testAssertEqualCase2
    info procs
}