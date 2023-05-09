#pragma once

#include <stdint.h>

struct heat_network;
 
struct heat_box {
	uint16_t max_temperature;	// max degree of temperature (Initial temperature and energy is 0)
	uint32_t specific_heat;	// energy (J) per degree of temperature
	uint32_t power;	// energy conduction (J) per tick
};
 
struct heat_state {
	int energy;	// Current energy (J)
	float temperature;	// Current temperature (degree)
	struct heat_box box;
};

struct heat_network;

struct heat_network * heatnet_new();
void heatnet_delete(struct heat_network *net);
void heatnet_build(struct heat_network *net, int id, struct heat_box *box);
void heatnet_connect(struct heat_network *net, int from, int to);
void heatnet_teardown(struct heat_network *net, int id);

struct heat_state * heatnet_query(struct heat_network *net, int id, struct heat_state *output);
int heatnet_set(struct heat_network *net, int id, int energy);
void heatnet_update(struct heat_network *net);
