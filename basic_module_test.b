implement Command;
include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "basic.m";
	basic_mod: Basic;

Command: module {
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	gb = load Graphbase Graphbase->PATH;
	basic_mod = load Basic "./basic.dis";
	
	if (basic_mod == nil) {
		print("Failed to load Basic module from ./basic.dis\n");
		return;
	}
	
	print("Testing Basic module (board)...\n");
	
	g := basic_mod->board(3, 3, 0, 0, 1, 0, 0); # 3x3 wazir, undirected
	if (g == nil) {
		print("board() returned nil\n");
		return;
	}
	
	print("Graph created: %d vertices, %d arcs\n", g.n, g.m);
	
	if (g.n == 9 && g.m == 24) {
		print("PASS: 3x3 Wazir\n");
	} else {
		print("FAIL: 3x3 Wazir. Expected 9, 24. Got %d, %d\n", g.n, g.m);
	}
}
