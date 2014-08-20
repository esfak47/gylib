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
proc gylib::printLine { str } {
    
    foreach string $str {
        if { [isNamespace "aetest"] } {
            aetest::action -info $string
        } else {
            puts $string
        }   
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
proc __assertEqual {arg1value arg2Value args} {
    if { $arg1value != $arg2Value } {
        if { ![info exists args] || [llength $args] != 1 } {        
            error "assert failed expected $arg1value but got $arg2Value" 
        } else {
            set err_msg [lindex $args 0]
            error err_msg
        }
    } 
}
proc __assertNotEqual {arg1value arg2Value args} {
    if { $arg1value == $arg2Value } {
        if { ![info exists args] || [llength args] != 1 } {        
            error "assert failed expected not $arg1value but got $arg2Value" 
        } else {
            set err_msg [lindex $arg 0]
            error err_msg
        }
    } 
}
proc __assertTrue {args} {
    foreach arg $args {
        __assertEqual 1 $arg
    }
}
proc __assertFalse {args} {
    foreach arg $args {
        __assertEqual 0 $arg
    }
} 
proc __stacktrace {args} {
	for {set i 1 ; set n [info level]} {$i<$n} {incr i} {
		set indent [string repeat " " $i]
		puts [format "%d:%s%s" $i $indent [info level $i]]
    }
}
proc __map {list procName} {
    set ret {}
    foreach item $list {
        set item [uplevel eval "$procName $item"]
        lappend ret $item
    }
    return $ret    
}
proc __filter {list procName} {
    set ret {}
    foreach item $list {
        if { [uplevel eval "$procName $item"]} {        
            lappend ret $item
           }
    }
    return $ret
}
proc __reduce {itemList procName args} {
    if { [info exists args] && [llength $args] == 1 } {
       set ret [lindex $args 0]
    } else {
        set ret [lindex $itemList 0]
    }
    foreach item $itemList {
        set ret [uplevel eval "$procName $ret $item"]
    }
    return $ret
}
proc unit_test {args} {

	puts "start running unit test"
	set total 0
	set passed 0
	set failed 0
	set passedCase {}
	set failedCase {}

	foreach testProcs $args {
        foreach testProc $testProcs {
            puts "running unit_test $testProc"
            if { [catch "$testProc" err] } {
                puts "test case $testProc failed,the message is $err"
                incr total
                incr failed
                lappend failedCase $testProc
            } else {
                puts "test case $testProc passed"
                incr total
                incr passed
                lappend passedCase $testProc
            }
        }
    }
    #end of foreach case
    ##end of running unit_test
    puts "summary  total:$total passed:$passed failed:$failed"
    if { [llength $failedCase] != 0} {
        puts "
------------
failed Cases
------------"
        foreach fail $failedCase {
            puts "$fail"
        }
    }

}
if { $RUN_UNIT_TEST_IN_LIB_GYLIB } {
	proc u_testAssertEqualCase1 {} {
		set a b
		set c b
		__assertEqual $a $c 
    }
    proc u_testAssertEqualCase2 {} {
	    set a a
	    set c b
	    if { ![catch "__assertEqual $a $c" err] } {
		    error "assert failed"
        }
    }
    proc u_testAssertTrue1 {} {
        __assertTrue 1
    }
    proc u_testAssertTrue2 {} {
	    if { ![catch "__assertTrue 0" err] } {
		    error "assert failed"
        }
    }
    proc u_testMap {} {
        set list {1 2 3}
        proc double {arg} {
            return [expr $arg *2]
        }
        set list [__map $list double]
        __assertEqual 2 [lindex $list 0]
        __assertEqual 4 [lindex $list 1]
        __assertEqual 6 [lindex $list 2]
        __assertEqual 3 [llength $list]
    }
    proc u_testFilter {} {
        set list {1 2 3}
        proc compare {arg} {
            if { $arg > 2} {
                return 1
            } else {
                return 0
            }
        }
        set list [__filter $list compare]
        __assertEqual 3 [lindex $list 0]
        __assertEqual 1 [llength $list]
    }
    proc u_testIsProc1 {} {
        proc xx {} {
        }
        __assertTrue [gylib::isProc xx]
        
    }
    proc u_testIsProc2 {} {
        __assertFalse [gylib::isProc xxasdsadad]
    }
    proc u_testIsProc3 {} {
        set xx a
        proc xx {} {
        }
        __assertTrue [gylib::isProc xx]
    }
    proc u_testIsArray1 {} {
        set xx(1) a
        set xx(2) a
        __assertTrue [gylib::isArray xx]
    }
    proc u_testIsArray2 {} {
        set xxx {1 2 3}
        __assertFalse [gylib::isArray xxx]
    }
    proc u_testReduce {} {
        proc sum {x y} {
            return [expr $x+$y]
        }
        set list {1 2 3 4}
        __assertEqual 10 [__reduce $list sum 0]
    }
    proc u_testReduce2 {} {
        proc min {x y} {
            if { $x> $y} {
                return $y
            } else {
                return $x
            }
        }
        set list {1 2 3 4}
        __assertEqual 1 [__reduce $list min]
    }
    proc u_testTypeOf {} {
        set a_variable a
        set a_array(1) a
        proc a_proc {} {
        }
        __assertNotEqual -1  [ lsearch [gylib::typeOf a_variable] "variable" ]
        __assertNotEqual -1  [ lsearch [gylib::typeOf a_array] "array" ]
        __assertNotEqual -1  [ lsearch [gylib::typeOf a_proc] "proc" ]
        __assertNotEqual -1  [ lsearch [gylib::typeOf gylib] "namespace" ]
        __assertNotEqual -1  [ lsearch [gylib::typeOf no_one_what_is_it ] "unknown" ]
    }
    proc selectUnitTest {procname} {
        return [regexp -- {u_test.*} $procname]
    }
    
    set list [__filter [info procs] selectUnitTest]
    unit_test $list
}