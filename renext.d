import std.stdio;
import std.conv;
import std.file;
import std.getopt;
import std.c.process;

import rename;

const char[] RENEXT_VERSION = "1.0.5";

void usage() {
    printVersion();
    writefln("Renames files using regular expressions\n"
             "\n"
             "syntax: renext [options] findRE replaceRE\n"
             "\n"
             "findRE            files to rename\n"
             "replaceRE         how to rename\n"
             "\n"
             "options:\n"
             "  -c, --capitalize  Capitalize Every Word\n"
             "  -a, --rename-all  rename files and directories\n"
             "  -d, --rename-dirs rename directories only\n"
             "  -g, --global      rename as many times as possible\n"
             "  -i, --ignore-case ignore case in findRE\n"
             "  -r, --recursive   search subdirectories recursively\n"
             "  -t, --test        don't change anything, just print possible changes\n"
             "  -v, --verbose     verbosity level (default: no output, -v: default output, -vv: much output)\n"
             "  -q, --quiet       same as verbose=0\n"
             "  -V, --version     display version and exit.\n"
             "  -h, --help        display this help and exit.\n"
             "\n"
             "examples:\n"
             "  renext \"ASD\" \"asd\"\n"
             "  renext -r \"(\\d)(\\d)\" \"$2$1\"");
}

void printVersion() {
    writefln("Rename Extended version %s - (c) 2006-2014, Marc Noirot", RENEXT_VERSION);
}

int main(string[] args) {
    auto renamer = new Renamer;
    
    // parse command line
    try {
	    getopt(args,
	    	std.getopt.config.caseSensitive,
	    	std.getopt.config.bundling,
	    	"capitalize|c",		&renamer.capitalize,
	    	"rename-all|a", 	{ renamer.renameDirs = true; renamer.renameFiles = true; },
	    	"rename-dirs|d", 	{ renamer.renameDirs = true; renamer.renameFiles = false; },
	    	"global|g", 		&renamer.global,
	    	"ignore-case|i", 	&renamer.ignoreCase,
	    	"recursive|r",		&renamer.recursive,
	    	"test|t",			&renamer.test,
	    	"verbose+|v+",		&renamer.verbosity,
	    	"quiet|q",			{ renamer.verbosity = 0; },
	    	"version|V",		{ printVersion(); exit(1); },
	    	"help|h",			{ usage(); exit(1); }
	    );
    }
    catch (Exception e) {
    	stderr.writefln(e.msg);
    	usage();
    	return 1;
    }

    if (args.length < 2) {
        usage();
        return 1;
    }
    
    renamer.findRe = args[1];
    renamer.replaceRe = args[2];

    uint renamed = renamer.renameInDir(getcwd());
    if (!renamer.test) {
        writefln("\n%d files successfully renamed.", renamed);
    }

    return 0;
}
