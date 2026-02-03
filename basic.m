Basic: module
{
	PATH:	con	"/dis/lib/basic.dis";

	board: fn(n0, n1, n2, n3: int, n4: int, p: int, wrap: int): ref Graphbase->Graph;
	gunion: fn(g, gg: ref Graphbase->Graph, multi, directed: int): ref Graphbase->Graph;
    
    complete: fn(n: int): ref Graphbase->Graph;
    transitive: fn(n: int): ref Graphbase->Graph;
    empty: fn(n: int): ref Graphbase->Graph;
    circuit: fn(n: int): ref Graphbase->Graph;
    cycle: fn(n: int): ref Graphbase->Graph;

    complement: fn(g: ref Graphbase->Graph, copy, self_loop, directed: int): ref Graphbase->Graph;

    intersection: fn(g, gg: ref Graphbase->Graph, multi, directed: int): ref Graphbase->Graph;
    lines: fn(g: ref Graphbase->Graph, directed: int): ref Graphbase->Graph;
    product: fn(g, gg: ref Graphbase->Graph, type_c, directed: int): ref Graphbase->Graph;
    induced: fn(g: ref Graphbase->Graph, desc: string, self_loop, multi, directed: int): ref Graphbase->Graph;

};
