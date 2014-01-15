module cmdline;

import std.string;

/*
    Command line parser
*/
class CmdlineParser {
    struct Option {
        int index;
        string value;
        string arg;
    }

    // a simple action
    alias void delegate() Action;

    private {
        Action[string] longOptList;
        Action[char] shortOptList;
        Action defaultAction;
        Action unknownOptionAction;
        int argCount;
        int currentIndex;
		string currentOption;
		string currentOptionArg;
    }

    void addOption(string longopt, char shortopt, Action a) {
        if (longopt.length > 0)
            longOptList[longopt] = a;
        if (shortopt != 0)
            shortOptList[shortopt] = a;
    }

    void setDefaultAction(Action a) {
        defaultAction = a;
    }

    void setUnknownOptionAction(Action a) {
        unknownOptionAction = a;
    }

    int argc() { return argCount; }
    int index() { return currentIndex; }
	string option() { return currentOption;	}
	string arg() { return currentOptionArg; }

    // parse the command line
    void parse(char[][] args) {
        argCount = args.length;
        foreach (int i, char[] arg; args) {
            currentIndex = i;
            currentOption = arg.idup;
            currentOptionArg = "";
            // long switch test
            if (arg.length > 2 && !cmp(arg[0..2], "--")) {
                int eqpos = arg.indexOf('=');
                if (eqpos != -1) {
					currentOption = arg[0..eqpos].idup;
                    currentOptionArg = arg[eqpos+1..$].idup;
                }
                else {
                    eqpos = arg.length;
                }
                if (arg[2..eqpos] in longOptList) {
                    longOptList[arg[2..eqpos]]();
                }
                else {
                    if (unknownOptionAction != null) {
                        unknownOptionAction();
                    }
                }
            }
            // short switch test
            else if ((arg.length == 2 || (arg.length > 2 && arg[2] == '=')) && arg[0] == '-') {
                if (arg.length > 2 && arg[2] == '=') {
					currentOption = arg[0..1].idup;
                    currentOptionArg = arg[3..$].idup;
                }
                if (arg[1] in shortOptList) {
                    shortOptList[arg[1]]();
                }
                else {
                    if (unknownOptionAction != null) {
                        unknownOptionAction();
                    }
                }
            }
            // any argument
            else {
                if (defaultAction != null) {
                    defaultAction();
                }
            }
        }
    }
}
