Board: module
{
	PATH:	con	"/dis/lib/board.dis";

	init:	fn(ctxt: ref Draw->Context, argv: list of string);
	board:	fn(n1, n2, n3, n4, piece, wrap, directed: int): ref Graphbase->Graph;
};
