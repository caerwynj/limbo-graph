implement Command;
include "cmd.m";

BookNode: adt {
	key, code, in, out, chap: int;
	vert: ref Vertex;	
};

MAX_CODE: 	con 36*36;
MAX_CHARS: 	con 600;
MAX_CHAPS:	con 360;

nodes : list of ref BookNode;
xnode := array[MAX_CODE] of ref BookNode;

main(nil: list of string)
{
	gb = load Graphbase Graphbase->PATH;
	gg := bi_book("anna.dat", 0, 0, 0, 0, 0, 0, 0);
	gb->hash_setup(gg);
	v := gb->hash_out("AA");
	for (l := v.arcs; l != nil; l = tl l) {
		print("%s %s\n", v.name, (hd l).tip.name);
	}	
}

ch2code(ch: string): int
{
	code := 0;
	for(i := 0; i < len ch; i++) {
		c := ch[i];
		r := 36 ** (len ch - i - 1);
		if (c >= '0' && c <= '9') 
			code += (c - '0') * r;
		else if (c >= 'A' && c <= 'Z') 
			code += (c - 'A' + 10) * r;
	}
	return code;	
}

# produce a bipartite graph of characters to book chapters
bi_book(name: string, n, x, first_chap, last_chap, in_weight, out_weight, seed: int): ref Graph
{
	chapters := MAX_CHAPS;
	if(first_chap == 0)
		first_chap = 1;
	if(last_chap == 0)
		last_chap = MAX_CHAPS;
	fd := bufio->open(name, Bufio->OREAD);
	if(fd == nil) {
		print("error,can't open %s\n",name);
		return nil;
	}

	g := gb->new_graph();
	# skip first 4 lines
	for(i:=0;i<4;i++)
		fd.gets('\n');
	# get vertices
	while((line := fd.gets('\n')) != nil) {
		if(line == "\n")
			break;
		ch := line[0:2];
		code := ch2code(ch);
		line = line[3:];	
		(a, b) := splitl(line, ",");
	#	print("%s: %s = %d\n", a, ch, code);
		v := gb->new_vert(g);
		v.name = ch;
		bn := ref BookNode(0, code, 0, 0, 0, v);
		xnode[code] = bn;
		nodes = bn :: nodes;
	}
	# get edges; first pass
	k := 1;
	chap_base := g.n;
	while((line = fd.gets('\n')) != nil) {
		if (line[0] == '*')
			break;
		chapter, rest: string;
		(chapter, rest) = splitl(line, ":\n");
		rest = rest[1:];
		v := gb->new_vert(g);
		v.name = chapter;
		(n, cliques) := tokenize(rest, ",;\n");
		for(l := cliques; l != nil; l = tl l) {
		#	print("ch %s, %s\n",chapter, hd l);
			code := ch2code(hd l);
			p := xnode[code];
			if (p == nil) raise "xnode";
			if(p.chap != k) {
				p.chap = k;
				gb->new_arc(g, p.vert, v, 1);
			}
			if(k >= first_chap && k <= last_chap)
				p.in++;
			else
				p.out++;
		}
		k++;
	}
	g.uu = ref Util.I(g.n); # utility field to denote the size of bipartite first part
	chapters = k-1;

	return g;
}

