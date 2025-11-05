Graphbase: module
{
	PATH:	con	"graph.dis";
	Graph: adt {
		vertices: array of ref Vertex;
		n: int;
		m: int;
		id: string;
		uu, ww, xx, yy, zz: ref Util;
	};

	Arc: adt {
		tip: ref Vertex;
		length: int;
		a, b: ref Util;
	}; 

	Util: adt {
		pick {
			V => v: ref Vertex;
			A => a: ref Arc;
			G => g: ref Graph;
			S => s: string;
			I => i: int;
		}
	};

	Vertex: adt {
		name: string;
		arcs: list of Arc;

		u,v,w,x,y,z: ref Util;
	};

	new_graph:	fn(): ref Graph;
	new_vert:	fn(g: ref Graph): ref Vertex;
	new_arc:	fn(g: ref Graph, u, v: ref Vertex, length: int);
	hash_setup:	fn(g: ref Graph);
	hash_in:	fn(v: ref Vertex);
	hash_out:	fn(s: string): ref Vertex;

};
