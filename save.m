Save: module
{
	PATH:	con	"/dis/lib/save.dis";

	save_graph: fn(g: ref Graphbase->Graph, f: string): int;
	restore_graph: fn(f: string): ref Graphbase->Graph;
	init:	fn(sys_mod: Sys, io_mod: GraphIO, gb_mod: Graphbase, bufio_mod: Bufio);
};
