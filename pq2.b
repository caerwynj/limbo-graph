implement PQ;

include "sys.m";
include "draw.m";
sys: Sys;

PQ: module
{
	Item: adt {
		priority: int;
		value: string;
		llink: ref Item;
		rlink: ref Item;
	};

	PriorityQueue: adt {
		head: ref Item;
		size: int;		 
	};

	new: fn(d: int): ref PriorityQueue;
	enqueue: fn(q: ref PriorityQueue, v: ref Item, d: int);
	requeue: fn(q: ref PriorityQueue, v: ref Item, d: int);
	extract_min: fn(q: ref PriorityQueue): ref Item;
	is_empty: fn(q: ref PriorityQueue): int;
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

new(d: int): ref PriorityQueue
{
	head := ref Item(d-1, nil, nil, nil);
	head.rlink = head;
	head.llink = head;
	return ref PriorityQueue(head, 0);
}

enqueue(q: ref PriorityQueue, v: ref Item, d: int)
{
	t: ref Item;
	t = q.head.llink;
	v.priority = d;
	while (d < t.priority) 
		t = t.llink;
	v.llink = t;
	v.rlink = t.rlink;
	t.rlink.llink = v;
	t.rlink = v;
	q.size++;
}

requeue(q: ref PriorityQueue, v: ref Item, d: int)
{
	t: ref Item;
	t = v.llink;
	t.rlink = v.rlink;
	v.rlink.llink = v.llink;  # remove v
	v.priority = d;
	# asssume new priority is smaller than before
	while (d < t.priority)
		t = t.llink;
	v.llink = t;
	v.rlink = t.rlink;
	t.rlink.llink = v;	
	t.rlink = v;
}

extract_min(q: ref PriorityQueue): ref Item
{
	t: ref Item;
	t = q.head.rlink;
	if (t == q.head)
		return nil;
	q.head.rlink = t.rlink;
	t.rlink.llink = q.head;
	q.size--;
	return t;
}

is_empty(q: ref PQ->PriorityQueue): int
{
	return q.size == 0;
}

init(ctxt: ref Draw->Context, argv: list of string)
{
	q: ref PriorityQueue;
	item: ref Item;
	
	sys = load Sys Sys->PATH;
	sys->print("--- Limbo Priority Queue Linked List Demo ---\n");
	
	# Initialize the queue
	q = new(0);
	
	i1 := ref Item(5, "Task A: Medium", nil, nil);
	i2 := ref Item(1, "Task B: High Priority", nil, nil);
	i3 := ref Item(10, "Task C: Low Priority", nil, nil);
	i4 := ref Item(2, "Task D: Urgent", nil, nil);
	# Insert items with various priorities
	sys->print("Inserting items: (P=5, A), (P=1, B), (P=10, C), (P=2, D)\n");
	enqueue(q, i1, 5);
	enqueue(q, i2, 1);
	enqueue(q, i3, 10);
	enqueue(q, i4, 2);
	# Extract items (should come out in order of priority: 1, 2, 5, 10)
	sys->print("\nExtracting minimums:\n");

	while(!is_empty(q)) {
		item = extract_min(q);
		sys->print("Extracted: Priority=%d, Value='%s'\n", item.priority, item.value);
	}

	# Check empty status
	if(is_empty(q)) {
		sys->print("\nQueue is now empty.\n");
	}
	
	# Insert items with various priorities
	sys->print("Inserting items: (P=5, A), (P=1, B), (P=10, C), (P=2, D)\n");
	enqueue(q, i1, 5);
	enqueue(q, i2, 1);
	enqueue(q, i3, 10);
	enqueue(q, i4, 2);
	
	requeue(q, i3, 3);
	while(!is_empty(q)) {
		item = extract_min(q);
		sys->print("Extracted: Priority=%d, Value='%s'\n", item.priority, item.value);
	}


	# Attempt to extract from an empty queue
	item = extract_min(q);
	sys->print("Attempted extract on empty queue (check console for error). Priority=\n" );
}

