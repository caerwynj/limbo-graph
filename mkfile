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
	test_basic_funcs.dis\
	test_board_sample.dis\
	test_lines.dis\
	test_product.dis\
	test_induced.dis\
	test_complement.dis\
	test_save_restore.dis\

TESTOUT=${TEST_DIS:%.dis=%.testout}

%.testout: %.dis
	emu /dis/sh.dis -lc $stem.dis > $stem.testout

all:V:  $DIS

tests:V: all $TESTOUT
	grep -i FAIL *.testout || echo "All tests passed"

test:V: tests

clean:V:
	rm -f *.dis
