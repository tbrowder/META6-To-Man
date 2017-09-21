use v6;
use Test;

use META6::To::Man;


my $exe = '../bin/meta6-to-man';
my $m   = './data/META6.json';


# invalid args 
my @bad = 
"debug"
, "-debug"
, "--meta6"
, "-meta6=$m"
;
my $nbad = @bad.elems;;

# valid args
my @good = 
"--debug"
, "--meta6=$m"
;
my $ngood = @good.elems;;

plan 2;

subtest "invalid args ", {
    plan $nbad;
for @bad {
    my $cmd = "$exe $_";
    dies-ok { $cmd };
}
}

subtest "valid args", {
    plan $ngood;
for @good {
    my $cmd = "$exe $_";
    lives-ok { $cmd };
}
}



