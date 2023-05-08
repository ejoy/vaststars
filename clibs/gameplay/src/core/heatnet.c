#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <limits.h>

#include "heatnet.h"

#define MAX_PIPE_CONNECTION 1024

struct heat_pipe {
	int id;
	uint32_t energy;
	int connection_index;

	uint32_t input;
	uint32_t output;

	// cap := max_temperature * specific_heat
	uint32_t cap;

	uint32_t specific_heat;
	uint32_t power;
};

struct heat_connection {
	int from;
	int to;
};

struct heat_network {
	struct heat_pipe *p;
	struct heat_connection *c;
	int pipe_n;
	int connection_n;
	int pipe_cap;
	int connection_cap;
	int sorted;
};

struct heat_network *
heatnet_new() {
	struct heat_network * H = (struct heat_network *)malloc(sizeof(*H));
	memset(H, 0, sizeof(*H));
	return H;
}

void
heatnet_delete(struct heat_network *H) {
	if (H == NULL)
		return;
	free(H->p);
	free(H->c);
	free(H);
}

// 1: fail
// 0: succ
void
heatnet_build(struct heat_network *H, int id, struct heat_box *box) {
	assert(id >= 0);
	if (H->pipe_n >= H->pipe_cap) {
		int cap = (H->pipe_cap + 1) * 3 / 2;
		H->p = (struct heat_pipe *)realloc(H->p, cap * sizeof(struct heat_pipe));
		assert(H->p != NULL);
		H->pipe_cap = cap;
	}
	H->sorted = 0;
	struct heat_pipe *P = &H->p[H->pipe_n++];
	P->id = id;
	P->energy = 0;
	P->connection_index = 0;
	P->input = 0;
	P->output = 0;
	uint64_t cap = (uint64_t)box->max_temperature * box->specific_heat;
	assert(cap <= UINT_MAX);
	P->cap = (uint32_t)cap;
	P->specific_heat = box->specific_heat;
	P->power = box->power;
}

static void
add_connection(struct heat_network *H, int from, int to) {
	if (H->connection_n >= H->connection_cap) {
		int cap = (H->connection_cap + 1) * 3 / 2;
		H->c = (struct heat_connection *)realloc(H->c, cap * sizeof(struct heat_connection));
		assert(H->c != NULL);
		H->connection_cap = cap;
	}
	H->sorted = 0;
	struct heat_connection *C = &H->c[H->connection_n++];
	C->from = from;
	C->to = to;
}

void
heatnet_connect(struct heat_network *H, int from, int to) {
	assert(from != to);
	add_connection(H, from, to);
	add_connection(H, to, from);
}

static int
comp_pipe(const void *a, const void *b) {
	const struct heat_pipe *pa = (const struct heat_pipe *)a;
	const struct heat_pipe *pb = (const struct heat_pipe *)b;
	return pa->id - pb->id;
}

static int
comp_connection(const void *a, const void *b) {
	const struct heat_connection * ca = (const struct heat_connection *)a;
	const struct heat_connection * cb = (const struct heat_connection *)b;
	if (ca->from == cb->from)
		return ca->to - cb->to;
	else
		return ca->from - cb->from;
}

static void
sort_pipe_(struct heat_network *H) {
	qsort(H->p, H->pipe_n, sizeof(struct heat_pipe), comp_pipe);
	// remove invalid connection
	int i,j;
	for (i=0,j=0;i<H->connection_n;i++) {
		struct heat_connection *c = &H->c[i];
		if (c->from >=0 && c->to >= 0) {
			if (i != j) {
				H->c[j] = H->c[i];
			}
			++j;
		}
	}
	H->connection_n = j;
	qsort(H->c, H->connection_n, sizeof(struct heat_connection), comp_connection);
	H->sorted = 1;
}

static inline void
sort_pipe(struct heat_network *H) {
	if (H->sorted)
		return;
	sort_pipe_(H);
}

static struct heat_pipe *
lookup_pipe(struct heat_network *H, int id, int begin) {
	int end = H->pipe_n;
	while (begin < end) {
		int mid = (begin + end) / 2;
		struct heat_pipe *P = &H->p[mid];
		if (P->id == id)
			return P;
		if (P->id < id) {
			begin = mid + 1;
		} else {
			end = mid;
		}
	}
	return NULL;
}

void
heatnet_teardown(struct heat_network *H, int id) {
	int i;
	for (i=0;i<H->pipe_n;i++) {
		if (H->p[i].id == id)
			break;
	}
	if (i == H->pipe_n)
		return;
	H->sorted = 0;
	H->p[i] = H->p[--H->pipe_n];
	for (i=0;i<H->connection_n;i++) {
		struct heat_connection *c = &H->c[i];
		if (c->from == id || c->to == id) {
			// set invalid, removed during sort_pipe
			c->from = -1;
			c->to = -1;
		}
	}
}

struct heat_state *
heatnet_query(struct heat_network *H, int id, struct heat_state *output) {
	sort_pipe(H);
	struct heat_pipe *P = lookup_pipe(H, id, 0);
	if (P == NULL)
		return NULL;

	output->energy = P->energy;
	output->temperature = (float)P->energy / P->specific_heat;
	output->box.max_temperature = P->cap / P->specific_heat;
	output->box.specific_heat = P->specific_heat;
	output->box.power = P->power;
	
	return output;
}

int
heatnet_set(struct heat_network *H, int id, int energy) {
	sort_pipe(H);
	struct heat_pipe *P = lookup_pipe(H, id, 0);
	if (P == NULL)
		return 0;
	if (energy <= 0) {
		P->energy = 0;
		return 0;
	}
	if (energy >= P->cap) {
		P->energy = P->cap;
		return P->cap;
	}
	P->energy = energy;
	return energy;
}

static void
reset_pipe(struct heat_network *H) {
	int i,j;
	for (i=0,j=0;i<H->pipe_n;i++) {
		struct heat_pipe *P = &H->p[i];
		P->input = 0;
		P->output = 0;
		while (j < H->connection_n) {
			if (H->c[j].from >= P->id)
				break;
			j++;
		}
		P->connection_index = j;
	}
}

// 16:16 fix number, 0x10000 is 1 degree
static inline uint32_t
get_temp(struct heat_pipe *P) {
	uint64_t energy_fix = (uint64_t) P->energy << 16;
	return (uint32_t)(energy_fix / P->specific_heat);
}

#define ONE_DEGREE 0x10000

static int
filter_lower_temperature(struct heat_network *H, uint32_t temp_threshold, int n, int index[]) {
	int from = 0;
	int to = 0;
	for (from = 0;from < n; from ++) {
		struct heat_pipe *P = &H->p[index[from]];
		uint32_t dest_temp = get_temp(P);
		if (temp_threshold > dest_temp && P->energy < P->cap) {
			index[to] = index[from];
			++to;
		}
	}
	return to;
}

static void
transfer_heat(uint32_t max_energy_transfer, uint32_t src_temp, struct heat_pipe *src, struct heat_pipe * dest) {
	uint64_t max_energy_transfer_fix = (uint64_t)max_energy_transfer << 16;
	uint32_t delta_temp = (uint32_t)(max_energy_transfer_fix / src->specific_heat);
	uint32_t temp_rise = (uint32_t)(max_energy_transfer_fix / dest->specific_heat);
	uint32_t temp_dest = get_temp(dest);

	if (src_temp > temp_dest + temp_rise + delta_temp + ONE_DEGREE) {
		src->output += max_energy_transfer;
		dest->input += max_energy_transfer;
	} else {
		uint32_t delta = (uint32_t)((uint64_t)(src_temp - temp_dest - ONE_DEGREE) * dest->specific_heat / (src->specific_heat + dest->specific_heat));
		uint32_t delta_energy = (uint32_t)(((uint64_t)delta * src->specific_heat) >> 16);
		src->output += delta_energy;
		dest->input += delta_energy;
	}
}

static void
heat_conduction(struct heat_network *H, int n, int index[]) {
	uint32_t temp = get_temp(&H->p[index[0]]);
	if (temp <= ONE_DEGREE)
		return;
	n = filter_lower_temperature(H, temp - ONE_DEGREE, n-1, index + 1);
	if (n == 0)
		return;

	struct heat_pipe *src = &H->p[index[0]];
	uint32_t max_energy_transfer = src->power;
	int i;
	for (i=0;i<n;i++) {
		transfer_heat(max_energy_transfer, temp, src, &H->p[index[i+1]]);
	}
}

void
heatnet_update(struct heat_network *H) {
	sort_pipe(H);
	reset_pipe(H);
	int i,j;
	for (i=0;i<H->pipe_n;i++) {
		int index[MAX_PIPE_CONNECTION];
		struct heat_pipe *P = &H->p[i];
		index[0] = i;
		j = 0;
		int last = 0;
		int connection_index = P->connection_index;
		while (j < MAX_PIPE_CONNECTION && connection_index + j < H->connection_n) {
			struct heat_connection *c = &H->c[connection_index + j];
			if (c->from != P->id)
				break;
			struct heat_pipe * to = lookup_pipe(H, c->to, last);
			if (to) {
				last = to - H->p;
				index[j+1] = last;
				j++;
			}
		}
		if (j > 0)
			heat_conduction(H, j+1, index);
	}
	// heat flow
	for (i=0;i<H->pipe_n;i++) {
		struct heat_pipe *P = &H->p[i];
		P->energy += P->input;
		if (P->energy < P->output) {
			P->energy = 0;
		} else {
			P->energy -= P->output;
			if (P->energy > P->cap) {
				P->energy = P->cap;
			}
		}
	}
}

#ifdef HEATNET_MAIN

#include <stdio.h>

static void
print_heatnet(struct heat_network *H) {
	int i;
	for (i=0;i<6;i++) {
		struct heat_state state;
		heatnet_query(H, i, &state);
		printf("[%d] %f ", i, state.temperature);
	}
	printf("\n");
}

int
main() {
	struct heat_network * H = heatnet_new();
	struct heat_box box = {
		1000,	// max_temperature
		20000,	// specific_heat, 20000J / degree
		30000,	// power, max energy transfer / tick
	};
	heatnet_build(H, 0, &box);
	heatnet_build(H, 1, &box);
	heatnet_build(H, 2, &box);
	heatnet_build(H, 3, &box);
	heatnet_build(H, 4, &box);
	heatnet_build(H, 5, &box);

//             0
//             |
//        1 -- 2 -- 3 -- 5
//             |
//             4

	heatnet_connect(H, 0,2);
	heatnet_connect(H, 1,2);
	heatnet_connect(H, 3,2);
	heatnet_connect(H, 4,2);
	heatnet_connect(H, 4,5);

	heatnet_set(H, 2, 10000000);

	struct heat_state state;
	heatnet_query(H, 2, &state);

	printf("energy = %d\n", (int)state.energy);
	printf("temperature = %f\n", state.temperature);
	printf("max_temperature = %d\n", (int)state.box.max_temperature);
	printf("specific_heat = %d\n", (int)state.box.specific_heat);
	printf("power = %d\n", (int)state.box.power);

	int i;

	for (i=0;i<200;i++) {
		print_heatnet(H);
		heatnet_update(H);
	}

	heatnet_delete(H);
	return 0;
}

#endif