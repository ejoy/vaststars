#include "core/fluidflow.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "util/sort_r.h"

#define PIPE_DEFAULT 8
#define PIPE_MAX 0xffff
#define PIPE_CONNECTION 4
#define PIPE_INVALID_CONNECTION 0xffff
#define FIXSHIFT 256

struct pipe {
	int id;
	int fluid;
	int height;
	int capacity;
	int base_level;
	int pumping_speed;	// 0 : pipe , >0 pump
	int flow;
	unsigned short uplink[PIPE_CONNECTION];	// index
	unsigned short downlink[PIPE_CONNECTION];
	int reservation[PIPE_CONNECTION];
};

struct fluidflow_network {
	struct pipe *p;
	unsigned short *order;
	int *blocking;
	int pump_n;
	int pipe_n;
	int cap;
	int blocking_n;
	int blocking_cap;
};

void
fluidflow_delete(struct fluidflow_network *net) {
	if (net == NULL)
		return;
	free(net->p);
	free(net->order);
	free(net->blocking);
	free(net);
}

struct fluidflow_network *
fluidflow_new() {
	struct fluidflow_network *net = (struct fluidflow_network *)malloc(sizeof(*net));
	if (net == NULL)
		return NULL;
	net->p = NULL;
	net->order = NULL;
	net->pump_n = 0;
	net->pipe_n = 0;
	net->cap = PIPE_DEFAULT;
	net->p = (struct pipe *)malloc(net->cap * sizeof(struct pipe));
	if (net->p == NULL) {
		fluidflow_delete(net);
		return NULL;
	}
	net->blocking = NULL;
	net->blocking_n = 0;
	net->blocking_cap = 0;
	return net;
}


static inline void
clear_order(struct fluidflow_network *net) {
	if (net->order) {
		free(net->order);
		net->order = NULL;
	}
}

static void
change_downlink(struct pipe *p, unsigned short from, unsigned short to) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->downlink[i] == from)
			p->downlink[i] = to;
	}
}

static void
change_uplink(struct pipe *p, unsigned short from, unsigned short to) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == from)
			p->uplink[i] = to;
	}
}

// move fist pipe to the last
static void
shift_pipe(struct fluidflow_network *net) {
	unsigned short from = net->pump_n;
	unsigned short to = net->pump_n + net->pipe_n;
	net->p[to] = net->p[from];
	int i;
	struct pipe *p = &net->p[to];
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->uplink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		change_downlink(&net->p[c], from, to);
	}
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->downlink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		change_uplink(&net->p[c], from, to);
	}
}

int
fluidflow_build(struct fluidflow_network *net, int id, struct fluid_box *box) {
	clear_order(net);
	int n = net->pump_n + net->pipe_n;
	if (n >= net->cap) {
		int cap = net->cap * 2;
		if (cap > PIPE_MAX)
			return 1;
		struct pipe * new_pipe = (struct pipe *)malloc(cap * sizeof(struct pipe));
		if (new_pipe == NULL) {
			free(new_pipe);
			return 1;
		}
		memcpy(new_pipe, net->p, n * sizeof(struct pipe));
		free(net->p);
		net->p = new_pipe;
		net->cap = cap;
	}
	struct pipe *p;
	if (box->pumping_speed > 0) {
		// It's a pump
		if (net->pipe_n > 0) {
			shift_pipe(net);
		}
		p = &net->p[net->pump_n++];
	} else {
		p = &net->p[n];
		++net->pipe_n;
	}
	p->id = id;
	p->fluid = 0;
	p->capacity = box->capacity;
	p->height = box->height * FIXSHIFT;
	p->base_level = box->base_level * FIXSHIFT;
	p->pumping_speed = box->pumping_speed;
	p->flow = 0;
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		p->uplink[i] = PIPE_INVALID_CONNECTION;
		p->downlink[i] = PIPE_INVALID_CONNECTION;
		p->reservation[i] = 0;
	}
	return 0;
}

static void
remove_connection(struct pipe *p, int idx) {
	int i,j;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == idx) {
			for (j=i+1;j<PIPE_CONNECTION;j++) {
				p->uplink[j-1] = p->uplink[j];
				p->reservation[j-1] = p->reservation[j];
			}
			p->uplink[PIPE_CONNECTION-1] = PIPE_INVALID_CONNECTION;
			p->reservation[PIPE_CONNECTION-1] = 0;
			break;
		}
	}
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->downlink[i] == idx) {
			for (j=i+1;j<PIPE_CONNECTION;j++) {
				p->downlink[j-1] = p->downlink[j];
			}
			p->downlink[PIPE_CONNECTION-1] = PIPE_INVALID_CONNECTION;
			break;
		}
	}
}

static int find_id(struct fluidflow_network *net, int id);

static void
adjust_connection(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->uplink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		if (c > idx) {
			p->uplink[i] = c - 1;
		}
	}
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->downlink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		if (c > idx) {
			p->downlink[i] = c - 1;
		}
	}
}

int
fluidflow_teardown(struct fluidflow_network *net, int id) {
	int idx = find_id(net, id);
	if (idx == PIPE_INVALID_CONNECTION)
		return 1;
	struct pipe *p = &net->p[idx];
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->uplink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		remove_connection(&net->p[c], idx);	
	}
	for (i=0;i<PIPE_CONNECTION;i++) {
		int c = p->downlink[i];
		if (c == PIPE_INVALID_CONNECTION)
			break;
		remove_connection(&net->p[c], idx);	
	}
	int n = net->pipe_n + net->pump_n;
	if (idx < n - 1) {
		for (i=0;i<idx;i++) {
			adjust_connection(&net->p[i], idx);
		}
		for (i=idx+1;i<n;i++) {
			adjust_connection(&net->p[i], idx);
		}
		memmove(&net->p[idx], &net->p[idx+1], (n - idx - 1) * sizeof(struct pipe));
	}
	if (idx < net->pump_n) {
		--net->pump_n;
	} else {
		--net->pipe_n;
	}
	clear_order(net);
	return 0;
}

#define FAIL 1
#define SUCC 0

static int
add_downlink(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->downlink[i] == idx) {
			// already added
			return SUCC;
		}
		if (p->downlink[i] == PIPE_INVALID_CONNECTION) {
			p->downlink[i] = idx;
			return SUCC;
		}
	}
	return FAIL;
}

static int
add_uplink(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == idx) {
			// already added
			return SUCC;
		}
		if (p->uplink[i] == PIPE_INVALID_CONNECTION) {
			p->uplink[i] = idx;
			p->reservation[i] = 0;
			return SUCC;
		}
	}
	return FAIL;
}

static int
add_connection(struct fluidflow_network *net, int from_idx, int to_idx) {
	struct pipe *from_pipe = &net->p[from_idx];
	struct pipe *to_pipe = &net->p[to_idx];
	if (add_downlink(from_pipe, to_idx) == FAIL)
		return FAIL;
	if (add_uplink(to_pipe, from_idx) == FAIL)
		return FAIL;
	return SUCC;
}

int
fluidflow_connect(struct fluidflow_network *net, int from, int to, int oneway) {
	int from_idx = find_id(net, from);
	int to_idx = find_id(net, to);
	if (from_idx == PIPE_INVALID_CONNECTION || to_idx == PIPE_INVALID_CONNECTION || from_idx == to_idx)
		return FAIL;
	if (add_connection(net, from_idx, to_idx) == FAIL)
		return FAIL;
	if (!oneway) {
		struct pipe *p = &net->p[to_idx];
		if (p->pumping_speed == 0) {
			return add_connection(net, to_idx, from_idx);
		}
	}
	return SUCC;
}

static struct fluid_state *
get_state(struct pipe *p, struct fluid_state *output) {
	output->id = p->id;
	output->volume = p->fluid;
	output->flow = p->flow;
	output->box.capacity = p->capacity;
	output->box.height = p->height / FIXSHIFT;
	output->box.base_level = p->base_level / FIXSHIFT;
	output->box.pumping_speed = p->pumping_speed;
	return output;
}

static int
set_fluid(struct fluidflow_network *net, int idx, int fluid, int multiple) {
	if (idx == PIPE_INVALID_CONNECTION)
		return -1;
	struct pipe *p = &net->p[idx];
	if (fluid <= 0) {
		p->fluid %= multiple;
		return 0;
	}
	fluid *= multiple;
	fluid += p->fluid % multiple;
	if (fluid >= p->capacity) {
		p->fluid = p->capacity;
	} else {
		p->fluid = fluid;
	}
	return p->fluid;
}

int
fluidflow_set(struct fluidflow_network *net, int id, int fluid, int multiple) {
	int idx = find_id(net, id);
	return set_fluid(net, idx, fluid, multiple);
}

void
fluidflow_block(struct fluidflow_network *net, int id) {
	if (net->blocking == NULL) {
		if (net->blocking_cap == 0) {
			net->blocking_cap = net->pump_n;
		}
		net->blocking = (int *)malloc(net->blocking_cap * sizeof(int));
	}
	if (net->blocking_n >= net->blocking_cap) {
		int cap = net->blocking_cap * 2;
		int *blocking = (int *)malloc(cap * sizeof(int));
		memcpy(blocking, net->blocking, net->blocking_cap * sizeof(int));
		free(net->blocking);
		net->blocking = blocking;
		net->blocking_cap = cap;
	}
	net->blocking[net->blocking_n++] = id;
}

static int
compar_blocking(const void *aa, const void *bb) {
	const int * a = (const int *)aa;
	const int * b = (const int *)bb;
	return *a - *b;
}

static void
sort_blocking(struct fluidflow_network *net) {
	if (net->blocking_n == 0) {
		return;
	}
	qsort(net->blocking, net->blocking_n, sizeof(int), compar_blocking);
}

static inline int
is_blocking(struct fluidflow_network *net, int id) {
	int begin = 0;
	int end = net->blocking_n;
	while (begin < end) {
		int mid = (begin + end) / 2;
		int t = net->blocking[mid];
		if (t == id)
			return 1;
		if (t < id)
			begin = mid + 1;
		else
			end = mid;
	}
	return 0;
}

static inline void
reset_blocking(struct fluidflow_network *net) {
	if (net->blocking_n * 2 < net->blocking_cap) {
		if (net->blocking_n > 0)
			net->blocking_cap = net->blocking_n;
		free(net->blocking);
		net->blocking = NULL;
	}
	net->blocking_n = 0;
}

static void
set_reservation(struct fluidflow_network *net, int from, int to, int r) {
	struct pipe *p = &net->p[to];
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == from) {
			p->reservation[i] = r;
//			printf("Reservation %d + %d -> %d : %d/%d\n", net->p[from].id, p->id , p->fluid , r , p->capacity);
			return;
		}
	}
}

static inline int
fluid_level(struct pipe *p) {
	return (uint64_t)p->fluid * p->height / p->capacity;
}

static void
attempt_flow(struct fluidflow_network *net, int idx) {
	struct pipe *p = &net->p[idx];
	int fluid = p->fluid;
	if (fluid == 0) {
		p->flow = 0;
		return;
	}

	int total = 0;
	int i;
	int f[PIPE_CONNECTION];
	int level = fluid_level(p);
	for (i=0;i<PIPE_CONNECTION;i++) {
		int to_idx = p->downlink[i];
		if (to_idx == PIPE_INVALID_CONNECTION)
			break;
		if (to_idx >= net->pump_n) {
			struct pipe *to = &net->p[to_idx];
			int to_level = fluid_level(to);
			int pressure = ((level + p->base_level) - (to_level + to->base_level)) / FIXSHIFT;
			if (pressure > 0) {
				f[i] = pressure / 2;
				total += f[i];
			} else {
				f[i] = 0;
			}
		} else {
			// ignore flow to pump
			f[i] = 0;
		}
	}
	int n = i;
	if (total > fluid) {
		int radio = FIXSHIFT * fluid / total;
		for (i=0;i<n;i++) {
			f[i] = f[i] * radio / FIXSHIFT;
		}
	}
	for (i=0;i<n;i++) {
//		printf("Attempt flow %d -> %d : %d\n", p->id, net->p[p->downlink[i]].id, f[i]);
		set_reservation(net, idx, p->downlink[i], f[i]);
	}
}

static void
reservation_fluid(struct fluidflow_network *net) {
	int i;
	// calc flow
	int n = net->pump_n + net->pipe_n;
	for (i=0;i<n;i++) {
		attempt_flow(net, i);
	}
}

struct bitset {
	unsigned int bits[(PIPE_MAX+31)/32];
};

static inline void
bitset_init(struct bitset *s, int n) {
	int c = (n + 31)/32 * sizeof(unsigned int);
	memset(s->bits, 0, c);
}

static inline int
bitset_isset(struct bitset *s, int idx) {
	int n = idx / 32;
	return s->bits[n] & (1 << (idx % 32));
}

static inline void
bitset_set(struct bitset *s, int idx) {
	int n = idx / 32;
	s->bits[n] |= (1 << (idx % 32));
}

static int
compar_sorted_index(const void *a, const void *b, void *arg) {
	const unsigned short *aa = (const unsigned short *)a;
	const unsigned short *bb = (const unsigned short *)b;
	struct pipe *p = (struct pipe *)arg;
	return p[*aa].id - p[*bb].id;
}

static unsigned short *
init_order(struct fluidflow_network *net) {
	int i;
	int base = net->pump_n;
	int n = base + net->pipe_n;
	unsigned short *order = (unsigned short *)malloc((net->pipe_n + n) * sizeof(unsigned short));
	for (i=0;i<net->pipe_n;i++) {
		order[i] = base + i;
	}

	unsigned short * sorted = order + net->pipe_n;

	for (i=0;i<n;i++) {
		sorted[i] = i;
	}

	sort_r(sorted, n, sizeof(sorted[0]), compar_sorted_index, net->p);

	net->order = order;
	return order;
}

static unsigned short *
prev_order(struct fluidflow_network *net) {
	if (net->order == NULL) {
		init_order(net);
	}
	return net->order;
}

static inline unsigned short *
sorted_index(struct fluidflow_network *net) {
	if (net->order == NULL) {
		init_order(net);
	}
	return net->order + net->pipe_n;
}

static int
find_id(struct fluidflow_network *net, int id) {
	unsigned short * sorted = sorted_index(net);
	int begin = 0;
	int end = net->pump_n + net->pipe_n;
	while (begin < end) {
		int mid = (begin + end) / 2;
		unsigned short index = sorted[mid];
		int v = net->p[index].id;
		if (id == v)
			return index;
		if (id < v)
			end = mid;
		else
			begin = mid + 1;
	}
	return PIPE_INVALID_CONNECTION;
}

static inline int
flow_to(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == idx) {
			return p->reservation[i] > 0;
		}
	}
	return 0;
}


static int
check_order(struct fluidflow_network *net, int idx, struct bitset *set) {
	struct pipe *p = &net->p[idx];
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		int to_idx = p->downlink[i];
		if (to_idx == PIPE_INVALID_CONNECTION)
			break;
		if (to_idx >= net->pump_n) {
			// to_idx is not a pump
			if (bitset_isset(set, to_idx)) {
				// to_idx is before idx
				if (flow_to(&net->p[idx], to_idx)) {
					// idx->to_idx, order reverse
					return to_idx;
				}
			} else {
				if (flow_to(&net->p[to_idx], idx)) {
					//to_idx->idx, order reverse
					return to_idx;
				}
			}
		}
	}
	return PIPE_INVALID_CONNECTION;
}

static void
print_order(struct fluidflow_network *net) {
	int i;
	for (i=0;i<net->pipe_n;i++) {
		int idx = net->order[i];
		printf("%d -> ", net->p[idx].id);
	}
	printf("\n");
}

static void
print_reservation(struct fluidflow_network *net) {
	int i, j;
	int base = net->pump_n;
	for (i=0;i<net->pipe_n;i++) {
		struct pipe *p = &net->p[base+i];
		for (j=0;j<PIPE_CONNECTION;j++) {
			if (p->uplink[j] == PIPE_INVALID_CONNECTION)
				break;
			if (p->reservation[j] > 0)
				printf("(%d->%d)/%d ", net->p[p->uplink[j]].id, p->id, p->reservation[j]);
		}
	}
	printf("\n");
}

static int
find_pipe(unsigned short *order, unsigned short id, struct bitset *set) {
	int i = 0;
	while (order[i] != id) {
		bitset_set(set, order[i]);
		++i;
	}
	return i;
}

static void
topology_sort(struct fluidflow_network *net) {
	int n = net->pipe_n;
	struct bitset set;
	bitset_init(&set, n);
	unsigned short *order = prev_order(net);
	int idx = 0;
	while (idx < n) {
		int current = order[idx];
		int id = check_order(net, current, &set);
		if (id == PIPE_INVALID_CONNECTION) {
			bitset_set(&set, current);
			++idx;
		} else {
			if (bitset_isset(&set, id)) {
				order[idx] = id;	// id is downstream
				bitset_init(&set, n);	// reset bitset
				idx = find_pipe(order, id, &set);
				order[idx] = current;
				bitset_set(&set, current);
			} else {
				order[idx] = id;	// id is upstream
				int i;
				for (i=idx+1;i<net->pipe_n;i++) {
					if (order[i] == id) {
						order[i] = current;
						break;
					}
				}
			}
		}
	}
 
}

static inline int
get_reservation(struct pipe *p, int from_idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == from_idx) {
			int r = p->reservation[i];
			p->reservation[i] = 0;
			return r;
		}
	}
	return 0;
}

static void
divide_fluid(int n, int f[PIPE_CONNECTION], int total, int space) {
	int radio = space * FIXSHIFT / total;
	int i;
	int o[PIPE_CONNECTION];
	int sum = 0;
	for (i=0;i<n;i++) {
		o[i] = f[i];
		f[i] = f[i] * radio / FIXSHIFT;
		sum += f[i];
	}
	int index = 0;
	while (sum < space) {
		if (o[index] > f[index]) {
			++f[index];
			++sum;
		}
		++index;
		if (index >= n)
			index = 0;
	}
}

static void
flow(struct fluidflow_network *net, int idx) {
	struct pipe *p = &net->p[idx];
	// reset flow
	p->flow = 0;
	int f[PIPE_CONNECTION];
	int total = 0;
	int i,n;
	for (i=0;i<PIPE_CONNECTION;i++) {
		int to = p->downlink[i];
		if (to == PIPE_INVALID_CONNECTION)
			break;
		f[i] = get_reservation(&net->p[to], idx);
		total += f[i];
	}
	n = i;
	int fluid = p->fluid;
	if (total > 0) {
		// flow
		if (total > fluid) {
			// reservation space is bigger than fluid
			divide_fluid(n, f, total, fluid);
			p->fluid = 0;
		} else {
			p->fluid -= total;
		}
		for (i=0;i<n;i++) {
			if (f[i] > 0) {
//				printf("Add %d->%d, %d+%d->%d\n", p->id, net->p[p->downlink[i]].id,
//					net->p[p->downlink[i]].fluid, f[i], net->p[p->downlink[i]].fluid + f[i]);
				struct pipe *to = &net->p[p->downlink[i]];
				to->fluid += f[i];
				to->flow += f[i];
			}
		}
	}
}

static void
adjust_reservation(struct fluidflow_network *net, int idx) {
	struct pipe *p = &net->p[idx];
	int space = p->capacity - p->fluid;
	int i;
//	printf("Space %d %d :\n", p->id, space);
	if (space == 0) {
		for (i=0;i<PIPE_CONNECTION;i++) {
			if (p->uplink[i] == PIPE_INVALID_CONNECTION) {
				break;
			}
			p->reservation[i] = 0;
		}
		return;
	}
	int total = 0;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == PIPE_INVALID_CONNECTION) {
			break;
		}
//		printf("(%d:%d)", net->p[p->uplink[i]].id,  p->reservation[i]);
		total += p->reservation[i];
	}
//	printf("\n");
	if (total > space) {
		// space is smaller than fluid
		int n = i;
//		printf("Realoc %d radio = %g total = %d space = %d\n", p->id, (float) space / total, total, space );
		divide_fluid(n, p->reservation, total, space);
	}
}

static void
draw_fluid(struct fluidflow_network *net, struct pipe *p) {
	if (is_blocking(net, p->id)) {
		// blocking
		p->flow = 0;
		return;
	}
	int space = p->capacity - p->fluid;
	if (space == 0) {
		// no space
		p->flow = 0;
		return;
	}
	int f[PIPE_CONNECTION];
	int total = 0;
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		int source_idx = p->uplink[i];
		if (source_idx == PIPE_INVALID_CONNECTION) {
			f[i] = 0;
			break;
		} else {
			f[i] = net->p[source_idx].fluid;
			total += f[i];
		}
	}
	int n = i;
	int speed = p->pumping_speed;
	if (speed > space)
		speed = space;
	if (speed >= total) {
		// draw all
		p->flow = total;
		for (i=0;i<n;i++) {
			int source_idx = p->uplink[i];
//			printf("Draw all fluid %d from %d to %d\n", net->p[source_idx].fluid, net->p[source_idx].id, p->id);
			net->p[source_idx].fluid = 0;
		}
	} else {
		p->flow = speed;
		divide_fluid(n, f, total, speed);
		for (i=0;i<n;i++) {
			int source_idx = p->uplink[i];
			net->p[source_idx].fluid -= f[i];
//			printf("Draw fluid %d from %d to %d\n", f[i], net->p[source_idx].id, p->id);
		}
	}
}

static void
pump_fluid(struct fluidflow_network *net) {
	int i;
	for (i=0;i<net->pump_n;i++) {
		struct pipe *p = &net->p[i];
		draw_fluid(net, p);
	}
	for (i=0;i<net->pump_n;i++) {
		net->p[i].fluid += net->p[i].flow;
	}
}

int
fluidflow_size(struct fluidflow_network *net) {
	return net->pump_n + net->pipe_n;
}

struct fluid_state *
fluidflow_index(struct fluidflow_network *net, int idx, struct fluid_state *output) {
	if (idx >= fluidflow_size(net))
		return NULL;
	get_state(&net->p[idx], output);
	output->blocking = is_blocking(net, idx);
	return output;
}

struct fluid_state *
fluidflow_query(struct fluidflow_network *net, int id, struct fluid_state *output) {
	// todo :  cache id map
	int idx = find_id(net, id);
	if (idx == PIPE_INVALID_CONNECTION)
		return NULL;
	get_state(&net->p[idx], output);
	output->blocking = is_blocking(net, idx);
	return output;
}

void
fluidflow_update(struct fluidflow_network *net) {
	sort_blocking(net);
	pump_fluid(net);
	reservation_fluid(net);
//	print_reservation(net);
	topology_sort(net);
//	print_order(net);
	
	int i;
	for (i=0;i<net->pipe_n;i++) {
		int idx = net->order[i];
		flow(net, idx);
		adjust_reservation(net, idx);
	}
	for (i=0;i<net->pump_n;i++) {
		flow(net, i);
	}
	reset_blocking(net);
}

void
fluidflow_dump(struct fluidflow_network *net) {
	int i, j;
	int n = net->pump_n + net->pipe_n;
	for (i=0;i<n;i++) {
		struct pipe *p = &net->p[i];
		printf("id=%d (%d/%d:%d)\n", p->id, p->fluid, p->capacity, p->pumping_speed);
		for (j=0;j<PIPE_CONNECTION;j++) {
			if (p->downlink[j] != PIPE_INVALID_CONNECTION) {
				printf(" ->%d", net->p[p->downlink[j]].id);
			} else {
				break;
			}
		}
		if (j > 0)
			printf("\n");
		for (j=0;j<PIPE_CONNECTION;j++) {
			if (p->uplink[j] != PIPE_INVALID_CONNECTION) {
				printf(" <-%d", net->p[p->uplink[j]].id);
			} else {
				break;
			}
		}
		if (j > 0)
			printf("\n");
	}
	printf("SORTED:");
	unsigned short * sorted = sorted_index(net);
	for (i=0;i<n;i++) {
		printf(" %d[%d]", sorted[i], net->p[sorted[i]].id);
	}
	printf("\n");

}

#ifdef TEST_MAIN

#include <stdio.h>


static void
update(struct fluidflow_network *net, int fluid[]) {
	fluidflow_set(net, 1, fluid[0] + 20000, 1);
	fluidflow_set(net, 12, fluid[11] + 10000, 1);
	fluidflow_update(net);
	int i;
	for (i=1;i<=12;i++) {
		struct fluid_state s;
		fluid[i-1] = fluidflow_query(net, i, &s)->volume;
		printf("[%d]:%d/%d ", i, fluid[i-1], s.flow);
	}
	printf("\n");
}

int
main() {
	struct fluidflow_network *net = fluidflow_new();
	struct fluid_box bump = {
		200 * 100, // cap
		200 * 100,	// height
		0,	// base_level
		200 * 100,	// pumping_speed
	};
	struct fluid_box pipe = {
		2 * 100 * 100,	// cap
		100 * 100,	// height
		0,
		0,
	};
	struct fluid_box tank = {
		50 * 100 * 100,	// cap
		100 * 100,	// height
		0,
		0,
	};
	fluidflow_build(net, 12, &pipe);
	fluidflow_build(net, 11, &bump);
	fluidflow_build(net, 10, &tank);
	fluidflow_build(net, 9, &pipe);
	fluidflow_build(net, 8, &pipe);
	fluidflow_build(net, 7, &pipe);
	fluidflow_build(net, 6, &pipe);
	fluidflow_build(net, 5, &pipe);
	fluidflow_build(net, 4, &pipe);
	fluidflow_build(net, 3, &pipe);
	fluidflow_build(net, 2, &bump);
	fluidflow_build(net, 1, &pipe);
	int c[] = {
		1, 2,
		2, 3,
		3, 4,
		4, 5,
		5, 6,
		6, 7,
		7, 8,
		8, 9,
		9, 10,
		11, 10,
		12, 11,
	};
	int i;
	for (i=0;i<sizeof(c)/sizeof(c[0]);i+=2) {
		fluidflow_connect(net, c[i], c[i+1], 0);
	}
	fluidflow_dump(net);

	int fluid[12] = {0};
	for (i=0;i<20;i++) {
		if (i % 2 == 1)
			fluidflow_block(net, 2);
		update(net, fluid);
	}

	fluidflow_teardown(net, 1);
	fluidflow_delete(net);
	return 0;
}

#endif
