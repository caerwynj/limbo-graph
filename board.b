implement Command;
include "cmd.m";

MAX_D: con 91;

nn := array[MAX_D+1] of int;
wr := array[MAX_D+1] of int;
del := array[MAX_D+1] of int;
sig := array[MAX_D+2] of int;
xx := array[MAX_D+1] of int;
yy := array[MAX_D+1] of int;


main(argv: list of string)
{
	i,j,k,d: int;
	print("board\n");
	g := new_graph();

	piece := 1;
	n1 := 8;
	n2 := 8;
	n3 := 0;

	nn[1] = n1;
	nn[2] = n2;
	nn[3] = n3;
	k = 3;
	d = k - 1;
	nn[0] = xx[0] = xx[1] = xx[2] = xx[3] = 0;
	for (k = 4; k <= d; k++) xx[k] = 0;
	while((v := new_vert(g)) != nil) {	
		s := "";
		for (k = 1; k <= d; k++) {
			t := sprint(".%d", xx[k]);
			s += t;
		}
		v.name = s[1:];
		print("%s\n",v.name);
		for (k = d; (xx[k] + 1) == nn[k]; k--) xx[k] = 0;
		if (k == 0)
			break;
		xx[k]++;
	}
}
