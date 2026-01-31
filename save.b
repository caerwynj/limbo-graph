implement Save;

include "sys.m";
	sys: Sys;
	print, sprint: import sys;
include "string.m";
	str: String;
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "io.m";
	io: GraphIO;
include "graph.m";
	gb: Graphbase;
	Graph, Vertex, Arc, Util: import gb;
include "save.m";

init(sys_mod: Sys, io_mod: GraphIO, gb_mod: Graphbase, bufio_mod: Bufio)
{
	sys = sys_mod;
	io = io_mod;
	gb = gb_mod;
	bufio = bufio_mod;
	str = load String String->PATH;
	io->init(sys, bufio); 
}

# restore_graph implementation
restore_graph(f: string): ref Graph
{
	if (io == nil) { print("IO nil\n"); return nil; }
	
	g: ref Graph;

	io->gb_raw_close();
	if (io->gb_raw_open(f) != 0) { print("gb_raw_open failed code %x\n", io->status()); return nil; }
	
	u_types := "";
	n := 0;
	m := 0;
	
	found := 0;
	while (!io->gb_eof()) {
        


		# Check for starting with *
		# io.m doesn't expose buffer. Parse blindly with primitives.
		
		# Reset pos to 0
		io->gb_backup(); io->gb_backup(); 
		
		c := io->gb_char();
		if (c != '*') {
			io->gb_newline();
			continue;
		}
		
		# Check "* GraphBase graph (util_types "
		io->gb_backup(); 
		prefix := "* GraphBase graph (util_types ";
		
		line := io->gb_string(0); # Read line
		
		# Match prefix
		if (len line > len prefix && line[0:len prefix] == prefix) {
            # ... Parsing logic ...
            # Need to capture u_types, n, m
            # Copy paste parsing logic from old code
            remainder := line[len prefix:];
			if (len remainder < 14) { io->gb_newline(); continue; }
			
			u_types = remainder[0:14];
			remainder = remainder[14:];
			
			if (len remainder < 1 || remainder[0] != ',') { io->gb_newline(); continue; }
			remainder = remainder[1:];
			
			(val_n, rem_n) := str->toint(remainder, 10);
			n = val_n;
			if (len rem_n < 1 || rem_n[0] != 'V') { io->gb_newline(); continue; }
			remainder = rem_n[1:];
			
			if (len remainder < 1 || remainder[0] != ',') { io->gb_newline(); continue; }
			remainder = remainder[1:];
			
			(val_m, rem_m) := str->toint(remainder, 10);
			m = val_m;
			if (len rem_m < 2 || rem_m[0] != 'A' || rem_m[1] != ')') { io->gb_newline(); continue; }
			
			found = 1;
			break;
		}
		io->gb_newline();
	}
	
	if (!found) {
		print("Header not found\n");
		io->gb_raw_close();
		return nil;
	}

	
	g = gb->new_graph();
	g.util_types = u_types;
	g.vertices = array[n] of ref Vertex;
	for (i := 0; i < n; i++) g.vertices[i] = gb->new_vert(g);
	g.util_types = u_types;

	io->gb_newline();

	c := io->gb_char();

	if (c != '"') { io->gb_raw_close(); return nil; }
	io->gb_backup();
	g.id = parse_string();
	
	expect_comma(); io->gb_number(10);
	expect_comma(); io->gb_number(10);
	g.n = n;
	g.m = m;
	
	g.uu = fillin_ret(u_types[8], g, nil);
	g.vv = fillin_ret(u_types[9], g, nil);
	g.ww = fillin_ret(u_types[10], g, nil);
	g.xx = fillin_ret(u_types[11], g, nil);
	g.yy = fillin_ret(u_types[12], g, nil);
	g.zz = fillin_ret(u_types[13], g, nil);
	io->gb_newline();
	
	io->gb_newline(); # * Vertices
	
	all_arcs := array[m] of ref Arc;
	for (k := 0; k < m; k++) {
		all_arcs[k] = ref Arc;
		all_arcs[k].tip = nil;
	}
	next_arc_indices := array[m] of int;
	vertex_arc_heads := array[n] of int;
	
	for (i = 0; i < n; i++) {
		io->gb_newline();
		v := g.vertices[i];
		c = io->gb_char(); io->gb_backup();
		if (c == '"') v.name = parse_string();
		else io->gb_string(',');
		expect_comma();
		vertex_arc_heads[i] = parse_arc_ptr(m);
		expect_comma(); v.u = fillin_ret(u_types[0], g, all_arcs);
		expect_comma(); v.v = fillin_ret(u_types[1], g, all_arcs);
		expect_comma(); v.w = fillin_ret(u_types[2], g, all_arcs);
		expect_comma(); v.x = fillin_ret(u_types[3], g, all_arcs);
		expect_comma(); v.y = fillin_ret(u_types[4], g, all_arcs);
		expect_comma(); v.z = fillin_ret(u_types[5], g, all_arcs);
	}
	
	io->gb_newline(); # * Arcs
	for (k = 0; k < m; k++) {
		io->gb_newline();
		a := all_arcs[k];
		v_idx := parse_vert_ptr(n);
		if (v_idx >= 0 && v_idx < n) a.tip = g.vertices[v_idx];
		expect_comma();
		next_arc_indices[k] = parse_arc_ptr(m);
		expect_comma();
		a.length = int io->gb_number(10);
		expect_comma(); a.a = fillin_ret(u_types[6], g, all_arcs);
		expect_comma(); a.b = fillin_ret(u_types[7], g, all_arcs);
	}
	
	io->gb_newline(); io->gb_raw_close();
	
	for (i = 0; i < n; i++) {
		curr := vertex_arc_heads[i];
		rev_arcs: list of Arc;
		tmp_list: list of Arc;
		while (curr >= 0 && curr < m) {
			tmp_list = *all_arcs[curr] :: tmp_list;
			curr = next_arc_indices[curr];
		}
		for (l := tmp_list; l != nil; l = tl l)
			rev_arcs = hd l :: rev_arcs;
		g.vertices[i].arcs = rev_arcs;
	}
	return g;
}

# Writer ADT
Writer: adt {
	file: ref Iobuf;
	magic: int;
	line_buf: string;
	
	new: fn(f: ref Iobuf): ref Writer;
	flush_line: fn(w: self ref Writer);
	append_str: fn(w: self ref Writer, s: string);
	append_item: fn(w: self ref Writer, s: string, comma: int);
};

Writer.new(f: ref Iobuf): ref Writer
{
	return ref Writer(f, 0, "");
}

Writer.flush_line(w: self ref Writer)
{
	if (len w.line_buf == 0) return;
	w.line_buf += "\n";
	w.magic = io->new_checksum(w.line_buf, w.magic);
	w.file.puts(w.line_buf);
	w.line_buf = "";
}

Writer.append_str(w: self ref Writer, s: string)
{
	if (len w.line_buf + len s > 78) {
		rem := s;
		while (len w.line_buf + len rem > 78) {
			chunk_len := 78 - len w.line_buf;
			if (chunk_len <= 0) {
				# Edge case
				w.line_buf[len w.line_buf] = '\\'; 
				w.flush_line();
			}
			
			if (len w.line_buf < 78) {
				space := 78 - len w.line_buf;
				if (space <= 0) space = 0;
				
				chunk := rem[0:space];
				w.line_buf += chunk;
				w.line_buf += "\\";
				w.flush_line();
				rem = rem[space:];
			}
		}
		w.line_buf += rem;
	} else {
		w.line_buf += s;
	}
}

Writer.append_item(w: self ref Writer, s: string, comma: int)
{
	if (comma) w.append_str(",");
	w.append_str(s);
}

save_graph(g: ref Graphbase->Graph, f: string): int
{
	if (g == nil) return -1;
	
	file := bufio->create(f, Bufio->OWRITE, 8r666);
	if (file == nil) return -2;
	
	w := Writer.new(file);

	# Pass 1: Header
	util_types := g.util_types;
	if (len util_types < 14) util_types = "ZZZIIIIZZZZZZZ"; 
	
	w.append_str(sprint("* GraphBase graph (util_types %s,%dV,%dA)", 
		util_types, g.n, g.m));
	w.flush_line();
	
	w.append_item(fmt_str(g.id), 0);
	w.append_item(sprint("%d", g.n), 1);
	w.append_item(sprint("%d", g.m), 1);
	
	w.append_item(fmt_util(g.uu, util_types[8], g), 1);
	w.append_item(fmt_util(g.vv, util_types[9], g), 1);
	w.append_item(fmt_util(g.ww, util_types[10], g), 1);
	w.append_item(fmt_util(g.xx, util_types[11], g), 1);
	w.append_item(fmt_util(g.yy, util_types[12], g), 1);
	w.append_item(fmt_util(g.zz, util_types[13], g), 1);
	w.flush_line();
	
	# Vertices
	w.append_str("* Vertices"); w.flush_line();
	
	vert_arc_start := array[g.n] of int;
	curr_arc_count := 0;
	for (i := 0; i < g.n; i++) {
		vert_arc_start[i] = curr_arc_count;
		cnt := 0;
		for (l := g.vertices[i].arcs; l != nil; l = tl l) cnt++;
		curr_arc_count += cnt;
	}
	
	for (i = 0; i < g.n; i++) {
		v := g.vertices[i];
		w.append_item(fmt_str(v.name), 0);
		
		start_idx := vert_arc_start[i];
		if (start_idx >= g.m) {
			w.append_item("0", 1); 
		} else {
			if (v.arcs == nil) w.append_item("0", 1);
			else w.append_item(sprint("A%d", start_idx), 1);
		}
		
		w.append_item(fmt_util(v.u, util_types[0], g), 1);
		w.append_item(fmt_util(v.v, util_types[1], g), 1);
		w.append_item(fmt_util(v.w, util_types[2], g), 1);
		w.append_item(fmt_util(v.x, util_types[3], g), 1);
		w.append_item(fmt_util(v.y, util_types[4], g), 1);
		w.append_item(fmt_util(v.z, util_types[5], g), 1);
		w.flush_line();
	}
	
	# Arcs
	w.append_str("* Arcs"); w.flush_line();
	
	curr_idx := 0;
	for (i = 0; i < g.n; i++) {
		v := g.vertices[i];
		for (l := v.arcs; l != nil; l = tl l) {
			a := hd l;
			w.append_item(fmt_ptr_v(a.tip, g), 0);
			
			if (tl l == nil) w.append_item("0", 1);
			else w.append_item(sprint("A%d", curr_idx + 1), 1);
			
			w.append_item(sprint("%d", a.length), 1);
			w.append_item(fmt_util(a.a, util_types[6], g), 1);
			w.append_item(fmt_util(a.b, util_types[7], g), 1);
			w.flush_line();
			
			curr_idx++;
		}
	}
	
	# Checksum
	w.append_str(sprint("* Checksum %d", w.magic));
	w.flush_line();
	
	file.close();
	return 0;
}

fmt_str(s: string): string
{
	res := "\"";
	for (i := 0; i < len s; i++) {
		c := s[i];
		if (c == '"' || c == '\n' || c == '\\') res[len res] = '?'; 
		else res[len res] = c;
	}
	res += "\"";
	return res;
}

fmt_ptr_v(v: ref Vertex, g: ref Graph): string
{
	if (v == nil) return "0";
	idx := find_vert_idx(g, v);
	return sprint("V%d", idx);
}

fmt_ptr_a(a: ref Arc, g: ref Graph): string
{
	if (a == nil) return "0";
	idx := find_arc_idx(g, a);
	return sprint("A%d", idx);
}

fmt_util(u: ref Util, t: int, g: ref Graph): string
{
	case t {
		'I' => 
			val := 0; 
			if (u != nil) pick x := u { I => val = x.i; }
			return sprint("%d", val);
		'S' =>
			s := "";
			if (u != nil) pick x := u { S => s = x.s; }
			return fmt_str(s);
		'V' =>
			v: ref Vertex = nil;
			if (u != nil) pick x := u { V => v = x.v; }
			return fmt_ptr_v(v, g);
		'A' =>
			a: ref Arc = nil;
			if (u != nil) pick x := u { A => a = x.a; }
			return fmt_ptr_a(a, g);
		'Z' => return "";
	}
	return "";
}

find_vert_idx(g: ref Graph, v: ref Vertex): int
{
	for (i := 0; i < g.n; i++)
		if (g.vertices[i] == v) return i;
	return -1;
}

find_arc_idx(g: ref Graph, target: ref Arc): int
{
	idx := 0;
	for (i := 0; i < g.n; i++) {
		for (l := g.vertices[i].arcs; l != nil; l = tl l) {
			a := hd l;
			if (a.tip == target.tip && a.length == target.length && a.a == target.a && a.b == target.b) return idx;
			idx++;
		}
	}
	return -1;
}

# Helpers
fillin_ret(t: int, g: ref Graph, all_arcs: array of ref Arc): ref Util { 
	c := io->gb_char();
	io->gb_backup();
	case t {
		'I' => 
			val := 0;
			if (c == '-') { io->gb_char(); val = -int io->gb_number(10); } 
			else { val = int io->gb_number(10); }
			return ref Util.I(val);
		'S' => return ref Util.S(parse_string());
		'V' =>
			if (c == '0') { io->gb_char(); return nil; }
			if (c == 'V') {
				io->gb_char(); idx := int io->gb_number(10);
				if (idx >= 0 && idx < len g.vertices) return ref Util.V(g.vertices[idx]);
			}
			return nil;
		'A' =>
			if (c == '0') { io->gb_char(); return nil; }
			if (c == 'A') {
				io->gb_char(); idx := int io->gb_number(10);
				if (all_arcs != nil && idx >= 0 && idx < len all_arcs) return ref Util.A(all_arcs[idx]);
			}
			return nil;
	}
	return nil; 
}

parse_string(): string { io->gb_char(); return io->gb_string('"'); }
expect_comma() { if (io->gb_char() != ',') io->gb_backup(); }
parse_vert_ptr(n: int): int { c := io->gb_char(); if (c == 'V') return int io->gb_number(10); return -1; }
parse_arc_ptr(m: int): int { c := io->gb_char(); if (c == 'A') return int io->gb_number(10); return -1; }
