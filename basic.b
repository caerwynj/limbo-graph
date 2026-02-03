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

complete(n: int): ref Graph
{
    return board(n, 0, 0, 0, -1, 0, 0);
}

transitive(n: int): ref Graph
{
    return board(n, 0, 0, 0, -1, 0, 1);
}

empty(n: int): ref Graph
{
    return board(n, 0, 0, 0, 2, 0, 0);
}

circuit(n: int): ref Graph
{
    return board(n, 0, 0, 0, 1, 1, 0);
}

cycle(n: int): ref Graph
{
    return board(n, 0, 0, 0, 1, 1, 1);
}

complement(g: ref Graph, copy, self_loop, directed: int): ref Graph
{
	if (g == nil) {
		print("Missing operand\n");
		return nil;
	}

	n := g.n;
	new_graph := gb->new_graph();
	new_graph.vertices = array[n] of ref Vertex;
	
	new_graph.id = sprint("complement(%s,%d,%d,%d)", g.id, copy, self_loop, directed);
	new_graph.util_types = g.util_types; 

	# Initialize vertices
	for (i := 0; i < n; i++) {
		v := g.vertices[i];
		u := gb->new_vert(new_graph);
		new_graph.vertices[i] = u;
		u.name = v.name;
		u.u = nil; # Clear tmp usage
	}
	
	for (i = 0; i < n; i++) {
		v := g.vertices[i];       # Old vertex
		u := new_graph.vertices[i]; # New vertex
		
		# Mark neighbors
		for (a := v.arcs; a != nil; a = tl a) {
			arc := hd a;
			tip_idx := find_vert_idx(g, arc.tip);
			if (tip_idx >= 0) {
				new_graph.vertices[tip_idx].u = ref Util.V(u);
			}
		}

		if (directed) {
			for (j := 0; j < n; j++) {
				vv := new_graph.vertices[j];
				marked := (vv.u != nil) && (get_util_v(vv.u) == u);
				
				if ((marked && copy) || (!marked && !copy)) {
					if (vv != u || self_loop) {
						gb->new_arc(new_graph, u, vv, 1);
					}
				}
			}
		} else {
			start_j := i + 1;
			if (self_loop) start_j = i;
			
			for (j := start_j; j < n; j++) {
				vv := new_graph.vertices[j];
				marked := (vv.u != nil) && (get_util_v(vv.u) == u);
				
				if ((marked && copy) || (!marked && !copy)) {
					gb->new_arc(new_graph, u, vv, 1);
					gb->new_arc(new_graph, vv, u, 1);
				}
			}
		}
	}
	
	# Clean up util fields
	for (i = 0; i < n; i++) {
		new_graph.vertices[i].u = nil;
	}

	return new_graph;
}

intersection(g, gg: ref Graph, multi, directed: int): ref Graph
{
	if (g == nil || gg == nil) { print("Missing operand\n"); return nil; }
	n := g.n;
	if (gg.n < n) n = gg.n; 

	new_graph := gb->new_graph();
	new_graph.vertices = array[n] of ref Vertex;
	new_graph.n = n;
	new_graph.id = sprint("intersection(%s,%s,%d,%d)", g.id, gg.id, multi, directed);
	new_graph.util_types = g.util_types;

	for (i := 0; i < n; i++) {
        v := g.vertices[i];
		u := gb->new_vert(new_graph);
		new_graph.vertices[i] = u;
		u.name = v.name;
		u.u = nil; 
        u.w = nil; 
	}
    
    for (i = 0; i < n; i++) {
        v := g.vertices[i];
        vv := new_graph.vertices[i];
        vvv := gg.vertices[i]; 

        # 1. Mark neighbors of v in new_graph space
        for (a := v.arcs; a != nil; a = tl a) {
            tip_g := hd a;
            tip_idx := find_vert_idx(g, tip_g.tip);
            if (tip_idx < 0 || tip_idx >= n) continue;
            
            u := new_graph.vertices[tip_idx];
            
            if (u.u == nil || get_util_v(u.u) != vv) {
                u.u = ref Util.V(vv);
                u.v = ref Util.I(1); # count = 1
                u.w = ref Util.I(tip_g.length); # minlen
            } else {
                 pick m := u.v { I => u.v = ref Util.I(m.i + 1); }
                 pick l := u.w { I => if (tip_g.length < l.i) u.w = ref Util.I(tip_g.length); }
            }
        }
        
        # 2. Check arcs in gg
        for (a = vvv.arcs; a != nil; a = tl a) {
            tip_gg := hd a;
            tip_idx := find_vert_idx(gg, tip_gg.tip);
            if (tip_idx < 0 || tip_idx >= n) continue;
            
            u := new_graph.vertices[tip_idx];
            
            if (u.u != nil && get_util_v(u.u) == vv) {
                # Match found!
                l := 0;
                pick ml := u.w { I => l = ml.i; }
                if (tip_gg.length > l) l = tip_gg.length; 
                
                count := 0;
                pick c := u.v { I => count = c.i; }
                
                if (directed) {
                    if (multi || count > 0) {
                       gb->new_arc(new_graph, vv, u, l);
                       
                       if (!multi) u.v = ref Util.I(0); 
                       else u.v = ref Util.I(count - 1); 
                    } 
                } else {
                     # Undirected
                     if (find_vert_idx(new_graph, vv) <= find_vert_idx(new_graph, u)) {
                        if (multi || count > 0) {
                            gb->new_arc(new_graph, vv, u, l);
                            gb->new_arc(new_graph, u, vv, l);
                            if (!multi) u.v = ref Util.I(0);
                            else u.v = ref Util.I(count - 1);
                        }
                     }
                }
            }
        }
        
        for (a = v.arcs; a != nil; a = tl a) {
             tip_idx := find_vert_idx(g, (hd a).tip);
             if (tip_idx >= 0 && tip_idx < n) {
                 u := new_graph.vertices[tip_idx];
                 u.u = nil;
                 u.v = nil;
                 u.w = nil;
             }
        }
    }
    
	return new_graph;
}

lines(g: ref Graph, directed: int): ref Graph
{
	if (g == nil) { print("Missing operand\n"); return nil; }
	
	n_lines := 0;
	if (directed) {
		n_lines = g.m;
	} else {
		for (i := 0; i < g.n; i++) {
			v := g.vertices[i];
			for (a := v.arcs; a != nil; a = tl a) {
				arc := hd a;
				tip_idx := find_vert_idx(g, arc.tip);
				if (i <= tip_idx) n_lines++;
			}
		}
	}

	new_graph := gb->new_graph();
	new_graph.vertices = array[n_lines] of ref Vertex; 
    # new_graph.n is 0 initially. new_vert will fill it.
	new_graph.id = sprint("lines(%s,%d)", g.id, directed);
	
	if (directed) {
		for (i := 0; i < g.n; i++) {
			v := g.vertices[i];
			
			for (a := v.arcs; a != nil; a = tl a) {
				arc := hd a;
				w := arc.tip;
				
				U := gb->new_vert(new_graph);
				U.name = sprint("%s->%s", v.name, w.name);
				
				U.v = ref Util.V(w);
				
				# Link U to v's outgoing list.
                # v.u is ref Util.A(head_arc). head_arc.a points to next Util.
                old_head: ref Arc = nil;
                if (v.u != nil) pick x := v.u { A => old_head = x.a; }
                
                new_head := ref Arc(U, 0, nil, nil);
                if (old_head != nil) new_head.a = ref Util.A(old_head);
                
                v.u = ref Util.A(new_head);
			}
		}
	} else {
		for (i := 0; i < g.n; i++) {
			v := g.vertices[i];
			for (a := v.arcs; a != nil; a = tl a) {
				arc := hd a;
				w := arc.tip;
				w_idx := find_vert_idx(g, w);
				
				if (i <= w_idx) {
					U := gb->new_vert(new_graph);
					U.name = sprint("%s--%s", v.name, w.name);
					
					# Add U to v.u
                    old_head_v: ref Arc = nil;
                    if (v.u != nil) pick x := v.u { A => old_head_v = x.a; }
                    new_head_v := ref Arc(U, 0, nil, nil);
                    if (old_head_v != nil) new_head_v.a = ref Util.A(old_head_v);
                    v.u = ref Util.A(new_head_v);

					if (i != w_idx) {
                        # Add U to w.u
                        old_head_w: ref Arc = nil;
                        if (w.u != nil) pick x := w.u { A => old_head_w = x.a; }
                        new_head_w := ref Arc(U, 0, nil, nil);
                        if (old_head_w != nil) new_head_w.a = ref Util.A(old_head_w);
                        w.u = ref Util.A(new_head_w);
					}
				}
			}
		}
	}
	
	if (directed) {
		for (k := 0; k < n_lines; k++) {
			U := new_graph.vertices[k];
			w: ref Vertex;
			if (U.v != nil) pick x := U.v { V => w = x.v; }
			
			if (w != nil && w.u != nil) {
				pick x := w.u {
					A =>
                        curr := x.a;
						while (curr != nil) {
							NextU := curr.tip;
							gb->new_arc(new_graph, U, NextU, 1);
                            
                            if (curr.a != nil) pick y := curr.a { A => curr = y.a; * => curr = nil; }
                            else curr = nil;
						}
				}
			}
		}
	} else {
		for (i := 0; i < g.n; i++) {
			v := g.vertices[i];
			if (v.u != nil) {
				pick x := v.u {
					A =>
                        # List of Us incident to v
                        l: list of ref Vertex;
                        curr := x.a;
                        while (curr != nil) {
                            l = curr.tip :: l;
                            if (curr.a != nil) pick y := curr.a { A => curr = y.a; * => curr = nil; }
                            else curr = nil;
                        }
                        
						for (n1 := l; n1 != nil; n1 = tl n1) {
							U1 := hd n1;
							for (n2 := tl n1; n2 != nil; n2 = tl n2) {
								U2 := hd n2;
                                # new_edge
								gb->new_arc(new_graph, U1, U2, 1);
                                gb->new_arc(new_graph, U2, U1, 1);
							}
						}
				}
			}
		}
	}
	
	for (i := 0; i < g.n; i++) {
		g.vertices[i].u = nil;
	}
	for (k := 0; k < n_lines; k++) {
		new_graph.vertices[k].v = nil;
	}

	return new_graph; 
}

product(g, gg: ref Graph, type_c, directed: int): ref Graph
{
	if (g == nil || gg == nil) { print("Missing operand\n"); return nil; }
	n := g.n * gg.n;
	
	new_graph := gb->new_graph();
	new_graph.vertices = array[n] of ref Vertex;
	
    t_str := "cartesian";
    if (type_c == 1) t_str = "direct";
    else if (type_c == 2) t_str = "strong";
	new_graph.id = sprint("product(%s,%s,%s,%d)", g.id, gg.id, t_str, directed);

	# Create Vertices
	for (i := 0; i < g.n; i++) {
		v := g.vertices[i];
		for (j := 0; j < gg.n; j++) {
			vv := gg.vertices[j];
			u := gb->new_vert(new_graph);
			u.name = sprint("%s,%s", v.name, vv.name);
		}
	}
	
    for (i = 0; i < g.n; i++) {
        v := g.vertices[i];
        for (j := 0; j < gg.n; j++) {
             vv := gg.vertices[j];
             u_idx := i * gg.n + j;
             u := new_graph.vertices[u_idx];
             
             if (type_c == 0 || type_c == 2) {
                 # v=x, neighbors of vv in gg
                 for (a := vv.arcs; a != nil; a = tl a) {
                     xx := (hd a).tip;
                     len_a := (hd a).length;
                     
                     xx_idx := find_vert_idx(gg, xx);
                     if (!directed && xx_idx < j) continue;
                     
                     nei_idx := i * gg.n + xx_idx;
                     nei := new_graph.vertices[nei_idx];
                     
                     gb->new_arc(new_graph, u, nei, len_a);
                     if (!directed) gb->new_arc(new_graph, nei, u, len_a);
                 }
                 
                 # v~x, neighbors of v in g
                 for (a_second := v.arcs; a_second != nil; a_second = tl a_second) {
                     x := (hd a_second).tip;
                     len_a := (hd a_second).length;
                     
                     x_idx := find_vert_idx(g, x);
                     if (!directed && x_idx < i) continue;
                     
                     nei_idx := x_idx * gg.n + j;
                     nei := new_graph.vertices[nei_idx];
                     
                     gb->new_arc(new_graph, u, nei, len_a);
                     if (!directed) gb->new_arc(new_graph, nei, u, len_a);
                 }
             }
             
             if (type_c == 1 || type_c == 2) {
                 for (a1 := v.arcs; a1 != nil; a1 = tl a1) {
                     x := (hd a1).tip;
                     len_a1 := (hd a1).length;
                     x_idx := find_vert_idx(g, x);
                     
                     for (a2 := vv.arcs; a2 != nil; a2 = tl a2) {
                         xx := (hd a2).tip;
                         len_a2 := (hd a2).length;
                         xx_idx := find_vert_idx(gg, xx);
                         
                         nei_idx := x_idx * gg.n + xx_idx;
                         nei := new_graph.vertices[nei_idx];
                         
                         if (!directed) {
                             if (u_idx >= nei_idx) continue;
                         }
                         
                         l := len_a1;
                         if (len_a2 < l) l = len_a2; 
                         
                         gb->new_arc(new_graph, u, nei, l);
                         if (!directed) gb->new_arc(new_graph, nei, u, l);
                     }
                 }
             }
        }
    }

	return new_graph;
}

induced(g: ref Graph, desc: string, self_loop, multi, directed: int): ref Graph
{
	if (g == nil) { print("Missing operand\n"); return nil; }
	
	# Determine n (total vertices)
	n := 0;
	nn := 0; 
    
    IND_GRAPH: con 1000000; # Threshold for substitution? SGB uses constant.
    
	for (i := 0; i < g.n; i++) {
		v := g.vertices[i];
        ind := 0;
        if (v.z != nil) pick z := v.z { I => ind = z.i; }
        
        if (ind > 0) {
            if (ind >= IND_GRAPH) {
                 # Substitution
                 subst: ref Graph = nil;
                 if (v.y != nil) pick y := v.y { G => subst = y.g; }
                 if (subst == nil) { print("Missing substitution graph\n"); return nil; }
                 n += subst.n;
            } else {
                 n += ind;
            }
        } else if (ind < -nn) {
            nn = -ind;
        }
	}
    n += nn;
    
	new_graph := gb->new_graph();
	new_graph.vertices = array[n] of ref Vertex; 
    # new_graph.n will be filled by new_vert calls or manual loop?
    # SGB: new_graph->n = n.
    # We can pre-allocate and set n=0, then call new_vert n times?
    # No, we need random access to new_graph vertices to set up mapping.
    # So we should create them sequentially.
    
    if (desc == nil) desc = "";
    new_graph.id = sprint("induced(%s,%s,%d,%d,%d)", g.id, desc, self_loop, multi, directed);
    
    # Assign names and create map
    # Negative vertices first? SGB lines 2307.
    # We need to fill new_graph.vertices.
    
    # We can use a loop to call new_vert n times first.
    for (k := 0; k < n; k++) {
        gb->new_vert(new_graph);
    }
    
    u_idx := 0;
    
    # Negative vertices
    for (k = 1; k <= nn; k++) {
        u := new_graph.vertices[u_idx];
        u.v = ref Util.I(-k); # mult field
        u.name = string(-k);
        u_idx++;
    }
    
    for (i = 0; i < g.n; i++) {
        v := g.vertices[i];
        ind := 0;
        if (v.z != nil) pick z := v.z { I => ind = z.i; }
        
        if (ind < 0) {
            # Point to negative vertex
            # v->map = (new_graph->vertices) - (k+1) ??
            # SGB pointer arithmetic.
            # v.map needs to point to the negative vertex.
            # index of neg vertex -ind is (-ind)-1.
            # v.map (using v.z for temporary map?)
            # SGB uses v->map which is z.V.
            # But ind is z.I. Overwriting z?
            # SGB: "store original ind field in mult field of first corresponding vertex ... and change ind to point to that vertex"
            # In Limbo, we can use v.x for map? SGB uses v->map (z.V).
            # But v.z is used for `ind`.
            # If we overwrite v.z with map, we lose ind.
            # SGB stores `ind` into `u->mult`.
            # We can do that.
            
            neg_idx := (-ind) - 1;
            v.u = ref Util.V(new_graph.vertices[neg_idx]); # Using u for map (tmp is u, map is z in SGB, but we used u in other funcs)
            # SGB uses map=z.V.
        } else if (ind > 0) {
             start_u := new_graph.vertices[u_idx];
             start_u.v = ref Util.I(ind); # Store original ind in first clone's mult (u.v)
             
             v.u = ref Util.V(start_u); # Map v to first clone
             
             if (ind <= 2) {
                 start_u.name = v.name;
                 u_idx++;
                 if (ind == 2) {
                     next_u := new_graph.vertices[u_idx];
                     next_u.name = sprint("%s'", v.name);
                     u_idx++;
                 }
             } else if (ind >= IND_GRAPH) {
                  # Subst
                  subst: ref Graph = nil;
                  if (v.y != nil) pick y := v.y { G => subst = y.g; }
                  for (j := 0; j < subst.n; j++) {
                      uu := new_graph.vertices[u_idx++];
                      uu.name = sprint("%s:%s", v.name, subst.vertices[j].name);
                  }
             } else {
                  for (j := 0; j < ind; j++) {
                      uu := new_graph.vertices[u_idx++];
                      uu.name = sprint("%s:%d", v.name, j);
                  }
             }
        }
    }
    
    # Insert Arcs
    for (i = 0; i < g.n; i++) {
        v := g.vertices[i];
        
        # u = v->map
        if (v.u == nil) continue;
        u_start: ref Vertex;
        pick map_u := v.u { V => u_start = map_u.v; }
        if (u_start == nil) continue; 
        
        k = 0;
        if (u_start.v != nil) pick m := u_start.v { I => k = m.i; }
        
        # If k < 0, k = 1 (negative vertex logic logic logic)
        # SGB: if k<0 k=1.
        if (k < 0) k = 1;
        else if (k >= IND_GRAPH) {
             subst: ref Graph = nil;
             if (v.y != nil) pick y := v.y { G => subst = y.g; }
             k = subst.n;
        }
        
        # Iterate u from u_start to u_start+k
        u_curr_idx := find_vert_idx(new_graph, u_start);
        
        for (off := 0; off < k; off++) {
             u := new_graph.vertices[u_curr_idx + off];
             
             # Take note of existing edges if !multi
             if (!multi) {
                 # SGB: use tmp/tlen on u->arcs?
                 # For simplicity, we skip the optimization for now or implement simply.
             }
             
             for (a := v.arcs; a != nil; a = tl a) {
                 vv := (hd a).tip;
                 
                 # uu = vv->map
                 if (vv.u == nil) continue;
                 uu_start: ref Vertex;
                 pick map_uu := vv.u { V => uu_start = map_uu.v; }
                 
                 j := 0;
                 if (uu_start.v != nil) pick m := uu_start.v { I => j = m.i; }
                 
                 if (j < 0) j = 1;
                 else if (j >= IND_GRAPH) {
                      subst: ref Graph = nil;
                      if (vv.y != nil) pick y := vv.y { G => subst = y.g; }
                      j = subst.n;
                 }
                 
                 if (!directed) {
                     if (find_vert_idx(g, vv) < i) continue;
                     if (vv == v) {
                          # Self loop logic
                          # skip second half
                          # For Limbo arcs, we process all arcs. If g is undirected, v->v is 2 arcs?
                          # We check if a->next == a+1 (SGB).
                          # Here we assume standard.
                          
                          # But if vv==v, we set j=k, uu=u.
                          j = k; 
                          uu_start = u_start; # Points to same block
                     }
                 }
                 
                 uu_curr_idx := find_vert_idx(new_graph, uu_start);
                 
                 # Insert arcs from u to uu..uu+j
                 for (off2 := 0; off2 < j; off2++) {
                      uu := new_graph.vertices[uu_curr_idx + off2];
                      
                      if (u == uu && !self_loop) continue;
                      
                      # Check subst connection logic
                      # SGB 2406: "if v and vv are substituted graphs..."
                      # Not implementing complex subst-subst logic yet.
                      
                      if (directed) gb->new_arc(new_graph, u, uu, 1);
                      else {
                           # Undirected: check u <= uu
                           if (find_vert_idx(new_graph, u) <= find_vert_idx(new_graph, uu)) {
                               gb->new_arc(new_graph, u, uu, 1);
                               gb->new_arc(new_graph, uu, u, 1);
                           }
                      }
                 }
             }
        }
    }
    
    # Restore g?
    # SGB restores g->ind from map->mult.
    # We used v.u for map, and u.v for mult.
    # We should clear v.u. And preserve v.z?
    # SGB overwrote z.I with z.V. We used v.u. So v.z is safe?
    # Yes, we didn't touch v.z. So no need to restore ind.
    # Just clear v.u.
    
    for (i = 0; i < g.n; i++) {
        g.vertices[i].u = nil;
    }
    
    return new_graph;
}
