import std.stdio;
import std.c.stdlib;
import std.conv;
import std.file;
import cmdline;
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
             "      --verbose=x   verbose (x=0: no output, x=1: default output, x=2: much output)\n"
             "  -q, --quiet       same as verbose=0\n"
             "  -V, --version     display version and exit.\n"
             "  -h, --help        display this help and exit.\n"
             "\n"
             "examples: renext \"ASD\" \"asd\"\n"
             "\n"
             "          renext -r \"(\\d)(\\d)\" \"$2$1\"");
}

void printVersion() {
    writefln("Rename Extended version %s - (c) 2006, Marc Noirot", RENEXT_VERSION);
}

int main(char [][] args) {
    if (args.length < 2) {
        usage();
    }
    else {
        auto renamer = new Renamer;
        auto p = new CmdlineParser;

        p.addOption("capitalize", 'c',  { renamer.capitalize = true; });
        p.addOption("rename-all", 'a',  { renamer.renameDirs = true; renamer.renameFiles = true; });
        p.addOption("rename-dirs", 'd', { renamer.renameDirs = true; renamer.renameFiles = false; });
        p.addOption("global", 'g',      { renamer.global = true; });
        p.addOption("ignore-case", 'i', { renamer.ignoreCase = true; });
        p.addOption("recursive", 'r',   { renamer.recursive = true; });
        p.addOption("test", 't',        { renamer.test = true; });
        p.addOption("verbose", '\0', {
            if (p.option.length == 0) {
                stderr.writefln("No argument provided for option %s.", p.option);
                exit(EXIT_FAILURE);
            }
            else {
                try {
                    int level = to!int(p.arg);
                    if (level < 0 || level > 2)
                        throw new ConvException("");
                    renamer.verbosity = level;
                }
                catch (ConvException e) {
                    stderr.writefln("Invalid verbosity level: %s", p.arg);
                        exit(EXIT_FAILURE);
                }
            }
        });
        p.addOption("quiet", 'q',       { renamer.verbosity = 0; });
        p.addOption("version", 'V',     { printVersion(); exit(EXIT_SUCCESS); });
        p.addOption("help", 'h',        { usage(); exit(EXIT_SUCCESS); });
        p.setDefaultAction({
            if (p.index == p.argc-2) {
                renamer.findRe = p.option;
            }
            else if (p.index == p.argc-1) {
                renamer.replaceRe = p.option;
            }
            else if (p.index != 0) {
                stderr.writefln("Syntax error: %s", p.option);
                exit(EXIT_FAILURE);
            }
        });
        p.setUnknownOptionAction({
            stderr.writefln("Unknown option: %s\n", p.option);
            usage();
            exit(EXIT_FAILURE);
        });

        p.parse(args);

        uint renamed = renamer.renameInDir(getcwd());
        if (!renamer.test) {
            writefln("\n%d files successfully renamed.", renamed);
        }
    }
    return 0;
}
