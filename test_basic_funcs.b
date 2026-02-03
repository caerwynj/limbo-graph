implement TestBasicFuncs;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "basic.m";
	basic_mod: Basic;

TestBasicFuncs: module {
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	gb = load Graphbase Graphbase->PATH;
	basic_mod = load Basic "./basic.dis";
	
	if (basic_mod == nil) {
		print("Failed to load Basic module\n");
		return;
	}
	
	# Test complete(5) -> K5
	# 5 vertices, 5*4 = 20 arcs (if directed) or 10 edges (20 arcs)
	# board implementation of undirected creates 2 arcs per edge.
	# complete calls board(n, 0..., -1, 0, 0) -> piece=1 (positive), directed=0.
	# piece=1 means King moves?
	# Wait, complete uses -1.
	# board: if piece < 0 { p = -p } -> p=1.
	# But piece logic in board:
	# if piece < 0:
	#   same := 1; check if yy != xx. if same break.
	#   This ensures we don't have self loops?
	#   piece=-1 (rook-like but strictly changing coordinate?)
	#   Wait, SGB documentation says:
	#   complete(n) = board(n,0,0,0,-1,0,0).
	#   Let's see what happens.
	
	print("Testing complete(5)...\n");
	g := basic_mod->complete(5);
	if (g != nil) {
		print("complete(5): %d vertices, %d arcs\n", g.n, g.m);
		# Expected: 5 vertices. Arcs: every vertex connected to every other. 5 * 4 = 20 arcs.
		if (g.n == 5 && g.m == 20) print("PASS\n"); else print("FAIL\n");
	} else print("FAIL (nil)\n");

	print("Testing transitive(5)...\n");
	g = basic_mod->transitive(5);
	if (g != nil) {
		print("transitive(5): %d vertices, %d arcs\n", g.n, g.m);
        # Directed. 5 * 4 = 20 arcs? Or upper triangular?
        # SGB: transitive(n) = board(n, ..., -1, 0, 1). Directed.
        # It creates arcs v->u.
        # Transitive tournament? Or full directed graph?
        # If it's complete directed graph (with no self loops), it's 20 arcs.
		# Let's verify output.
	} else print("FAIL (nil)\n");

	print("Testing empty(5)...\n");
	g = basic_mod->empty(5);
	if (g != nil) {
		print("empty(5): %d vertices, %d arcs\n", g.n, g.m);
		if (g.n == 5 && g.m == 0) print("PASS\n"); else print("FAIL\n");
	} else print("FAIL (nil)\n");

    print("Testing circuit(5)...\n");
    g = basic_mod->circuit(5);
    if (g != nil) {
        print("circuit(5): %d vertices, %d arcs\n", g.n, g.m);
        # Undirected cycle C5. 5 edges = 10 arcs.
        if (g.n == 5 && g.m == 10) print("PASS\n"); else print("FAIL\n");
    } else print("FAIL (nil)\n");

    print("Testing cycle(5)...\n");
    g = basic_mod->cycle(5);
    if (g != nil) {
        print("cycle(5): %d vertices, %d arcs\n", g.n, g.m);
        # Directed cycle. 5 arcs.
        if (g.n == 5 && g.m == 5) print("PASS\n"); else print("FAIL\n");
    } else print("FAIL (nil)\n");

}
