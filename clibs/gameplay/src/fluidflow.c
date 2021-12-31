#include "fluidflow.h"
 
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
 
#define PIPE_DEFAULT 8
#define PIPE_MAX 0xffff
#define PIPE_CONNECTION 4
#define PIPE_INVALID_CONNECTION 0xffff
#define FIXSHIFT 256
 
struct pipe {
	int id;
	int fluid;
	int area;
	int capacity;
	int base_level;
	int pumping_speed;	// 0 : pipe , >0 pump
	unsigned short uplink[PIPE_CONNECTION];	// index
	unsigned short downlink[PIPE_CONNECTION];
	int reservation[PIPE_CONNECTION];
};
 
struct fluidflow_network {
	struct pipe *p;
	unsigned short *order;
	int *blocking;
	int n;
	int cap;
	int last_query;
	int blocking_n;
	int blocking_cap;
};
 
void
fluidflow_delete(struct fluidflow_network *net) {
	if (net == NULL)
		return;
	free(net->p);
	free(net->order);
	free(net);
}
 
struct fluidflow_network *
fluidflow_new() {
	struct fluidflow_network *net = (struct fluidflow_network *)malloc(sizeof(*net));
	if (net == NULL)
		return NULL;
	net->p = NULL;
	net->order = NULL;
	net->n = 0;
	net->cap = PIPE_DEFAULT;
	net->p = (struct pipe *)malloc(net->cap * sizeof(struct pipe));
	if (net->p == NULL) {
		fluidflow_delete(net);
		return NULL;
	}
	net->last_query = 0;
	net->blocking = NULL;
	net->blocking_n = 0;
	net->blocking_cap = 0;
	return net;
}
 
 
int
check_duplicate(struct fluidflow_network *net, int id) {
	int i;
	for (i=0;i<net->n;i++) {
		if (net->p[i].id == id)
			return 1;
	}
	return 0;
}
 
static inline void
clear_order(struct fluidflow_network *net) {
	if (net->order) {
		free(net->order);
		net->order = NULL;
	}
}
 
int
fluidflow_build(struct fluidflow_network *net, int id, struct fluid_box *box) {
	clear_order(net);
	if (net->n >= net->cap) {
		int cap = net->cap * 2;
		if (cap > PIPE_MAX)
			return 1;
		struct pipe * new_pipe = (struct pipe *)malloc(cap * sizeof(struct pipe));
		if (new_pipe == NULL) {
			free(new_pipe);
			return 1;
		}
		memcpy(new_pipe, net->p, net->n * sizeof(struct pipe));
		free(net->p);
		net->p = new_pipe;
		net->cap = cap;
	}
	if (check_duplicate(net, id))	// not necessary
		return 1;
	struct pipe *p = &net->p[net->n++];
	p->id = id;
	p->fluid = 0;
	p->area = box->area;
	p->capacity = box->area * box->height;
	p->base_level = box->base_level * FIXSHIFT;
	p->pumping_speed = box->pumping_speed;
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
 
static inline int
find_id(struct fluidflow_network *net, int id) {
	int i;
	for (i=0;i<net->n;i++) {
		if (net->p[i].id == id) {
			return i;
		}
	}
	return PIPE_INVALID_CONNECTION;
}
 
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
	clear_order(net);
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
	if (idx < net->n - 1) {
		for (i=0;i<idx;i++) {
			adjust_connection(&net->p[i], idx);
		}
		for (i=idx+1;i<net->n;i++) {
			adjust_connection(&net->p[i], idx);
		}
		memmove(&net->p[idx], &net->p[idx+1], (net->n - idx - 1) * sizeof(struct pipe));
	}
	--net->n;
	net->last_query = 0;
	return 0;
}
 
static int
add_downlink(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->downlink[i] == idx) {
			// already added
			return 0;
		}
		if (p->downlink[i] == PIPE_INVALID_CONNECTION) {
			p->downlink[i] = idx;
			return 0;
		}
	}
	return 1;
}
 
static int
add_uplink(struct pipe *p, int idx) {
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == idx) {
			// already added
			return 0;
		}
		if (p->uplink[i] == PIPE_INVALID_CONNECTION) {
			p->uplink[i] = idx;
			p->reservation[i] = 0;
			return 0;
		}
	}
	return 1;
}
 
static int
add_connection(struct fluidflow_network *net, int from_idx, int to_idx) {
	struct pipe *from_pipe = &net->p[from_idx];
	struct pipe *to_pipe = &net->p[to_idx];
	if (add_downlink(from_pipe, to_idx))
		return 1;
	if (add_uplink(to_pipe, from_idx))
		return 1;
	if (from_pipe->pumping_speed == 0 && to_pipe->pumping_speed == 0) {
		// not pump
		if (add_downlink(to_pipe, from_idx))
			return 1;
		if (add_uplink(from_pipe, to_idx))
			return 1;
	}
	return 0;
}
 
#define CACHE_SIZE 2039
 
static inline int
index_hash(int v) {
	return ((unsigned int)(v * 2654435761)) % CACHE_SIZE;
}
 
static int
find_id_cache(struct fluidflow_network *net, unsigned short cache[CACHE_SIZE], int id) {
	int h = index_hash(id);
	unsigned short idx = cache[h];
	if (idx == PIPE_INVALID_CONNECTION || net->p[idx].id != id) {
		idx = find_id(net, id);
		cache[h] = idx;
	}
	return idx;
}
 
static int
connect(struct fluidflow_network *net, unsigned short cache[CACHE_SIZE], int from, int to) {
	int from_idx = find_id_cache(net, cache, from);
	int to_idx = find_id_cache(net, cache, to);
	if (from_idx == PIPE_INVALID_CONNECTION || to_idx == PIPE_INVALID_CONNECTION)
		return 1;
	return add_connection(net, from_idx, to_idx);
}
 
static inline void
init_cache(unsigned short cache[CACHE_SIZE]) {
	int i;
	for (i=0;i<CACHE_SIZE;i++) {
		cache[i] = PIPE_INVALID_CONNECTION; 
	}
}
 
int
fluidflow_connect(struct fluidflow_network *net, int n, int *id) {
	unsigned short cache[CACHE_SIZE];
	int i;
	init_cache(cache);
	for (i=0;i<n;i++) {
		if (connect(net, cache, id[i*2], id[i*2+1]))
			return 1;
	}
	return 0;
}
 
void
fluidflow_dump(struct fluidflow_network *net) {
	int i, j;
	for (i=0;i<net->n;i++) {
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
}
 
static struct fluid_state *
get_state(struct pipe *p, struct fluid_state *output) {
	output->volume = p->fluid;
	output->space = p->capacity - p->fluid;
	return output;
}
 
struct fluid_state *
fluidflow_query(struct fluidflow_network *net, int id, struct fluid_state *output) {
	if (net->last_query < net->n) {
		struct pipe *guess = &net->p[net->last_query];
		if (guess->id == id) {
			++net->last_query;
			return get_state(guess, output);
		}
	}
	int idx = find_id(net, id);
	if (idx == PIPE_INVALID_CONNECTION)
		return NULL;
	net->last_query = idx + 1;
	return get_state(&net->p[idx], output);
}
 
static int
find_import(struct fluidflow_network *net, int id) {
	unsigned short *order = net->order;
	if (order == NULL) {
		return find_id(net, id);
	}
	int i;
	for (i=net->n-1;i>=0;i--) {
		if (id == net->p[order[i]].id) {
			return order[i];
		}
	}
	return PIPE_INVALID_CONNECTION;
}
 
static int
find_export(struct fluidflow_network *net, int id) {
	unsigned short *order = net->order;
	if (order == NULL) {
		return find_id(net, id);
	}
	int i;
	for (i=0;i<net->n;i++) {
		if (id == net->p[order[i]].id) {
			return order[i];
		}
	}
	return PIPE_INVALID_CONNECTION;
}
 
static int
set_fluid(struct fluidflow_network *net, int idx, int fluid) {
	if (idx == PIPE_INVALID_CONNECTION)
		return -1;
	struct pipe *p = &net->p[idx];
	p->fluid = fluid;
	if (p->fluid <= 0) {
		p->fluid = 0;
		return 0;
	} else if (p->fluid > p->capacity) {
		p->fluid = p->capacity;
	}
	return p->fluid;
}
 
int
fluidflow_import(struct fluidflow_network *net, int id, int fluid) {
	int idx = find_import(net, id);
	return set_fluid(net, idx, fluid);
}
 
int
fluidflow_export(struct fluidflow_network *net, int id, int fluid) {
	int idx = find_export(net, id);
	return set_fluid(net, idx, fluid);
}
 
void
fluidflow_block(struct fluidflow_network *net, int id) {
	if (net->blocking == NULL) {
		if (net->blocking_cap == 0) {
			net->blocking_cap = net->n;
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
reservation(struct fluidflow_network *net, int from, int to, int r) {
	struct pipe *p = &net->p[to];
	int i;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == from) {
			p->reservation[i] = r;
			return;
		}
	}
}
 
static void
attempt_flow(struct fluidflow_network *net, int idx) {
	struct pipe *p = &net->p[idx];
	if (is_blocking(net, p->id)) {
		return;
	}
 
	int total = 0;
	int i;
	int f[PIPE_CONNECTION];
	int fluid = p->fluid;
	int level = fluid * FIXSHIFT / p->area;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->downlink[i] == PIPE_INVALID_CONNECTION)
			break;
		struct pipe *to = &net->p[p->downlink[i]];
		int pumping_speed = to->pumping_speed;
		if (pumping_speed > 0) {
			// It's pump
			f[i] = (pumping_speed > fluid) ? fluid : pumping_speed;
		} else {
			int to_level = to->fluid * FIXSHIFT / to->area;
			if (level + p->base_level > to_level + to->base_level) {
				f[i] = (level + p->base_level - to_level - to->base_level) / FIXSHIFT / 2 ;
			} else {
				f[i] = 0;
			}
		}
		total += f[i];
	}
	int n = i;
	if (total > fluid) {
		int radio = FIXSHIFT * fluid / total;
		for (i=0;i<n-1;i++) {
			f[i] = f[i] * radio / FIXSHIFT;
			total -= f[i];
		}
		f[i] = total;
	}
	for (i=0;i<n;i++) {
//		struct pipe *to = &net->p[p->downlink[i]];
		if (f[i] > 0) {
			reservation(net, idx, p->downlink[i], f[i]);
		}
	}
}
 
static void
reservation_fluid(struct fluidflow_network *net) {
	int i;
	// calc flow
	for (i=0;i<net->n;i++) {
		attempt_flow(net, i);
	}
}
 
struct bitset {
	unsigned int bits[(PIPE_MAX+7)/8];
};
 
static inline void
bitset_init(struct bitset *s, int n) {
	int c = (n + 7)/8;
	memset(s->bits, 0, c);
}
 
static inline int
bitset_isset(struct bitset *s, int idx) {
	int n = idx / 8;
	return s->bits[n] & (1 << (idx % 8));
}
 
static inline void
bitset_set(struct bitset *s, int idx) {
	int n = idx / 8;
	s->bits[n] |= (1 << (idx % 8));
}
 
static unsigned short *
prev_order(struct fluidflow_network *net) {
	if (net->order)
		return net->order;
	int i;
	unsigned short *order = (unsigned short *)malloc(net->n * sizeof(unsigned short));
	for (i=0;i<net->n;i++) {
		order[i] = i;
	}
	net->order = order;
	return order;
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
		if (!bitset_isset(set, to_idx) && flow_to(&net->p[to_idx], idx)) {
			return to_idx;
		}
	}
	return PIPE_INVALID_CONNECTION;
}
 
static void
print_order(struct fluidflow_network *net) {
	int i;
	for (i=0;i<net->n;i++) {
		int idx = net->order[i];
		printf("%d -> ", net->p[idx].id);
	}
	printf("\n");
}
 
static void
print_reservation(struct fluidflow_network *net) {
	int i, j;
	for (i=0;i<net->n;i++) {
		for (j=0;j<PIPE_CONNECTION;j++) {
			if (net->p[i].uplink[j] == PIPE_INVALID_CONNECTION)
				break;
			if (net->p[i].reservation[j] > 0)
				printf("(%d->%d)/%d ", net->p[net->p[i].uplink[j]].id, net->p[i].id, net->p[i].reservation[j]);
		}
	}
	printf("\n");
}
 
static void
topology_sort(struct fluidflow_network *net) {
	int n = net->n;
	struct bitset set;
	bitset_init(&set, n);
	unsigned short *order = prev_order(net);
	int idx=0;
	while (idx < n) {
		int current = order[idx];
		int downstream = check_order(net, current, &set);
		if (downstream == PIPE_INVALID_CONNECTION) {
			bitset_set(&set, current);
			++idx;
		} else {
			order[idx] = downstream;
			int i;
			for (i=idx+1;i<net->n;i++) {
				if (order[i] == downstream) {
					order[i] = current;
					break;
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
flow(struct fluidflow_network *net, int idx) {
	struct pipe *p = &net->p[idx];
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
			int radio = fluid * FIXSHIFT / total;
			p->fluid = 0;
			int total = fluid;
			for (i=0;i<n-1;i++) {
				f[i] = f[i] * radio / FIXSHIFT;
				total -= f[i];
			}
			f[i] = total;
		} else {
			p->fluid -= total;
		}
		for (i=0;i<n;i++) {
			if (f[i] > 0) {
//				printf("Add %d->%d, %d+%d->%d\n", p->id, net->p[p->downlink[i]].id,
//					net->p[p->downlink[i]].fluid, f[i], net->p[p->downlink[i]].fluid + f[i]);
				struct pipe *to = &net->p[p->downlink[i]];
				to->fluid += f[i];
			}
		}
	}
 
	int space = p->capacity - p->fluid;
//	printf("Space %d %d :", p->id, space);
	total = 0;
	for (i=0;i<PIPE_CONNECTION;i++) {
		if (p->uplink[i] == PIPE_INVALID_CONNECTION) {
			break;
		}
//		printf("(%d:%g)", net->p[p->uplink[i]].id,  p->reservation[i]);
		total += p->reservation[i];
	}
//	printf("\n");
	if (total > space) {
		// space is smaller than fluid
		n = i;
		int radio = space * FIXSHIFT / total;
//		printf("Realoc %d radio = %g total = %d space = %d\n", p->id, (float) radio / FIXSHIFT, total, space );
		for (i=0;i<n;i++) {
			p->reservation[i] = p->reservation[i] * radio / FIXSHIFT;
		}
	}
}
 
void
fluidflow_update(struct fluidflow_network *net) {
	sort_blocking(net);
	reservation_fluid(net);
//	print_reservation(net);
	topology_sort(net);
//	print_order(net);
	
	int i;
	for (i=0;i<net->n;i++) {
		int idx = net->order[i];
		flow(net, idx);
	}
	reset_blocking(net);
}
 
#ifdef TEST_MAIN
 
#include <stdio.h>
 
static void
update(struct fluidflow_network *net, int fluid[]) {
	fluidflow_import(net, 1, fluid[0] + 20000);
	fluidflow_import(net, 1, fluid[11] + 20000);
	fluidflow_update(net);
	int i;
	for (i=1;i<=12;i++) {
		struct fluid_state s;
		fluid[i-1] = fluidflow_query(net, i, &s)->volume;
		printf("[%d]:%d ", i, fluid[i-1]);
	}
	printf("\n");
}
 
int
main() {
	struct fluidflow_network *net = fluidflow_new();
	struct fluid_box bump = {
		1, // area
		200 * 100,	// height
		0,	// base_level
		200 * 100,	// pumping_speed
	};
	struct fluid_box pipe = {
		2,	// area
		100 * 100,	// height
		0,
		0,
	};
	struct fluid_box tank = {
		50,	// area
		100 * 100,	// height
		0,
		0,
	};
	fluidflow_build(net, 1, &bump);
	fluidflow_build(net, 2, &pipe);
	fluidflow_build(net, 3, &pipe);
	fluidflow_build(net, 4, &pipe);
	fluidflow_build(net, 5, &pipe);
	fluidflow_build(net, 6, &pipe);
	fluidflow_build(net, 7, &pipe);
	fluidflow_build(net, 8, &pipe);
	fluidflow_build(net, 9, &tank);
	fluidflow_build(net, 10, &tank);
	fluidflow_build(net, 11, &tank);
	fluidflow_build(net, 12, &bump);
	int c[] = {
		1, 2,
		2, 3,
		3, 4,
		4, 5,
		5, 6,
		6, 7,
		7, 8,
		8, 9,
		4, 10,
		4, 11,
		12, 10,
	};
	fluidflow_connect(net, 11, c);
	fluidflow_dump(net);
	int i;
	int fluid[12] = {0};
	for (i=0;i<10;i++) {
		if (i % 2 == 1)
			fluidflow_block(net, 2);
		update(net, fluid);
	}
	fluidflow_teardown(net, 1);
	fluidflow_delete(net);
	return 0;
}
 
#endif
