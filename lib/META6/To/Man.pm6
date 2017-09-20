unit module META6::To::Man;

my $debug = 0;
sub meta6-to-man(@*ARGS) is export {
    # check for debug first
    for @*ARGS {
	$debug = 1 if /:i debug /;
    }
    for @*ARGS {
	say "DEBUG: arg '$_'" if $debug;
	my $val;
	my $need-value = 0;
	if /:i ^ \s* '--' (<-[=]>+) \s* $ / {
	    # good arg format
	    $_ = ~$0;
	    say "  DEBUG: good arg format" if $debug;
	}
	elsif /:i ^ \s* '--' (<-[=]>+) '=' (<-[=]>+) \s* $ / {
	    # good arg format
	    say "  DEBUG: good arg format" if $debug;
	    $_   = ~$0;
	    $val = ~$1;
	}
	else {
	    say "FATAL: Unknown arg '$_'";
	    exit 1;
	}

	if $debug {
	    say "  DEBUG: good arg '$_'";
	    say "  DEBUG: good val '$val'" if $val.defined;
	    #say "DEBUG tmp next arg"; next;
	}

	#===== options with a value
        when /:i ^ man  $ / {
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
	}
        when /:i ^ 'install-to'  $ / {
	    # option with value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
	}

	#===== options with NO value
        when /:i ^ install $ / {
	    # option with no value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if it has a value
	    proceed if $val.defined;
        }
        when /:i ^ debug $ / {
	    # option with no value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if it has a value
	    proceed if $val.defined;
        }
        default {
	    if $val.defined {
		say "FATAL: Unknown arg with value'{$_}={$val}'.";
	    }
	    elsif $need-value {
		say "FATAL: Known arg '{$_}' also needs a value (e.g., 'arg=value').";
	    }
	    else {
		say "FATAL: Unknown arg '{$_}' with no value.";
	    }
	    exit 1;
        }
    }
} # meta6-to-man
