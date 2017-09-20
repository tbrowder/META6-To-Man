# META6::To::Man  [![Build Status](https://travis-ci.org/tbrowder/META6-To-Man-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/META6-To-Man-Perl6)

Produces a rudimentary man page from a Perl 6 META6.json (or META.json) file

# SYNOPSIS

```perl6
meta6-to-man META6.json > my-module.1
```

The output file should be a POSIX roff file. The default suffix number '1' may be changed by an option.

# MISCELLANEOUS

View a local man page on a POSIX system (e.g., the one you just generated):

```perl6
man -l <man src file name>.<number>
```
Example:

```perl6
man -l m-module.1
```

Man page numbers most likely for Perl 6 modules (from man-pages(7) :

+ 1 Commands (Programs)
	Those commands that can be executed by the user from within a shell.

+ 3 Library calls
	Most of the libc functions.

# REFERENCES

1. On a POSIX system:

  + man(7)
  + man-pages(7)

2. Writing man pages: https://liw.fi/manpages


## COPYRIGHT

Copyright (C) 2017 Thomas M. Browder, Jr. <<tom.browder@gmail.com>> (IRC #perl6: tbrowder)
