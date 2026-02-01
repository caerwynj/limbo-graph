implement Basic;

include "sys.m";
	sys: Sys;
	print, sprint: import sys;
include "draw.m";
include "basic.m";
include "graph.m";
	gb: Graphbase;
	Graph, Vertex, Arc, Util, new_graph, new_vert, new_arc: import gb;

State: adt {
	nn: array of int;
	wr: array of int;
	del: array of int;
	sig: array of int;
	xx: array of int;
	yy: array of int;
	d: int;
	g: ref Graph;

	advance_delta: fn(s: self ref State, p: int): int;
	advance_signs: fn(s: self ref State): int;
	generate_moves: fn(s: self ref State, piece, directed: int);
};

init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	gb = load Graphbase Graphbase->PATH;
	
	n1, n2, n3, n4: int;
	piece, wrap, directed: int;

	# Default parameters
	n1 = 8; n2 = 8; n3 = 0; n4 = 0;
	piece = 1; wrap = 0; directed = 0;

	if (argv != nil) {
		argv = tl argv;
		if (argv != nil) { n1 = int hd argv; argv = tl argv; }
		if (argv != nil) { n2 = int hd argv; argv = tl argv; }
		if (argv != nil) { n3 = int hd argv; argv = tl argv; }
		if (argv != nil) { n4 = int hd argv; argv = tl argv; }
		if (argv != nil) { piece = int hd argv; argv = tl argv; }
		if (argv != nil) { wrap = int hd argv; argv = tl argv; }
		if (argv != nil) { directed = int hd argv; argv = tl argv; }
	}

	g := board(n1, n2, n3, n4, piece, wrap, directed);
	if (g != nil)
		print("Created board graph with %d vertices and %d arcs\n", g.n, g.m);
}

board(n1, n2, n3, n4, piece, wrap, directed: int): ref Graph
{
	if (sys == nil) sys = load Sys Sys->PATH;
	if (gb == nil) gb = load Graphbase Graphbase->PATH;

	i, j, k, n, p: int;
	d: int;

	MAX_D: con 91;
	
	nn := array[MAX_D+1] of int;

	if (piece == 0) piece = 1;

	if (n1 <= 0) { n1 = 8; n2 = 8; n3 = 0; }
	nn[1] = n1;
	if (n2 <= 0) { k = 2; d = -n2; n3 = 0; n4 = 0; }
	else {
		nn[2] = n2;
		if (n3 <= 0) { k = 3; d = -n3; n4 = 0; }
		else {
			nn[3] = n3;
			if (n4 <= 0) { k = 4; d = -n4; }
			else { nn[4] = n4; d = 4; }
		}
	}

	if (d == 0) d = k - 1;
	else {
		j = 1;
		while (k <= d) { nn[k] = nn[j]; j++; k++; }
	}

	n = 1;
	for (j = 1; j <= d; j++) n *= nn[j];
	
	g := new_graph();
	g.id = sprint("board(%d,%d,%d,%d,%d,%d,%d)", n1, n2, n3, n4, piece, wrap, directed);
	g.util_types = "IZZZZZZZZZZZZZ";

	s := ref State;
	s.nn = nn;
	s.wr = array[MAX_D+1] of int;
	s.del = array[MAX_D+1] of int;
	s.sig = array[MAX_D+2] of int;
	s.xx = array[MAX_D+1] of int;
	s.yy = array[MAX_D+1] of int;
	s.d = d;
	s.g = g;

	# Init xx
	for (k = 0; k <= d; k++) s.xx[k] = 0;
	s.nn[0] = 0; 
	
	g.vertices = array[n] of ref Vertex;
	for (i = 0; i < n; i++) {
		v := new_vert(g);
		if (v == nil) {
			print("Error: failed to create vertex %d\n", i);
			break;
		}
		g.vertices[i] = v;
		
		# Name
		nm := "";
		for (k = 1; k <= d; k++) nm += sprint(".%d", s.xx[k]);
		if (len nm > 0) v.name = nm[1:];
		else v.name = ""; 
		
		# Set util fields
		if (d >= 1) v.u = ref Util.I(s.xx[1]);
		if (d >= 2) v.v = ref Util.I(s.xx[2]);
		if (d >= 3) v.w = ref Util.I(s.xx[3]);

		for (k = d; s.xx[k] + 1 == s.nn[k]; k--) s.xx[k] = 0;
		if (k > 0) s.xx[k]++;
	}
	g.n = n;

	w := wrap;
	for (k = 1; k <= d; k++) {
		s.wr[k] = w & 1;
		w >>= 1;
		s.del[k] = 0; s.sig[k] = 0;
	}
	s.sig[0] = 0; s.del[0] = 0; s.sig[d+1] = 0;

	p = piece;
	if (p < 0) p = -p;

	while (s.advance_delta(p)) {
		while (1) {
			s.generate_moves(piece, directed);
			if (!s.advance_signs()) break;
		}
	}
	
	return g;
}

State.advance_delta(s: self ref State, p: int): int
{
	k: int;
	for (k = s.d; s.sig[k] + (s.del[k]+1)*(s.del[k]+1) > p; k--)
		s.del[k] = 0;
	
	if (k == 0) return 0;
	
	s.del[k]++;
	s.sig[k+1] = s.sig[k] + s.del[k]*s.del[k];
	for (k++; k <= s.d; k++) s.sig[k+1] = s.sig[k];
	
	if (s.sig[s.d+1] < p) return s.advance_delta(p);
	return 1;
}

State.advance_signs(s: self ref State): int
{
	k: int;
	for (k = s.d; s.del[k] <= 0; k--) s.del[k] = -s.del[k];
	if (s.sig[k] == 0) return 0;
	s.del[k] = -s.del[k];
	return 1;
}

State.generate_moves(s: self ref State, piece, directed: int)
{
	k, i, l, j: int;
	v, u: ref Vertex;

	for (k = 1; k <= s.d; k++) s.xx[k] = 0;

	for (i = 0; i < s.g.n; i++) {
		v = s.g.vertices[i];
		for (k = 1; k <= s.d; k++) s.yy[k] = s.xx[k] + s.del[k];
		
		for (l = 1; ; l++) {
			ok := 1;
			for (k = 1; k <= s.d; k++) {
				if (s.yy[k] < 0) {
					if (s.wr[k] == 0) { ok = 0; break; }
					while (s.yy[k] < 0) s.yy[k] += s.nn[k];
				} else if (s.yy[k] >= s.nn[k]) {
					if (s.wr[k] == 0) { ok = 0; break; }
					while (s.yy[k] >= s.nn[k]) s.yy[k] -= s.nn[k];
				}
			}
			if (!ok) break;

			if (piece < 0) {
				same := 1;
				for (k = 1; k <= s.d; k++) if (s.yy[k] != s.xx[k]) { same = 0; break; }
				if (same) break;
			}

			j = s.yy[1];
			for (k = 2; k <= s.d; k++) j = s.nn[k] * j + s.yy[k];
			
			u = s.g.vertices[j];
			gb->new_arc(s.g, v, u, l);
			if (!directed) gb->new_arc(s.g, u, v, l);

			if (piece > 0) break;
			for (k = 1; k <= s.d; k++) s.yy[k] += s.del[k];
		}
		for (k = s.d; s.xx[k] + 1 == s.nn[k]; k--) s.xx[k] = 0;
		if (k > 0) s.xx[k]++;
	}
}

gunion(g, gg: ref Graph, multi, directed: int): ref Graph
{
	if (sys == nil) sys = load Sys Sys->PATH;
	if (gb == nil) gb = load Graphbase Graphbase->PATH;

	if (g == nil || gg == nil) {
		print("Missing operand\n");
		return nil;
	}

	n := g.n;
	new_graph := gb->new_graph();
    new_graph.vertices = array[n] of ref Vertex;
    
	new_graph.id = sprint("gunion(%s,%s,%d,%d)", g.id, gg.id, multi, directed);
    new_graph.util_types = g.util_types; 
	
	# Clear tmp fields in new_graph
	for (i := 0; i < n; i++) {
        v := gb->new_vert(new_graph);
        new_graph.vertices[i] = v;
        # Copy name from g
        v.name = g.vertices[i].name;
        
        # Use v.u for tmp, v.w for tlen (though we only check tmp for now)
		v.u = nil; 
		v.w = nil; 
	}

	for (i = 0; i < n; i++) {
		v := g.vertices[i];       # Vertex in g
		vv := new_graph.vertices[i]; # Vertex in new_graph
		
        # Process arcs from g
		for (l := v.arcs; l != nil; l = tl l) {
            a := hd l;
			tip_idx := find_vert_idx(g, a.tip);
			if (tip_idx == -1) continue;
			
			u := new_graph.vertices[tip_idx];
			
			insert_union_arc(vv, u, a.length, multi, directed, new_graph);
		}

        # Process arcs from gg
        if (i < gg.n) {
            vvv := gg.vertices[i];
            for (l := vvv.arcs; l != nil; l = tl l) {
                a := hd l;
                tip_idx := find_vert_idx(gg, a.tip);
                if (tip_idx == -1) continue; 
                
                if (tip_idx < n) {
                    u := new_graph.vertices[tip_idx];
                    insert_union_arc(vv, u, a.length, multi, directed, new_graph);
                }
            }
        }
	}
    
    # Cleanup tmp fields
    for (i = 0; i < n; i++) {
        new_graph.vertices[i].u = nil;
        new_graph.vertices[i].w = nil;
    }

	return new_graph;
}

get_util_v(u: ref Util): ref Vertex
{
	if (u == nil) return nil;
	pick x := u {
		V => return x.v;
		* => return nil;
	}
	return nil;
}

insert_union_arc(vv, u: ref Vertex, length: int, multi, directed: int, g: ref Graph)
{
	if (directed) {
        last_v := get_util_v(u.u);
		if (multi || last_v == nil || last_v != vv) {
			gb->new_arc(g, vv, u, length);
        } else {
            # Need update? For now we skip as per plan for queen demo
            # if (u.w ...) check min length
		}
		u.u = ref Util.V(vv);
		# u.w = ref Util.A(vv.arcs); # Skip tlen/w as we don't update
		
	} else {
        # Undirected
        # Check index condition vv <= u
        idx_vv := find_vert_idx(g, vv); # O(N) search
        idx_u := find_vert_idx(g, u);
        
        if (idx_u >= idx_vv) {
            created := 0;
            last_v := get_util_v(u.u);
            
    		if (multi || last_v == nil || last_v != vv) {
                gb->new_arc(g, vv, u, length);
                gb->new_arc(g, u, vv, length);
                created = 1;
    		} else {
                 # Update logic skipped
    		}
    		u.u = ref Util.V(vv);
    		# u.w = ...
            
            if (vv == u && created) {
                # self loop, new_edge created two arcs vv->vv.
                # Remove second one.
                # v.arcs is stack. new_arc pushes.
                # First new_arc pushes A1. Second new_arc pushes A2.
                # Head is A2. We remove head.
                if (vv.arcs != nil) vv.arcs = tl vv.arcs;
            }
        }
	}
}

find_vert_idx(g: ref Graph, v: ref Vertex): int
{
	for(i := 0; i < g.n; i++)
		if(g.vertices[i] == v) return i;
	return -1;
}
