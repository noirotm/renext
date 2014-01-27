module rename;

import std.stdio;
import std.file;
import std.path;
import std.string;
import std.regex;
import std.ascii;

/*
    File and directories renaming class
*/
class Renamer {
    bool capitalize = false;
    bool renameDirs = false;
    bool renameFiles = true;
    bool global = false;
    bool ignoreCase = false;
    bool recursive = false;
    bool test = false;
    int verbosity = 1;

    string findRe;
    string replaceRe;

    this() {}

    uint renameInDir(string dir, void delegate(string,string) namesCallback = null) {
        string[] directories;
        string[string] replacements;
        string attrib;
        uint renamed = 0;

        if (verbosity > 1)
            writefln("\n  %s", dir);
        if (ignoreCase)
            attrib = "i";
        if (global)
            attrib ~= "g";

        auto re = regex(findRe, attrib);

        auto entries = dirEntries(dir, SpanMode.shallow);
        foreach (string e; entries) {
            bool isDir = (isDir(std.path.buildPath(dir, e)) != 0);
            if (isDir)
                directories ~= e;

            if (((renameDirs && isDir) || (renameFiles && !isDir)) && match(e, re)) {
                if (replacements.length == 0 && verbosity == 1)
                    writefln("\n  %s", dir);

                auto repl = replace(e, re, replaceRe);
                replacements[e] = repl;
                if (capitalize)
                    repl = capstr(repl);

                if (verbosity > 0) {
                    writefln("rename: %s ==> %s", e, repl);
                }

                if (namesCallback != null) {
                    namesCallback(e, repl);
                }
            }
            else {
                if (verbosity > 1)
                    writefln("skip: %s", e);
            }
        }

        if (recursive) {
            foreach (d; directories) {
                if (d != "." || d != "..") {
                    renamed += renameInDir(std.path.buildPath(dir, d), namesCallback);
                }
            }
        }

        if (!test) {
            foreach (e, repl; replacements) {
                std.file.rename(std.path.buildPath(dir, e), std.path.buildPath(dir, repl));
                ++renamed;
            }
        }

        return renamed;
    }

    private string capstr(string s) {
        bool isBoundary = true;
		char[] result;
        foreach (c; s) {
            if (std.ascii.isWhite(c)) {
                isBoundary = true;
				result ~= c;
			}
            else if (isBoundary) {
                isBoundary = false;
                result ~= std.ascii.toUpper(c);
            }
        }
		return result.idup;
    }
}
