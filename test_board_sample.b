implement TestBoardSample;

include "sys.m";
	sys: Sys;
	print, sprint: import sys;
include "draw.m";
include "graph.m";
	gb: Graphbase;
	Graph, Vertex, Arc, Util: import gb;
include "board.m";
	board_mod: Board;

TestBoardSample: module
{
	init: fn(nil: ref Draw->Context, nil: list of string);
};

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	gb = load Graphbase Graphbase->PATH;
	board_mod = load Board "./board.dis";

	if (board_mod == nil) {
		print("Failed to load Board module\n");
		return;
	}

	# Test case from sgb/sample.correct
	# "board(1,1,2,-33,1,-2147483648,1)"
	# wrap = -2^31 (MIN_INT)
	min_int := int -2147483648; # Force int context
	
	g := board_mod->board(1, 1, 2, -33, 1, min_int, 1);
	if (g == nil) {
		print("Failed to create graph\n");
		return;
	}
	
	# The util_types for board are "ZZZIIIZZZZZZZZ"
	# Vertices use x,y,z (indices 3,4,5) as Ints.
	print_sample(g, 2000, "ZZZIIIZZZZZZZZ");
}

print_sample(g: ref Graph, n: int, util_types: string)
{
	print("\n");
	if (g == nil) {
		print("Ooops, graph is nil!\n");
	} else {
		# Print global characteristics
		print("\"%s\"\n%d vertices, %d arcs, util_types %s",
			g.id, g.n, g.m, util_types);
			
		pr_util(g.uu, util_types[8], 0, util_types);
		pr_util(g.ww, util_types[10], 0, util_types); # Limbo Graph has uu,ww,xx,yy,zz. Missing vv.
		# sgb/test_sample.w prints uu, vv, ww, xx, yy, zz.
		# If vv is missing in Limbo ADT, we skip it or print something else?
		# util_types[9] is for vv. board uses 'Z' so it prints nothing.
		# We'll just follow what we have.
		
		# Wait, print_sample prints all of them?
		# pr_util(g->uu...); pr_util(g->vv...);
		# If Limbo Graph lacks vv, we can't print it.
		# But since type is Z, it outputs nothing anyway.
		# xx, yy, zz are present.
		pr_util(g.xx, util_types[11], 0, util_types);
		pr_util(g.yy, util_types[12], 0, util_types);
		pr_util(g.zz, util_types[13], 0, util_types);
		print("\n");
		
		# Print vertex n
		print("V%d: ", n);
		if (n >= g.n || n < 0) {
			print("index is out of range!\n");
		} else {
			pr_vert(g.vertices[n], 1, util_types);
			print("\n");
		}
	}
}

pr_vert(v: ref Vertex, l: int, s: string)
{
	if (v == nil) {
		print("NULL");
	} else {
		print("\"%s\"", v.name);
		pr_util(v.u, s[0], l-1, s);
		pr_util(v.v, s[1], l-1, s);
		pr_util(v.w, s[2], l-1, s);
		pr_util(v.x, s[3], l-1, s);
		pr_util(v.y, s[4], l-1, s);
		pr_util(v.z, s[5], l-1, s);
		
		if (l > 0) {
			for (arcs := v.arcs; arcs != nil; arcs = tl arcs) {
				print("\n   ");
				pr_arc(hd arcs, 1, s);
			}
		}
	}
}

pr_arc(a: Arc, l: int, s: string)
{
	print("->");
	pr_vert(a.tip, 0, s);
	if (l > 0) {
		print(", %d", a.length);
		pr_util(a.a, s[6], l-1, s);
		pr_util(a.b, s[7], l-1, s);
	}
}

pr_util(u: ref Util, c: int, l: int, s: string)
{
	case c {
		'I' =>
			val := 0;
			if (u != nil) pick x := u { I => val = x.i; }
			print("[%d]", val);
		'S' =>
			str_val := "(null)";
			if (u != nil) pick x := u { S => if (x.s != nil) str_val = x.s; }
			print("[\"%s\"]", str_val);
		'A' =>
			if (l < 0) break;
			print("[");
			if (u == nil) print("NULL");
			else {
				# Util.A holds ref Arc?
				# Limbo Util: A => a: ref Arc;
				pick x := u { A => pr_arc(*x.a, l, s); }
			}
			print("]");
		'V' =>
			if (l < 0) break;
			print("[");
			pick x := u { V => pr_vert(x.v, l, s); }
			print("]");
		* =>
			# 'Z' or other
			break;
	}
}
