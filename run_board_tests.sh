#!/bin/bash
# Test script for board.b implementation
# Runs board generator with various configurations

source /home/user/.bashrc

echo "=============================="
echo "Board Graph Generation Tests"
echo "=============================="
echo ""

# Test 1: Default 8x8 board
echo "Test 1: Default 8x8 Wazir board"
echo "Expected: 64 vertices, ~112 edges (interior vertices have degree 4)"
echo "Command: emu board.dis"
emu board.dis
echo ""

# Test 2: Small 3x3 board
echo "Test 2: Small 3x3 Wazir board"
echo "Expected: 9 vertices"
echo "Command: emu board.dis 3 3 0 0 1 0 0"
emu board.dis 3 3 0 0 1 0 0
echo ""

# Test 3: 8x8 Knight
echo "Test 3: 8x8 Knight moves (distance 5)"
echo "Expected: 64 vertices, knights from center have 8 moves"
echo "Command: emu board.dis 8 8 0 0 5 0 0"
emu board.dis 8 8 0 0 5 0 0
echo ""

# Test 4: 4x4 Fers (diagonal)
echo "Test 4: 4x4 Fers (diagonal moves, distance 2)"
echo "Expected: 16 vertices"
echo "Command: emu board.dis 4 4 0 0 2 0 0"
emu board.dis 4 4 0 0 2 0 0
echo ""

# Test 5: 8x8 Rook (rider)
echo "Test 5: 8x8 Rook moves (orthogonal rider, piece=-1)"
echo "Expected: 64 vertices, each rook can reach 14 squares"
echo "Command: emu board.dis 8 8 0 0 -1 0 0"
emu board.dis 8 8 0 0 -1 0 0
echo ""

# Test 6: 8x8 Bishop (rider)
echo "Test 6: 8x8 Bishop moves (diagonal rider, piece=-2)"
echo "Expected: 64 vertices, bishops in center can reach 13 squares"
echo "Command: emu board.dis 8 8 0 0 -2 0 0"
emu board.dis 8 8 0 0 -2 0 0
echo ""

# Test 7: 4x4 Cylinder (wrap in x)
echo "Test 7: 4x4 Cylinder (wrap=1, x-axis wraps)"
echo "Expected: 16 vertices, edge vertices connect to opposite edge"
echo "Command: emu board.dis 4 4 0 0 1 1 0"
emu board.dis 4 4 0 0 1 1 0
echo ""

# Test 8: 4x4 Torus (wrap in both)
echo "Test 8: 4x4 Torus (wrap=3, both axes wrap)"
echo "Expected: 16 vertices, all vertices have degree 4"
echo "Command: emu board.dis 4 4 0 0 1 3 0"
emu board.dis 4 4 0 0 1 3 0
echo ""

# Test 9: Linear board (1D)
echo "Test 9: Linear 8-vertex board"
echo "Expected: 8 vertices in a line"
echo "Command: emu board.dis 8 0 0 0 1 0 0"
emu board.dis 8 0 0 0 1 0 0
echo ""

# Test 10: Circuit (1D with wrap)
echo "Test 10: 8-vertex circuit (cycle)"
echo "Expected: 8 vertices, all with degree 2"
echo "Command: emu board.dis 8 0 0 0 1 1 0"
emu board.dis 8 0 0 0 1 1 0
echo ""

# Test 11: Small 3D cube
echo "Test 11: 3x3x3 3D Wazir board"
echo "Expected: 27 vertices, center has degree 6"
echo "Command: emu board.dis 3 3 3 0 1 0 0"
emu board.dis 3 3 3 0 1 0 0
echo ""

# Test 12: Complete graph
echo "Test 12: Complete graph K5"
echo "Expected: 5 vertices, each with 4 outgoing arcs"
echo "Command: emu board.dis 5 0 0 0 -1 0 0"
emu board.dis 5 0 0 0 -1 0 0
echo ""

# Test 13: Camel moves
echo "Test 13: 8x8 Camel (distance 10 = sqrt of 1+9 or 4+6)"
echo "Expected: 64 vertices, camel moves (3,1)"
echo "Command: emu board.dis 8 8 0 0 10 0 0"
emu board.dis 8 8 0 0 10 0 0
echo ""

# Test 14: Zebra moves
echo "Test 14: 8x8 Zebra (distance 13 = sqrt of 4+9)"
echo "Expected: 64 vertices, zebra moves (2,3)"
echo "Command: emu board.dis 8 8 0 0 13 0 0"
emu board.dis 8 8 0 0 13 0 0
echo ""

# Test 15: Directed graph
echo "Test 15: 5-vertex directed complete graph (transitive tournament)"
echo "Expected: 5 vertices, directed acyclic graph"
echo "Command: emu board.dis 5 0 0 0 -1 0 1"
emu board.dis 5 0 0 0 -1 0 1
echo ""

echo "=============================="
echo "All tests completed"
echo "=============================="
