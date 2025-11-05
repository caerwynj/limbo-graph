implement Graphbase;
include "graph.m";

HASH_MULT: con 314159;
HASH_PRIME: con 516595003;

hash_table : array of list of ref Vertex;

hash(s: string): int
{
	h, i: int = 0;
	for (h=0; i < len s; i++) {
		h += (h^(h>>1))+HASH_MULT*s[i];
		while (h>=HASH_PRIME) h-=HASH_PRIME;
	}
	return h;
}

hash_in(v: ref Vertex)
{
	h := hash(v.name) % len hash_table;
	hash_table[h] = v :: hash_table[h];
}

hash_out(s: string): ref Vertex
{
	h := hash(s);
	u := hash_table[h % len hash_table];
	for (; u != nil; u = tl u) {
		if ((hd u).name == s) return hd u;
	}
	return nil;
}

hash_setup(g: ref Graph)
{
	hash_table = array[g.n] of list of ref Vertex;
	for(i := 0; i < g.n; i++)
		hash_in(g.vertices[i]);
}

new_graph(): ref Graph
{
	g := ref Graph(nil,0,0,nil,nil,nil,nil,nil,nil);
	g.vertices = array[256] of ref Vertex;
	return g;
}

new_vert(g: ref Graph): ref Vertex
{
	v := ref Vertex(nil, nil, nil, nil, nil,nil,nil,nil);
	if (g.n >= len g.vertices) {
		a := array[len g.vertices * 2] of ref Vertex;
		a[0:] = g.vertices;
		g.vertices = a;
	}
	g.vertices[g.n] = v;
	g.n++;
	return v;
}

new_arc(g: ref Graph, u, v: ref Vertex, length: int)
{
	a := Arc(v, length, nil, nil);
	u.arcs = a :: u.arcs;
	g.m++;
}

