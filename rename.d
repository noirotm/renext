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

        foreach (DirEntry e; dirEntries(dir, SpanMode.shallow)) {
            string filename = baseName(e.name); 
            if (e.isDir)
                directories ~= filename;

            if (((renameDirs && e.isDir) || (renameFiles && !e.isDir)) && match(filename, re)) {
                if (replacements.length == 0 && verbosity == 1)
                    writefln("\n  %s", dir);

                auto repl = replace(filename, re, replaceRe);
                replacements[e] = repl;
                if (capitalize)
                    repl = capstr(repl);

                if (verbosity > 0) {
                    writefln("rename: %s ==> %s", filename, repl);
                }

                if (namesCallback != null) {
                    namesCallback(filename, repl);
                }
            }
            else {
                if (verbosity > 1)
                    writefln("skip: %s", filename);
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
                std.file.rename(e, std.path.buildPath(dir, repl));
                ++renamed;
            }
        }

        return renamed;
    }

    private static string capstr(string s)
    out (result) {
		assert(s.length == result.length, format("length should be %d, got %d ", s.length, result.length));
	}
    body {
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
            else {
            	result ~= std.ascii.toLower(c);
            }
        }
		return result.idup;
    }
    
    unittest {
    	assert(capstr("abc") == "Abc");
    	assert(capstr("ABC") == "Abc");
    	assert(capstr("abc def") == "Abc Def");
    }
}
