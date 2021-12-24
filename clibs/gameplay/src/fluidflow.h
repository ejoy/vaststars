#pragma once

struct fluidflow_network;
 
struct fluid_box {
	float area;
	float height;	// capacity = area * height
	float base_level;
	float pumping_speed;	// 0 : pipe , >0 pump
};

struct fluid_state {
	float volume;
	float space;
};

struct fluidflow_network * fluidflow_new();
void fluidflow_delete(struct fluidflow_network *);
int fluidflow_build(struct fluidflow_network *net, int id, struct fluid_box *box);
int fluidflow_teardown(struct fluidflow_network *net, int id);
int fluidflow_connect(struct fluidflow_network *net, int n, int *id);
void fluidflow_dump(struct fluidflow_network *net);
 
struct fluid_state * fluidflow_query(struct fluidflow_network *net, int id, struct fluid_state *output);
float fluidflow_import(struct fluidflow_network *net, int id, float fluid);
float fluidflow_export(struct fluidflow_network *net, int id, float fluid);
void fluidflow_block(struct fluidflow_network *net, int id);
void fluidflow_update(struct fluidflow_network *net);
 