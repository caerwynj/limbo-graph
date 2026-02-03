implement TestLines;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "basic.m";
	basic_mod: Basic;

TestLines: module {
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
	
	# Test 1: L(C5 directed) should be C5
	print("Test 1: L(C5 directed)\n");
	c5 := basic_mod->cycle(5); # 5 vertices, 5 arcs 0->1->2->3->4->0
	l_c5 := basic_mod->lines(c5, 1);
	# Vertices: 5. Arcs: 5?
	# Arc 0->1 (v0) connects to 1->2 (v1).
	# Yes, isomorphic to C5.
	if (l_c5.n == 5 && l_c5.m == 5) print("PASS: L(C5) has 5 vertices, 5 arcs\n");
	else print("FAIL: L(C5) has %d vertices, %d arcs\n", l_c5.n, l_c5.m);
	
	# Test 2: L(C5 undirected) should be C5
	print("Test 2: L(C5 undirected)\n");
	u_c5 := basic_mod->circuit(5); # 5 vertices, 5 edges (10 arcs)
	l_u_c5 := basic_mod->lines(u_c5, 0);
	# Vertices: 5 (edges). 
	# Adjacency: edge {0,1} connects to {1,2} (shares 1) and {4,0} (shares 0).
	# Degree 2. 5 vertices, 5 edges (10 arcs).
	if (l_u_c5.n == 5 && l_u_c5.m == 10) print("PASS: L(Undirected C5) has 5 vertices, 10 arcs\n");
	else print("FAIL: L(Undirected C5) has %d vertices, %d arcs\n", l_u_c5.n, l_u_c5.m);

    # Test 3: L(K3 directed)
    # K3 directed (complete(3) without -1). complete calls board(.., -1).
    # complete is undirected by default unless built manually?
    # complete(n) uses board(..., -1, 0, 0). Undirected.
    # We can use transitive(3) for directed?
    # transitive(3): 0->1, 0->2, 1->2. (3 arcs).
    # L(T3):
    # vA(0->1), vB(0->2), vC(1->2).
    # vA ends at 1. Start at 1: vC. So vA->vC.
    # vB ends at 2. Start at 2: None.
    # vC ends at 2. Start at 2: None.
    # Only 1 arc: A->C.
    print("Test 3: L(Transitive 3)\n");
    t3 := basic_mod->transitive(3);
    l_t3 := basic_mod->lines(t3, 1);
    # 3 vertices. 1 arc.
    if (l_t3.n == 3 && l_t3.m == 1) print("PASS: L(T3) has 3 vertices, 1 arc\n");
    else print("FAIL: L(T3) has %d vertices, %d arcs\n", l_t3.n, l_t3.m);
    
    # Test 4: L(K3 undirected) -> K3
    # K3 has 3 edges. L(K3) has 3 vertices.
    # Edges share vertices. All pairs connected. -> K3.
    print("Test 4: L(K3 undirected)\n");
    k3 := basic_mod->complete(3);
    l_k3 := basic_mod->lines(k3, 0);
    if (l_k3.n == 3 && l_k3.m == 6) print("PASS: L(K3) has 3 vertices, 6 arcs\n"); # 3 edges = 6 arcs
    else print("FAIL: L(K3) has %d vertices, %d arcs\n", l_k3.n, l_k3.m);
}
