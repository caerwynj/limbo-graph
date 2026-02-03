implement TestInduced;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph, Util: import gb;
include "basic.m";
	basic_mod: Basic;

TestInduced: module {
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
	
	# Test 1: Induced on K2 with ind=2.
	# Should be K4 minus some edges? Or K2,2?
	# K2: 0-1.
	# ind(0)=2, ind(1)=2.
	# Vertices: 0:0, 0:1, 1:0, 1:1.
	# Arcs from 0 to 1 implies arcs from {0:0, 0:1} to {1:0, 1:1}.
	# Total 4 edges (8 arcs).
	# This is K2,2 (complete bipartite).
	
	g := basic_mod->complete(2); # 0, 1
	g.vertices[0].z = ref Util.I(2);
	g.vertices[1].z = ref Util.I(2);
	
	ind_g := basic_mod->induced(g, "test", 0, 0, 0);
	
	print("Test 1: Induced K2 (ind=2)\n");
	# Expect 4 vertices, 4 edges (8 arcs).
	if (ind_g.n == 4 && ind_g.m == 8) print("PASS: 4 vertices, 8 arcs\n");
	else print("FAIL: %d vertices, %d arcs (Expected 4, 8)\n", ind_g.n, ind_g.m);
    
    # Test 2: Induced on K3 with ind=1.
    # Should be isomorphic to K3.
    k3 := basic_mod->complete(3);
    k3.vertices[0].z = ref Util.I(1);
    k3.vertices[1].z = ref Util.I(1);
    k3.vertices[2].z = ref Util.I(1);
    
    ind_k3 := basic_mod->induced(k3, "test2", 0, 0, 0);
    print("Test 2: Induced K3 (ind=1)\n");
    if (ind_k3.n == 3 && ind_k3.m == 6) print("PASS: 3 vertices, 6 arcs\n");
    else print("FAIL: %d vertices, %d arcs (Expected 3, 6)\n", ind_k3.n, ind_k3.m);
}
