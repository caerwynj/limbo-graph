%.dis: %.b
	limbo $stem.b


all:V:  graph.dis


test:V: all
	mash graph
