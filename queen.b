implement Queen;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph, Vertex, Arc, Util: import gb;
include "basic.m";
	basic_mod: Basic;
include "save.m";
	save_mod: Save;
include "io.m";
	io: GraphIO;
include "bufio.m";
	bufio: Bufio;

Queen: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	gb = load Graphbase Graphbase->PATH;
	basic_mod = load Basic "./basic.dis";
	save_mod = load Save "./save.dis";
	io = load GraphIO "./io.dis";
	bufio = load Bufio Bufio->PATH;
	
	save_mod->init(sys, io, gb, bufio);
	
	if (basic_mod == nil) { print("Failed to load Basic\n"); return; }
	if (save_mod == nil) { print("Failed to load Save\n"); return; }
	
	g := basic_mod->board(3, 4, 0, 0, -1, 0, 0); # Rook moves
	gg := basic_mod->board(3, 4, 0, 0, -2, 0, 0); # Bishop moves
	
	if (g == nil || gg == nil) { print("Failed to create graphs\n"); return; }
	
	ggg := basic_mod->gunion(g, gg, 0, 0); # Queen moves
	
	if (ggg == nil) { print("gunion failed\n"); return; }
	
	print("Saving queen.gb...\n");
	save_mod->save_graph(ggg, "queen.gb");
	
	print("Queen Moves on a 3x4 Board\n\n");
	print("  The graph whose official name is\n%s\n", ggg.id);
	print("  has %d vertices and %d arcs:\n\n", ggg.n, ggg.m);
	
	for (i := 0; i < ggg.n; i++) {
		v := ggg.vertices[i];
		print("%s\n", v.name);
		cnt := 0;
		for (a := v.arcs; a != nil; a = tl a) {
			arc := hd a;
			print("  -> %s, length %d\n", arc.tip.name, arc.length);
			cnt++;
		}
	}
}
