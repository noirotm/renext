Rename Extended
===============

A small command-line utility written in D for the sake of evaluating the language.

Building
--------

Renext uses DUB (https://github.com/rejectedsoftware/dub).

Assuming you have `dub` and a D compiler installed, just type `dub build` and you're done.

Usage
-----

    
    Rename Extended version 1.0.5 - (c) 2006-2014, Marc Noirot
    Renames files using regular expressions
    
    syntax: renext [options] findRE replaceRE
    
    findRE            files to rename
    replaceRE         how to rename
    
    options:
      -c, --capitalize  Capitalize Every Word
      -a, --rename-all  rename files and directories
      -d, --rename-dirs rename directories only
      -g, --global      rename as many times as possible
      -i, --ignore-case ignore case in findRE
      -r, --recursive   search subdirectories recursively
      -t, --test        don't change anything, just print possible changes
      -v, --verbose     verbosity level (default: no output, -v: default output, -vv: much output)
      -q, --quiet       same as verbose=0
      -V, --version     display version and exit.
      -h, --help        display this help and exit.
    
    examples:
      renext "ASD" "asd"
      renext -r "(\d)(\d)" "$2$1"
