unit module META6::To::Man;

use META6;

# variables set from input args
my $section;
# mandatory args
my $meta6      = 0; # META6 object
# options
my $man        = 0; # file name
my $debug      = 0; # 0 | 1
my $install    = 0; # 0 | 1
my $install-to = 0; # dir name

sub meta6-to-man(@*ARGS) is export {
    handle-args @*ARGS;

    write-man-file $man;
}

sub write-man-file($man) {

    # extract data from the META6 file
    my $descrip = $meta6.AT-KEY: 'description';
    my $name    = $meta6.AT-KEY: 'name';
    my $src-url = $meta6.AT-KEY: 'source-url';
    my $license = $meta6.AT-KEY: 'license';

    my $supp    = $meta6.support;
    my $issues  = $supp.bugtracker;

    if $debug {
	say "DEBUG: \$descrip  = '$descrip'";
	say "       \$name     = '$name'";
	say "       \$src-url  = '$src-url'";
	say "       \$issues   = '$issues'";
	say "       \$license  = '$license'";
    }

    # need a file name 
    if !$man {
        $section = 1;
        $man = $name ~ ".$section";
    }

    my $date = '2017-09-20';
    # generate the man file as a string first
    my $s  = ".TH $name $section $date Perl6.org\n";

    $s    ~= ".SH NAME $name\n";
    $s    ~= "item \- $descrip\n";

    $s    ~= ".SH SYNOPSIS\n";
    $s    ~= "use $name;\n";

    #$s    ~= ".SH DESCRIPTION\n";

    $s    ~= ".SH BUGS\n";
    $s    ~= "Submit bug reports to\n";
    $s    ~= ".UR\n";
    $s    ~= "$issues\n";
    $s    ~= ".UE\n";
    $s    ~= ".\n";

    #$s    ~= ".SH SEE ALSO\n";

    my $f = $man;
    if $install {
        $f = "$install/$f";
    }
    elsif $install-to {
        $f = "$install-to/$f";
    }

    # write the file
    spurt $f, $s;
}

sub check-meta6-value($val) {
    # val is a valid META6.json file
    if !$val.IO.f {
        die "FATAL: File '$val' doesn't exist.";
        #die "FATAL: File '$val' doesn't exist.\n";
        exit 1;
    }
    my $m = META6.new: :file($val);
    CATCH {
        die "FATAL: File '$val' is not a valid META6 file.";
        #die "FATAL: File '$val' is not a valid META6 file.\n";
        exit 1;
    }
    $meta6 = $m;
}

sub check-install-to-value($val) {
    # $val is a directory name the user must be able to write to
    if $val.IO.d {
        my $f = "$val/.meta6-to-man";
        spurt $f, 'some text';
        CATCH {
            die "FATAL: Unable to write to directory $val.";
            #die "FATAL: Unable to write to directory $val.\n";
            exit 1;
        }
    }
    else {
        die "FATAL: Directory $val doesn't exist.";
        #die "FATAL: Directory $val doesn't exist.\n";
        exit 1;
    }

    $install-to = $val;
}

sub check-man-value($val) {
    # $val is the desired name of the man file. ensure it
    # has a valid file extension
    if $val ~~ / '.' (<[1..8>]> ** 1) $/ {
        # name is okay
        $man = $val;
        $section = ~$0;
    }
    else {
        die "FATAL: Man name '$val' needs a number extension in the range '1..8'.";
        #die "FATAL: Man name '$val' needs a number extension in the range '1..8'.\n";
        exit 1;
    }
}

sub handle-args(@*ARGS) {
    # check for debug first
    my @args;
    for @*ARGS {
        if /:i debug / {
	    $debug = 1;
            next;
        }
        @args.append: $_;
    }

    for @args {
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
	    die "FATAL: Unknown arg '$_'.";
	    #die "FATAL: Unknown arg '$_'.\n";
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
            check-man-value $val;
	}
        when /:i ^ 'install-to'  $ / {
	    # option with value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-install-to-value $val;
	}
        when /:i ^ meta6  $ / {
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-meta6-value $val;
	}

	#===== options with NO value
        when /:i ^ install $ / {
	    # option with no value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if it has a value
	    proceed if $val.defined;
            $install = 1;
        }
        default {
            my $msg;
	    if $val.defined {
		 $msg = "FATAL: Unknown arg with value '{$_}={$val}'.";
	    }
	    elsif $need-value {
		$msg = "FATAL: Known arg '{$_}' also needs a value (e.g., 'arg=value').";
	    }
	    else {
		$msg = "FATAL: Unknown arg '{$_}' with no value.";
	    }
            die "$msg";
            #die "$msg\n";
	    exit 1;
        }
    }

    # one more check
    if !$meta6 {
	die "FATAL: Missing option '--meta6=M'.";
	#die "FATAL: Missing option '--meta6=M'.\n";
        exit 1;
    }

} # handle-args
