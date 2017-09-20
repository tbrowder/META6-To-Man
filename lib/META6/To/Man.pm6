unit module META6::To::Man;

sub meta6-to-man(@*ARGS) is export {
    for @*ARGS {
	say "arg '$_'";
    }
} # meta6-to-man
