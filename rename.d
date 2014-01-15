module rename;

import std.stdio;
import std.file;
import std.path;
import std.string;
import std.regexp;
import std.ctype;

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

        auto re = new RegExp(findRe, attrib);

        auto entries = std.file.listdir(dir);
        foreach (e; entries) {
            bool isDir = (isdir(std.path.join(dir, e)) != 0);
            if (isDir)
                directories ~= e;

            if (((renameDirs && isDir) || (renameFiles && !isDir)) && re.test(e)) {
                if (replacements.length == 0 && verbosity == 1)
                    writefln("\n  %s", dir);

                auto repl = re.replace(e, replaceRe);
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
                if (cmp(d, curdir) || cmp(d, pardir)) {
                    renamed += renameInDir(std.path.join(dir, d), namesCallback);
                }
            }
        }

        if (!test) {
            foreach (e, repl; replacements) {
                std.file.rename(std.path.join(dir, e), std.path.join(dir, repl));
                ++renamed;
            }
        }

        return renamed;
    }

    private string capstr(string s) {
        bool isBoundary = true;
		char[] result;
        foreach (c; s) {
            if (isspace(c)) {
                isBoundary = true;
				result ~= c;
			}
            else if (isBoundary) {
                isBoundary = false;
                result ~= std.ctype.toupper(c);
            }
        }
		return result.idup;
    }
}
