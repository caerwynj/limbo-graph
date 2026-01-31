# Limbo Graph Base

A Limbo language implementation of Donald Knuth's Stanford GraphBase algorithms, originally written in CWEB. This project provides graph data structures and classic graph algorithms for the Inferno operating system.

## About

The Stanford GraphBase (SGB) is a collection of datasets and algorithms for combinatorial computing, created by Donald Knuth. This project translates these routines into the Limbo programming language, making them available for use in the Inferno environment.

## Prerequisites

### Install Inferno64

This project requires the Inferno64 system with the Limbo compiler, mk build tool, and emu emulator.

1. Clone and build Inferno64:
```bash
cd /home/user
git clone https://github.com/caerwynj/inferno64.git
cd inferno64

# Install dependencies (on Linux)
apt install libx11-dev libxext-dev linux-libc-dev

# Build Inferno
export ROOT=/home/user/inferno64
export objtype=amd64
export PATH=$PATH:$ROOT/Linux/$objtype/bin
./makemk.sh
mk mkdirs
mk install
```

2. Add to your `.bashrc`:
```bash
export ROOT=/home/user/inferno64
export objtype=amd64
export PATH=$PATH:$ROOT/Linux/$objtype/bin
```

## Building the Project

### Build all modules
```bash
mk
```

### Build specific module
```bash
limbo graph.b    # Build graph module
limbo book.b     # Build book example
limbo board.b    # Build board graph generator
limbo dijk2.b    # Build Dijkstra's algorithm
```

### Run a dis file from the current folder
```bash
emu /dis/sh.dis -lc "book.dis"
```

### Run tests
```bash
mk test
```

### Clean build artifacts
```bash
mk clean
```

## Project Structure

### Core Modules

- **graph.b / graph.m** - Core graph data structures (Graph, Vertex, Arc ADTs)
  - `new_graph()` - Create new graph
  - `new_vert()` - Add vertex to graph
  - `new_arc()` - Add arc between vertices
  - Hash table support for vertex lookup

### Algorithms

- **dijk2.b** - Dijkstra's shortest path algorithm
- **dijk3.b** - Alternative Dijkstra implementation

### Data Structures

- **pq.b** - Priority queue implementation
- **pq2.b** - Alternative priority queue implementation

### Examples

- **book.b** - Book graph generation (uses anna.dat)
  - Creates graph from Anna Karenina word co-occurrence data

- **board.b** - Board/grid graph generation
  - Generates graphs representing game boards or grids

### Data Files

- **anna.dat** - Sample dataset (Anna Karenina word data, 9.7KB)

## Graph ADT

The core graph abstract data type provides:

```limbo
Graph: adt {
    vertices: array of ref Vertex;
    n: int;          # number of vertices
    m: int;          # number of arcs
    id: string;      # graph identifier
    uu, ww, xx, yy, zz: ref Util;  # utility fields
};

Vertex: adt {
    name: string;
    arcs: list of Arc;
    u, v, w, x, y, z: ref Util;  # utility fields
};

Arc: adt {
    tip: ref Vertex;
    length: int;
    a, b: ref Util;  # utility fields
};
```

## Running Programs

Programs are compiled to `.dis` bytecode files that run under the Inferno emulator using the mash shell which is like the Plan 9 shell rc:

```bash
mash board.dis
mash 'lc | wc'
```
## Debugging Programs

Source level debug is available using the `debug` CLI inside inferno.
```bash
mash debug 
> help
> run /dis/ls.dis
> next
> stack
> print argv
```
## References

- **Stanford GraphBase**: https://cs.stanford.edu/~knuth/sgb.html
- **Donald Knuth's original CWEB implementation**
- **Inferno64**: https://github.com/caerwynj/inferno64
- **Limbo Language**: Part of the Inferno operating system

## License

See original Stanford GraphBase license and Inferno license terms.

## Notes

- All utilities are "loosely translated" from the original CWEB code
- The Limbo versions maintain the spirit of SGB while adapting to Limbo's type system and module structure
- Utility fields (u, v, w, x, y, z) provide flexible per-vertex/arc storage using pick ADTs
