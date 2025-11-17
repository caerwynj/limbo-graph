%.dis: %.b
	limbo $stem.b

DIS=\
	graph.dis\
	book.dis\
	board.dis\
	dijk2.dis\
	pq.dis\
	pq2.dis\

all:V:  $DIS


test:V: all
	mash graph
