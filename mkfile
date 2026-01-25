%.dis: %.b
	limbo $stem.b

DIS=\
	graph.dis\
	book.dis\
	board.dis\
	dijk2.dis\
	pq.dis\
	pq2.dis\

TEST_DIS=\
	boardtest.dis\

all:V:  $DIS

tests:V: all $TEST_DIS
	echo "Running board graph tests..."
	emu /dis/sh.dis -lc boardtest.dis
	echo ""
	echo "To run comprehensive board tests, execute: ./run_board_tests.sh"

test:V: tests

clean:V:
	rm -f *.dis
