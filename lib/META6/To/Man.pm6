unit module META6::To::Man;

use META6;

# variables setbfrom input args
# mandatory args
my $meta6      = 0; # META6 object
my $man        = 0; # file name
# options
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

    #my $issues  = $meta6.AT-KEY: 'bugtracker';
    my $issues  = $supp.bugtracker;

    if $debug {
	say "DEBUG: \$descrip  = '$descrip'";
	say "       \$name     = '$name'";
	say "       \$src-url  = '$src-url'";
	say "       \$issues   = '$issues'";
	say "       \$license  = '$license'";
    }

    # generate the man file as a string first
    my $s = '';

    if $install {
    }
    elsif $install-to {

    }
    else {
    }
}

sub check-meta6-value($val) {
    # val is a valid META6.json file
    if !$val.IO.f {
        say "FATAL: File '$val' doesn't exist.";
        exit 1;
    }
    my $m = META6.new: :file($val);
    CATCH {
        say "FATAL: File '$val' is not a valid META6 file.";
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
            say "FATAL: Unable to write to directory $val.";
            exit 1;
        }
    }
    else {
        say "FATAL: Directory $val doesn't exist.";
        exit 1;
    }

    $install-to = $val;
}

sub check-man-value($val) {
    # $val is the desired name of the man file. ensure it
    # has a valid file extension
    if $val ~~ / '.' <[1..8>]> ** 1 $/ {
        # name is okay
        $man = $val;
    }
    else {
        say "FATAL: Man name '$val' needs a number extension in the range '1..8'";
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
	    if $val.defined {
		say "FATAL: Unknown arg with value '{$_}={$val}'.";
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
