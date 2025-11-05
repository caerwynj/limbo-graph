implement Command;
include "cmd.m";

PriorityQueue: adt {
	head: ref Vertex;
	size: int;		 
};

new: fn(d: int): ref PriorityQueue;
enqueue: fn(q: ref PriorityQueue, v: ref Vertex, d: int);
requeue: fn(q: ref PriorityQueue, v: ref Vertex, d: int);
extract_min: fn(q: ref PriorityQueue): ref Vertex;

new(d: int): ref PriorityQueue
{
	head := ref Vertex(nil, nil, nil, nil, nil, nil, nil, nil);
	set_rlink(head, head);
	set_llink(head, head);
	return ref PriorityQueue(head, 0);
}

# Util fields of a Vertex
# v = llink
# w = rlink
# y = backlink
# z = dist
get_dist(v:ref Vertex): int
{ pick c:=v.z {I=>return c.i; * =>return 0;}}
set_dist(v:ref Vertex, d: int)
{ v.z = ref Util.I(d); }
get_llink(v:ref Vertex): ref Vertex
{ pick c:=v.v {V=>return c.v; * =>return nil;}}
get_rlink(v:ref Vertex): ref Vertex
{ pick c:=v.w {V=>return c.v; * =>return nil;}}
get_backlink(v: ref Vertex): ref Vertex
{ pick c:=v.y {V=>return c.v; * =>return nil;}}
set_llink(v: ref Vertex, w: ref Vertex)
{ v.v = ref Util.V(w);}
set_rlink(v: ref Vertex, w: ref Vertex)
{ v.w = ref Util.V(w);}
set_backlink(v: ref Vertex, w: ref Vertex)
{ v.y = ref Util.V(w);}

enqueue(q: ref PriorityQueue, v: ref Vertex, d: int)
{
	t: ref Vertex;
	t = get_llink(q.head);
	set_dist(v, d);
	while (d < get_dist(t)) 
		t = get_llink(t);
	set_llink(v,t);
	set_rlink(v, get_rlink(t));	
	set_llink(get_rlink(t), v);
	set_rlink(t, v);
	q.size++;
}

requeue(q: ref PriorityQueue, v: ref Vertex, d: int)
{
	t: ref Vertex;
	t = get_llink(v);
	set_rlink(t,  get_rlink(v));
	set_llink(get_rlink(v), get_llink(v));  # remove v
	set_dist(v, d);
	# asssume new priority is smaller than before
	while (d < get_dist(t))
		t = get_llink(t);
	set_llink(v,t);
	set_rlink(v, get_rlink(t));
	set_llink(get_rlink(t), v);
	set_rlink(t, v);
}

extract_min(q: ref PriorityQueue): ref Vertex
{
	t: ref Vertex;
	t = get_rlink(q.head);
	if (t == q.head)
		return nil;
	set_rlink(q.head, get_rlink(t));
	set_llink(get_rlink(t), q.head);
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
	q := new(0);
	set_dist(uu, 0);
	t := uu;
	while (t != vv) {
		d := get_dist(t);	
		for(l := t.arcs; l != nil; l = tl l) {
			a := hd l;
			v := a.tip;
			backlink := get_backlink(v);
			dist := get_dist(v);
			if(backlink != nil) {
				dd := d + a.length;
				if(dd < dist) {
					set_backlink(v, t);
					requeue(q, v, dd);
				}
			} else {
				set_backlink(v, t);
				enqueue(q, v, d + a.length);
			}	
		}
		t = extract_min(q);
		if (t == nil)
			return -1;
	}
	return get_dist(vv);
}
