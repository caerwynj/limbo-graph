Basic: module
{
	PATH:	con	"/dis/lib/basic.dis";

	board: fn(n0, n1, n2, n3: int, n4: int, p: int, wrap: int): ref Graphbase->Graph;
	gunion: fn(g, gg: ref Graphbase->Graph, multi, directed: int): ref Graphbase->Graph;

};
