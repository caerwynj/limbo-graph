include "sys.m";
sys: Sys;
print, sprint, tokenize: import sys;
include "draw.m";
include "math.m";
math: Math;
ceil, fabs, floor, Infinity, log10, pow10, pow, sqrt, exp: import math;
dot, gemm, iamax: import math;
include "string.m";
str: String;
tobig, toint, toreal, tolower, toupper, splitl: import str;
include "bufio.m";
bufio: Bufio;
Iobuf: import bufio;
include "graph.m";
gb: Graphbase;
Graph, Arc, Vertex, Util, new_graph, new_vert, new_arc: import gb;

false, true: con iota;
bool: type int;

Command:module
{ 
	init:fn(ctxt: ref Draw->Context, argv: list of string); 
};

init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	str = load String String->PATH;
	bufio = load Bufio Bufio->PATH;
	gb = load Graphbase Graphbase->PATH;
	main(argv);
}
