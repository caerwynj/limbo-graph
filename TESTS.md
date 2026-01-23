# Board Graph Tests

This directory contains test suites for the board graph implementation.

**Note:** Running .dis files under emu requires proper Inferno environment setup. The .dis files need to be accessible within the Inferno filesystem, or you can run the board implementation by compiling and testing within the Inferno environment directly.

## Test Files

### 1. boardtest.b
Standalone test suite that creates small graphs manually to verify basic graph operations.

**Compile and run:**
```bash
limbo boardtest.b
emu boardtest.dis
```

**Tests included:**
- 3x3 Wazir grid (orthogonal moves)
- 4x4 Knight graph
- 8-vertex linear graph
- 3x3 Torus (wraparound grid)
- 4-vertex complete graph

### 2. run_board_tests.sh
Comprehensive test script that runs the actual board.b implementation with various configurations.

**Run all tests:**
```bash
./run_board_tests.sh
```

## Test Configurations

### Basic Board Sizes

| Test | Command | Vertices | Description |
|------|---------|----------|-------------|
| 3x3 Wazir | `emu board.dis 3 3 0 0 1 0 0` | 9 | Small grid with orthogonal moves |
| 8x8 Default | `emu board.dis` | 64 | Standard chessboard |
| 4x4 Board | `emu board.dis 4 4 0 0 1 0 0` | 16 | Medium grid |

### Piece Types (Distance-based)

| Piece | Distance | Moves | Example |
|-------|----------|-------|---------|
| Wazir | 1 | Orthogonal (±1,0) or (0,±1) | `piece=1` |
| Fers | 2 | Diagonal (±1,±1) | `piece=2` |
| Dabbaba | 4 | (±2,0) or (0,±2) | `piece=4` |
| Knight | 5 | (±2,±1) or (±1,±2) | `piece=5` |
| Alfil | 8 | (±2,±2) | `piece=8` |
| Camel | 10 | (±3,±1) or (±1,±3) | `piece=10` |
| Zebra | 13 | (±3,±2) or (±2,±3) | `piece=13` |

### Rider Pieces (Negative values)

| Piece | Moves | Example |
|-------|-------|---------|
| Rook | Multiple orthogonal steps | `piece=-1` |
| Bishop | Multiple diagonal steps | `piece=-2` |
| Unicorn | Multiple 3D diagonal steps | `piece=-3` |

### Wraparound (Toroidal Boards)

| Wrap | Description | Example |
|------|-------------|---------|
| 0 | No wraparound | Default |
| 1 | X-axis wraps (cylinder) | `wrap=1` |
| 2 | Y-axis wraps (cylinder) | `wrap=2` |
| 3 | Both axes wrap (torus) | `wrap=3` |
| -1 | All dimensions wrap | `wrap=-1` |

### Special Graphs

**Complete Graph (K_n):**
```bash
emu board.dis 5 0 0 0 -1 0 0  # Complete graph on 5 vertices
```

**Cycle/Circuit:**
```bash
emu board.dis 8 0 0 0 1 1 0   # 8-vertex undirected cycle
emu board.dis 8 0 0 0 1 1 1   # 8-vertex directed cycle
```

**Transitive Tournament:**
```bash
emu board.dis 5 0 0 0 -1 0 1  # Directed acyclic complete graph
```

**Empty Graph:**
```bash
emu board.dis 8 0 0 0 2 0 0   # 8 vertices, no edges
```

### Multi-dimensional Boards

**3D Cube:**
```bash
emu board.dis 3 3 3 0 1 0 0   # 3x3x3 cube with orthogonal moves
```

**4D Hypercube:**
```bash
emu board.dis 2 2 2 2 1 0 0   # 2x2x2x2 tesseract
```

## Expected Results

### Degree Analysis

**8x8 Wazir (orthogonal):**
- Corner vertices: degree 2
- Edge vertices: degree 3
- Interior vertices: degree 4
- Total arcs: 2 × (7×8 + 8×7) = 224

**8x8 Knight:**
- Corner vertices: degree 2
- Near-corner: degree 3-4
- Edge vertices: degree 4-6
- Interior vertices: degree 8
- Total arcs: varies by position

**4x4 Torus (wrap=3):**
- All vertices: degree 4 (regular graph)
- Total arcs: 4 × 16 = 64

**Complete K_5:**
- All vertices: degree 4 (outgoing)
- Total arcs: 5 × 4 = 20 (directed)

## Validation Checks

When running tests, verify:

1. **Vertex count** matches expected n₁ × n₂ × ... × nₐ
2. **Degree distribution** is correct for piece type
3. **Symmetry** - graph should be symmetric (unless directed)
4. **Wraparound** - edges connect across boundaries when wrap ≠ 0
5. **No self-loops** (except in special wrapped cases with piece > 0)

## Performance Notes

- Small boards (< 100 vertices): instant
- Medium boards (100-1000 vertices): < 1 second
- Large boards (> 10000 vertices): may take several seconds
- Very large boards: limited by memory (vertices = n₁ × n₂ × ... × nₐ)

## Debugging

To see vertex names and arc counts:
```bash
emu board.dis 3 3 0 0 1 0 0
```

Output shows:
- Dimension count
- Vertex count
- Arc count
- First/last vertex names (for large graphs)
