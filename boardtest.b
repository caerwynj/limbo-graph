implement Command;
include "cmd.m";

# Simplified test runner for board graphs
# Each test creates a board with specific parameters and validates results

main(argv: list of string)
{
	print("\n======================\n");
	print("Board Graph Test Suite\n");
	print("======================\n\n");

	# Test 1: 3x3 Wazir (should have 9 vertices)
	print("Test 1: 3x3 Wazir (orthogonal moves)\n");
	print("Expected: 9 vertices\n");
	print("Corners have degree 2, edges have degree 3, center has degree 4\n");
	test_3x3_wazir();

	# Test 2: 4x4 Knight
	print("\nTest 2: 4x4 Knight moves\n");
	print("Expected: 16 vertices\n");
	test_4x4_knight();

	# Test 3: Linear board (1D)
	print("\nTest 3: 8-vertex linear board\n");
	print("Expected: 8 vertices in a line\n");
	test_linear();

	# Test 4: 3x3 Torus (wraparound)
	print("\nTest 4: 3x3 Torus with wazir\n");
	print("Expected: 9 vertices, all with degree 4\n");
	test_torus();

	# Test 5: Small complete graph
	print("\nTest 5: Complete graph on 4 vertices\n");
	print("Expected: 4 vertices, each with degree 6 (3 neighbors, 2 directions)\n");
	test_complete();

	print("\n=== All tests completed ===\n");
}

test_3x3_wazir()
{
	x, y, vi, ui, d: int;
	corner, edge, center: int;
	v: ref Vertex;

	g := new_graph();

	# Create 3x3 grid
	d = 2;
	nn := array[3] of { * => 0 };
	nn[1] = 3;
	nn[2] = 3;

	# Create vertices
	for (x = 0; x < 3; x++) {
		for (y = 0; y < 3; y++) {
			v = new_vert(g);
			v.name = sprint("%d.%d", x, y);
		}
	}

	# Create edges for wazir (orthogonal) moves
	for (x = 0; x < 3; x++) {
		for (y = 0; y < 3; y++) {
			vi = x * 3 + y;
			v = g.vertices[vi];

			# Right neighbor
			if (x < 2) {
				ui = (x+1) * 3 + y;
				new_arc(g, v, g.vertices[ui], 1);
			}
			# Down neighbor
			if (y < 2) {
				ui = x * 3 + (y+1);
				new_arc(g, v, g.vertices[ui], 1);
			}
			# Left neighbor
			if (x > 0) {
				ui = (x-1) * 3 + y;
				new_arc(g, v, g.vertices[ui], 1);
			}
			# Up neighbor
			if (y > 0) {
				ui = x * 3 + (y-1);
				new_arc(g, v, g.vertices[ui], 1);
			}
		}
	}

	print("Created: %d vertices, %d arcs\n", g.n, g.m);

	# Check degrees
	corner = count_arcs(g.vertices[0]);  # (0,0)
	edge = count_arcs(g.vertices[1]);     # (0,1)
	center = count_arcs(g.vertices[4]);   # (1,1)

	print("Corner degree: %d, Edge degree: %d, Center degree: %d\n",
		corner, edge, center);
}

test_4x4_knight()
{
	x, y, vi, ui, i, dx, dy, nx, ny, corner: int;
	v: ref Vertex;

	g := new_graph();

	# Create 4x4 grid
	for (x = 0; x < 4; x++) {
		for (y = 0; y < 4; y++) {
			v = new_vert(g);
			v.name = sprint("%d.%d", x, y);
		}
	}

	# Knight moves: distance sqrt(5) = (±2,±1) or (±1,±2)
	deltas := array[] of {
		(2, 1), (2, -1), (-2, 1), (-2, -1),
		(1, 2), (1, -2), (-1, 2), (-1, -2)
	};

	for (x = 0; x < 4; x++) {
		for (y = 0; y < 4; y++) {
			vi = x * 4 + y;
			v = g.vertices[vi];

			for (i = 0; i < len deltas; i++) {
				(dx, dy) = deltas[i];
				nx = x + dx;
				ny = y + dy;

				if (nx >= 0 && nx < 4 && ny >= 0 && ny < 4) {
					ui = nx * 4 + ny;
					new_arc(g, v, g.vertices[ui], 1);
				}
			}
		}
	}

	print("Created: %d vertices, %d arcs\n", g.n, g.m);

	# Corner knights have fewer moves
	corner = count_arcs(g.vertices[0]);
	print("Corner knight degree: %d\n", corner);
}

test_linear()
{
	i, endpoint, middle: int;
	v: ref Vertex;

	g := new_graph();

	# Create 8 vertices in a line
	for (i = 0; i < 8; i++) {
		v = new_vert(g);
		v.name = sprint("%d", i);
	}

	# Connect neighbors
	for (i = 0; i < 7; i++) {
		new_arc(g, g.vertices[i], g.vertices[i+1], 1);
		new_arc(g, g.vertices[i+1], g.vertices[i], 1);
	}

	print("Created: %d vertices, %d arcs\n", g.n, g.m);

	endpoint = count_arcs(g.vertices[0]);
	middle = count_arcs(g.vertices[4]);
	print("Endpoint degree: %d, Middle degree: %d\n", endpoint, middle);
}

test_torus()
{
	x, y, vi, ui, nx, ny, deg: int;
	v: ref Vertex;

	g := new_graph();

	# Create 3x3 grid with wraparound
	for (x = 0; x < 3; x++) {
		for (y = 0; y < 3; y++) {
			v = new_vert(g);
			v.name = sprint("%d.%d", x, y);
		}
	}

	# Create edges with wraparound
	for (x = 0; x < 3; x++) {
		for (y = 0; y < 3; y++) {
			vi = x * 3 + y;
			v = g.vertices[vi];

			# All 4 directions with wraparound
			nx = (x + 1) % 3;
			ui = nx * 3 + y;
			new_arc(g, v, g.vertices[ui], 1);

			nx = (x - 1 + 3) % 3;
			ui = nx * 3 + y;
			new_arc(g, v, g.vertices[ui], 1);

			ny = (y + 1) % 3;
			ui = x * 3 + ny;
			new_arc(g, v, g.vertices[ui], 1);

			ny = (y - 1 + 3) % 3;
			ui = x * 3 + ny;
			new_arc(g, v, g.vertices[ui], 1);
		}
	}

	print("Created: %d vertices, %d arcs\n", g.n, g.m);

	# On a torus, all vertices should have same degree
	deg = count_arcs(g.vertices[0]);
	print("All vertices have degree: %d\n", deg);
}

test_complete()
{
	i, j, deg: int;
	v: ref Vertex;

	g := new_graph();

	# Create 4 vertices
	for (i = 0; i < 4; i++) {
		v = new_vert(g);
		v.name = sprint("%d", i);
	}

	# Connect all pairs
	for (i = 0; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			if (i != j) {
				new_arc(g, g.vertices[i], g.vertices[j], 1);
			}
		}
	}

	print("Created: %d vertices, %d arcs\n", g.n, g.m);

	deg = count_arcs(g.vertices[0]);
	print("Each vertex degree: %d\n", deg);
}

count_arcs(v: ref Vertex): int
{
	count := 0;
	for (arcs := v.arcs; arcs != nil; arcs = tl arcs)
		count++;
	return count;
}
