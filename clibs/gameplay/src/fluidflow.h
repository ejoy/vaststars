#pragma once

struct fluidflow_network;
 
struct fluid_box {
	int capacity;
	int height;
	int base_level;
	int pumping_speed;	// 0 : pipe , >0 pump
};
 
struct fluid_state {
	int volume;
	int space;
};
 
struct fluidflow_network * fluidflow_new();
void fluidflow_delete(struct fluidflow_network *);
int fluidflow_build(struct fluidflow_network *net, int id, struct fluid_box *box);
int fluidflow_teardown(struct fluidflow_network *net, int id);
int fluidflow_connect(struct fluidflow_network *net, int n, int *id);
void fluidflow_dump(struct fluidflow_network *net);
 
struct fluid_state * fluidflow_query(struct fluidflow_network *net, int id, struct fluid_state *output);
int fluidflow_import(struct fluidflow_network *net, int id, int fluid);
int fluidflow_export(struct fluidflow_network *net, int id, int fluid);
void fluidflow_block(struct fluidflow_network *net, int id);
void fluidflow_update(struct fluidflow_network *net);
