implement TestSaveRestore;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "io.m";
	io: GraphIO;
include "save.m";
	save_mod: Save;
include "basic.m";
	basic_mod: Basic;

TestSaveRestore: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	gb = load Graphbase Graphbase->PATH;
	io = load GraphIO "./io.dis";
	save_mod = load Save "./save.dis";
	basic_mod = load Basic "./basic.dis";
	
	save_mod->init(sys, io, gb, bufio);
	# board_mod->init(nil, nil); 
	
	print("Generating 3x3 board graph...\n");
	g := basic_mod->board(3, 3, 0, 0, 1, 0, 0);
	
	print("Saving graph to 'test_sr.gb'...\n");
	res := save_mod->save_graph(g, "test_sr.gb");
	if (res != 0) {
		print("Save failed with code %d\n", res);
		return;
	}
	
	print("Restoring graph from 'test_sr.gb'...\n");
	g_restored := save_mod->restore_graph("test_sr.gb");
	
	if (g_restored == nil) {
		print("Restore failed\n");
		return;
	}
	
	print("Original: %d vertices, %d arcs\n", g.n, g.m);
	print("Restored: %d vertices, %d arcs\n", g_restored.n, g_restored.m);
	
	if (g.n == g_restored.n && g.m == g_restored.m) {
		print("PASS: Basic dimensions match\n");
	} else {
		print("FAIL: Dimensions mismatch\n");
	}
	
	if (g.id == g_restored.id) {
		print("PASS: IDs match\n");
	} else {
		print("FAIL: IDs mismatch: '%s' vs '%s'\n", g.id, g_restored.id);
	}
}
