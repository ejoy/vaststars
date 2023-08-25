#pragma once

struct fluidflow_network;
 
struct fluid_box {
	int capacity;
	int height;
	int base_level;
	int pumping_speed;	// 0 : pipe , >0 pump
};
 
struct fluid_state {
	int id;
	int volume;
	int flow;
	int blocking;
	struct fluid_box box;
};
 
struct fluidflow_network * fluidflow_new();
void fluidflow_delete(struct fluidflow_network *);
int fluidflow_build(struct fluidflow_network *net, int id, struct fluid_box *box);
int fluidflow_teardown(struct fluidflow_network *net, int id);
void fluidflow_resetconnect(struct fluidflow_network *net);
int fluidflow_connect(struct fluidflow_network *net, int from, int to, int oneway);
void fluidflow_dump(struct fluidflow_network *net);
 
int fluidflow_size(struct fluidflow_network *net);
struct fluid_state * fluidflow_index(struct fluidflow_network *net, int idx, struct fluid_state *output);
struct fluid_state * fluidflow_query(struct fluidflow_network *net, int id, struct fluid_state *output);
int fluidflow_set(struct fluidflow_network *net, int id, int fluid, int multiple);
void fluidflow_block(struct fluidflow_network *net, int id);
void fluidflow_update(struct fluidflow_network *net);
