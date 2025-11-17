implement Command;
include "sys.m";
include "draw.m";
sys: Sys;
print: import sys;

Command: module {
	init: fn(ctxt: ref Draw->Context, args: list of string);
};

init(ctxt: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	main(args);
}

Graph: adt {
	vertices: array of ref Vertex;
	n, m: int;
	id: string;
};

Arc: adt {
	tip: ref Vertex;
	length: int;
}; 

Vertex: adt {
	name: string;
	arcs: list of Arc;
	rlink, llink, backlink: ref Vertex;
	dist: int;
};

PriorityQueue: adt {
	head: ref Vertex;
	size: int;		 
};

new_graph(): ref Graph
{
	g := ref Graph(nil,0,0,nil);
	g.vertices = array[256] of ref Vertex;
	return g;
}

new_vert(g: ref Graph): ref Vertex
{
	v := ref Vertex(nil, nil, nil, nil, nil,0);
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
	a := Arc(v, length);
	u.arcs = a :: u.arcs;
	g.m++;
}

new_pq(d: int): ref PriorityQueue
{
	head := ref Vertex(nil, nil, nil, nil, nil, 0);
	head.rlink = head;
	head.llink = head;
	return ref PriorityQueue(head, 0);
}

enqueue(q: ref PriorityQueue, v: ref Vertex, d: int)
{
	t: ref Vertex;
	t = q.head.llink;
	v.dist = d;
	while (d < t.dist) 
		t = t.llink;
	v.llink = t;
	v.rlink = t.rlink;
	t.rlink.llink = v;
	t.rlink = v;
	q.size++;
}

requeue(q: ref PriorityQueue, v: ref Vertex, d: int)
{
	t: ref Vertex;
	t = v.llink;
	t.rlink = v.rlink;
	v.rlink.llink = v.llink;  # remove v
	v.dist = d;
	# asssume new priority is smaller than before
	while (d < t.dist)
		t = t.llink;
	v.llink = t;
	v.rlink = t.rlink;
	t.rlink.llink = v;
	t.rlink = v;
}

extract_min(q: ref PriorityQueue): ref Vertex
{
	t: ref Vertex;
	t = q.head.rlink;
	if (t == q.head)
		return nil;
	q.head.rlink = t.rlink;
	t.rlink.llink = q.head;
	q.size--;
	return t;
}

main(argv: list of string)
{
	g := new_graph();
	u := new_vert(g);
	v := new_vert(g);
	w := new_vert(g);
	x := new_vert(g);
	u.name="vertex 0";
	v.name="vertex 1";
	w.name="vertex 2";
	x.name="vertex 3";	
	new_arc(g,u,v,1);
	new_arc(g,v,w,2);
	new_arc(g,w,x,3);
	new_arc(g,u,x,10);
	
	d := dijkstra(g, u, x);
	print("dijkstra %d\n", d);	
}    

dijkstra(g: ref Graph, uu, vv: ref Vertex): int
{
	q := new_pq(0);
	uu.dist = 0;
	t := uu;
	while (t != vv) {
		d := t.dist;
		for(l := t.arcs; l != nil; l = tl l) {
			a := hd l;
			v := a.tip;
			backlink := v.backlink;
			dist := v.dist;
			if(backlink != nil) {
				dd := d + a.length;
				if(dd < dist) {
					v.backlink = t;
					requeue(q, v, dd);
				}
			} else {
				v.backlink = t;
				enqueue(q, v, d + a.length);
			}	
		}
		t = extract_min(q);
		if (t == nil)
			return -1;
	}
	return vv.dist;
}
