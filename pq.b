implement PQ;

include "sys.m";
include "draw.m";
sys: Sys;

PQ: module
{
	Item: adt {
		priority: int;
		value: string;
	};

	PriorityQueue: adt {
		heap: array of Item;
		size: int;		 
		capacity: int;
	};

	new: fn(capacity: int): ref PriorityQueue;
	insert: fn(q: ref PriorityQueue, priority: int, value: string): int;
	extract_min: fn(q: ref PriorityQueue): Item;
	is_empty: fn(q: ref PriorityQueue): int;
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

swap(q: ref PriorityQueue, i: int, j: int)
{
	temp: Item;
	temp = q.heap[i];
	q.heap[i] = q.heap[j];
	q.heap[j] = temp;
}

sift_up(q: ref PriorityQueue, i: int)
{
	parent: int;
	while(i > 0) {
		parent = (i - 1) / 2;
		if(q.heap[i].priority < q.heap[parent].priority) {
			swap(q, i, parent);
			i = parent;
		} else {
			break;
		}
	}
}

sift_down(q: ref PriorityQueue, i: int)
{
	left: int;
	right: int;
	min_child: int;
	
	while(i < q.size) {
		left = 2 * i + 1;
		right = 2 * i + 2;
		min_child = i;

		# Find the index of the smallest child
		if(left < q.size && q.heap[left].priority < q.heap[min_child].priority) {
			min_child = left;
		}
		if(right < q.size && q.heap[right].priority < q.heap[min_child].priority) {
			min_child = right;
		}

		# If the current element is not the smallest, swap and continue
		if(min_child != i) {
			swap(q, i, min_child);
			i = min_child;
		} else {
			break;
		}
	}
}

new(capacity: int): ref PriorityQueue
{
	return ref PriorityQueue(array[capacity] of Item, 0, capacity);
}

insert(q: ref PriorityQueue, priority: int, value: string): int
{
	if(q.size >= q.capacity) {
		sys->print("PQ: Error: Queue is full\n");
		return -1;
	}
	q.heap[q.size] = Item(priority, value);
	sift_up(q, q.size);
	q.size++;
	return 0;
}

extract_min(q: ref PriorityQueue): Item
{
	if(q.size == 0) {
		sys->print("PQ: Error: Queue is empty\n");
		return Item(~0, nil); # ~0 is MAXINT in Limbo
	}
	
	min_item: PQ->Item;
	min_item = q.heap[0];
	q.size--;
	q.heap[0] = q.heap[q.size];
	sift_down(q, 0);
	
	return min_item;
}

is_empty(q: ref PQ->PriorityQueue): int
{
	return q.size == 0;
}

init(ctxt: ref Draw->Context, argv: list of string)
{
	q: ref PriorityQueue;
	item: Item;
	
	sys = load Sys Sys->PATH;
	sys->print("--- Limbo Priority Queue Demo ---\n");
	
	# Initialize the queue
	q = new(100);
	
	# Insert items with various priorities
	sys->print("Inserting items: (P=5, A), (P=1, B), (P=10, C), (P=2, D)\n");
	insert(q, 5, "Task A: Medium");
	insert(q, 1, "Task B: High Priority");
	insert(q, 10, "Task C: Low Priority");
	insert(q, 2, "Task D: Urgent");

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
	
	# Attempt to extract from an empty queue
	item = extract_min(q);
	sys->print("Attempted extract on empty queue (check console for error). Priority=%d\n", item.priority);
}
