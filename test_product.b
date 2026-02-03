implement TestProduct;

include "sys.m";
	sys: Sys;
	print: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph: import gb;
include "basic.m";
	basic_mod: Basic;

TestProduct: module {
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
	
	# Create K2 (complete(2)). 0--1.
	k2 := basic_mod->complete(2);
	
	# Test 1: Cartesian Product K2 x K2 = C4 (Square)
	# 4 vertices. 4 edges. (8 arcs)
	p_cart := basic_mod->product(k2, k2, 0, 0);
	print("Test 1: Cartesian Product K2xK2 (C4)\n");
	if (p_cart.n == 4 && p_cart.m == 8) print("PASS: 4 vertices, 8 arcs\n");
	else print("FAIL: %d vertices, %d arcs\n", p_cart.n, p_cart.m);

    # Test 2: Direct Product K2 x K2
    # 2 edges. (4 arcs)
    p_direct := basic_mod->product(k2, k2, 1, 0);
    print("Test 2: Direct Product K2xK2\n");
    if (p_direct.n == 4 && p_direct.m == 4) print("PASS: 4 vertices, 4 arcs\n");
    else print("FAIL: %d vertices, %d arcs\n", p_direct.n, p_direct.m);

    # Test 3: Strong Product K2 x K2 = K4
    # 6 edges. (12 arcs)
    p_strong := basic_mod->product(k2, k2, 2, 0);
    print("Test 3: Strong Product K2xK2 (K4)\n");
    if (p_strong.n == 4 && p_strong.m == 12) print("PASS: 4 vertices, 12 arcs\n");
    else print("FAIL: %d vertices, %d arcs\n", p_strong.n, p_strong.m);
}
