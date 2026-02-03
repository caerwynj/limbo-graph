implement TestComplement;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "basic.m";
	basic_mod: Basic;

TestComplement: module {
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
	
	# Test 1: Complement of Complete(5) should be Empty(5)
    # complete(5) has 20 arcs.
    # empty(5) has 0 arcs.
    # complement(K5, 0, 0, 0)
    
    print("Test 1: Complement of K5\n");
    k5 := basic_mod->complete(5);
    k5_comp := basic_mod->complement(k5, 0, 0, 0);
    
    if (k5_comp.m == 0) print("PASS: K5 complement has 0 arcs\n");
    else print("FAIL: K5 complement has %d arcs\n", k5_comp.m);
    
    # Test 2: Double Complement of K5 should be K5
    # complement(empty, 0, 0, 0)
    k5_restored := basic_mod->complement(k5_comp, 0, 0, 0);
    if (k5_restored.m == 20) print("PASS: K5 restored\n");
    else print("FAIL: K5 restored has %d arcs\n", k5_restored.m);
    
    # Test 3: Copy of K5 (double complement flag=1)
    k5_copy := basic_mod->complement(k5, 1, 0, 0);
    if (k5_copy.m == 20) print("PASS: K5 copy has 20 arcs\n");
    else print("FAIL: K5 copy has %d arcs\n", k5_copy.m);
    
    # Test 4: Directed Cycle C5 complement
    # C5: 0->1, 1->2, 2->3, 3->4, 4->0 (5 arcs)
    # Total arcs in directed complete with loops=0: 5*4 = 20.
    # Complement should have 15 arcs.
    c5 := basic_mod->cycle(5);
    c5_comp := basic_mod->complement(c5, 0, 0, 1);
    
    if (c5_comp.m == 15) print("PASS: C5 complement has 15 arcs\n");
    else print("FAIL: C5 complement has %d arcs\n", c5_comp.m);
    
    # Test 5: Self loops
    # complement(empty(3), 0, 1, 0) -> complete graph with self loops
    # 3 vertices. Arcs: 3*3 = 9 edges? (undirected: 3 self loops + 3 edges * 2 = 9 arcs? No)
    # Undirected:
    # 0-0, 1-1, 2-2 (3 arcs?)
    # 0-1, 0-2, 1-2 (3 edges * 2 = 6 arcs)
    # Total 9 arcs?
    # Wait, gb_new_edge creates 2 arcs. gb_new_arc creates 1.
    # If self loop, gb_new_arc called once?
    # In my implementation of complement:
    # if (vv==u && created) new_arc called twice, then second removed. So 1 arc.
    # So 3 self loops + 6 non-loop arcs = 9 arcs.
    
    e3 := basic_mod->empty(3);
    e3_self := basic_mod->complement(e3, 0, 1, 0);
    if (e3_self.m == 12) print("PASS: Empty(3) complement with self loops has 12 arcs\n");
    else print("FAIL: Empty(3) complement with self loops has %d arcs\n", e3_self.m);
}
