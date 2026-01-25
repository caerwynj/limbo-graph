implement Command;
include "cmd.m";

MAX_D: con 91;

nn := array[MAX_D+1] of int;
wr := array[MAX_D+1] of int;
del := array[MAX_D+1] of int;
sig := array[MAX_D+2] of int;
xx := array[MAX_D+1] of int;
yy := array[MAX_D+1] of int;

g: ref Graph;
d: int;

main(argv: list of string)
{
	i, j, k, n, p, l: int;
	n1, n2, n3, n4: int;
	piece, wrap, directed: int;

	# Default parameters for an 8x8 board with wazir (rook+king) moves
	n1 = 8;
	n2 = 8;
	n3 = 0;
	n4 = 0;
	piece = 1;  # wazir moves (distance 1)
	wrap = 0;   # no wraparound
	directed = 0;  # undirected graph

	# Parse command line arguments if provided
	# board n1 n2 n3 n4 piece wrap directed
	if (argv != nil) {
		argv = tl argv;  # skip program name
		if (argv != nil) { n1 = int hd argv; argv = tl argv; }
		if (argv != nil) { n2 = int hd argv; argv = tl argv; }
		if (argv != nil) { n3 = int hd argv; argv = tl argv; }
		if (argv != nil) { n4 = int hd argv; argv = tl argv; }
		if (argv != nil) { piece = int hd argv; argv = tl argv; }
		if (argv != nil) { wrap = int hd argv; argv = tl argv; }
		if (argv != nil) { directed = int hd argv; argv = tl argv; }
	}

	# Normalize piece parameter
	if (piece == 0) piece = 1;

	# Normalize board size parameters
	if (n1 <= 0) {
		n1 = 8;
		n2 = 8;
		n3 = 0;
	}

	nn[1] = n1;
	if (n2 <= 0) {
		k = 2;
		d = -n2;
		n3 = 0;
		n4 = 0;
	} else {
		nn[2] = n2;
		if (n3 <= 0) {
			k = 3;
			d = -n3;
			n4 = 0;
		} else {
			nn[3] = n3;
			if (n4 <= 0) {
				k = 4;
				d = -n4;
			} else {
				nn[4] = n4;
				d = 4;
			}
		}
	}

	# Compute component sizes periodically if needed
	if (d == 0) {
		d = k - 1;
	} else {
		# Replicate sizes periodically
		j = 1;
		while (k <= d) {
			nn[k] = nn[j];
			j++;
			k++;
		}
	}

	# Calculate total number of vertices
	n = 1;
	for (j = 1; j <= d; j++)
		n *= nn[j];

	print("Creating board graph: %d dimensions, %d vertices\n", d, n);

	# Create the graph
	g = new_graph();

	# Create all vertices and assign names
	nn[0] = xx[0] = xx[1] = xx[2] = xx[3] = 0;
	for (k = 4; k <= d; k++) xx[k] = 0;

	for (i = 0; i < n; i++) {
		v := new_vert(g);
		if (v == nil) {
			print("Error: failed to create vertex %d\n", i);
			break;
		}

		# Build vertex name from coordinates
		s := "";
		for (k = 1; k <= d; k++) {
			t := sprint(".%d", xx[k]);
			s += t;
		}
		v.name = s[1:];  # skip leading '.'

		# Advance to next coordinate
		for (k = d; xx[k] + 1 == nn[k]; k--) xx[k] = 0;
		if (k > 0) xx[k]++;
	}

	print("Created %d vertices\n", g.n);

	# Initialize wrap, sig, and del tables
	{
		w := wrap;
		for (k = 1; k <= d; k++) {
			wr[k] = w & 1;
			w >>= 1;
			del[k] = sig[k] = 0;
		}
		sig[0] = del[0] = sig[d+1] = 0;
	}

	# Generate all legal moves
	p = piece;
	if (p < 0) p = -p;

	# Iterate through all delta vectors
	while (advance_delta(p)) {
		while (1) {
			generate_moves(piece, directed);
			if (!advance_signs())
				break;
		}
	}

	print("Created board graph with %d vertices and %d arcs\n", g.n, g.m);
}

# Advance to next nonnegative delta vector
# Returns 1 if successful, 0 if done
advance_delta(p: int): int
{
	k: int;

	# Find rightmost position where we can increment
	for (k = d; sig[k] + (del[k]+1)*(del[k]+1) > p; k--)
		del[k] = 0;

	if (k == 0)
		return 0;

	del[k]++;
	sig[k+1] = sig[k] + del[k]*del[k];
	for (k++; k <= d; k++)
		sig[k+1] = sig[k];

	if (sig[d+1] < p)
		return advance_delta(p);  # recurse to find valid configuration

	return 1;
}

# Advance to next signed delta vector
# Returns 1 if successful, 0 if we should restore to nonnegative and stop
advance_signs(): int
{
	k: int;

	for (k = d; del[k] <= 0; k--)
		del[k] = -del[k];

	if (sig[k] == 0)
		return 0;  # all but del[k] were negative or zero

	del[k] = -del[k];
	return 1;
}

# Generate moves for current delta vector
generate_moves(piece: int, directed: int)
{
	k, i, l, j: int;
	v: ref Vertex;
	u: ref Vertex;

	# Initialize xx to (0,0,...,0)
	for (k = 1; k <= d; k++) xx[k] = 0;

	# Iterate through all vertices
	for (i = 0; i < g.n; i++) {
		v = g.vertices[i];

		# Generate moves from v corresponding to del
		for (k = 1; k <= d; k++)
			yy[k] = xx[k] + del[k];

		for (l = 1; ; l++) {
			# Correct for wraparound or skip if off board
			ok := 1;
			for (k = 1; k <= d; k++) {
				if (yy[k] < 0) {
					if (wr[k] == 0) {
						ok = 0;
						break;
					}
					while (yy[k] < 0)
						yy[k] += nn[k];
				} else if (yy[k] >= nn[k]) {
					if (wr[k] == 0) {
						ok = 0;
						break;
					}
					while (yy[k] >= nn[k])
						yy[k] -= nn[k];
				}
			}

			if (!ok)
				break;

			# Check for self-loop when piece < 0
			if (piece < 0) {
				same := 1;
				for (k = 1; k <= d; k++) {
					if (yy[k] != xx[k]) {
						same = 0;
						break;
					}
				}
				if (same)
					break;
			}

			# Record legal move from xx to yy
			# Calculate linear index of destination vertex
			j = yy[1];
			for (k = 2; k <= d; k++)
				j = nn[k] * j + yy[k];

			u = g.vertices[j];

			if (directed)
				new_arc(g, v, u, l);
			else
				new_arc(g, v, u, l);  # For undirected, we create both directions

			if (piece > 0)
				break;

			# Continue in same direction for piece < 0
			for (k = 1; k <= d; k++)
				yy[k] += del[k];
		}

		# Advance to next vertex coordinate
		for (k = d; xx[k] + 1 == nn[k]; k--) xx[k] = 0;
		if (k > 0) xx[k]++;
	}
}
