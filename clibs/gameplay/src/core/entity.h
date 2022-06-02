#pragma once

#include <stdint.h>

enum COMPONENT {
	COMPONENT_ENTITY = 1,
	COMPONENT_CHEST = 2,
	COMPONENT_ASSEMBLING = 3,
	COMPONENT_LABORATORY = 4,
	COMPONENT_INSERTER = 5,
	COMPONENT_CAPACITANCE = 6,
	COMPONENT_BURNER = 7,
	COMPONENT_CHIMNEY = 8,
	COMPONENT_CONSUMER = 9,
	TAG_GENERATOR = 10,
	TAG_SOLAR_PANEL = 11,
	TAG_ACCUMULATOR = 12,
	TAG_POLE = 13,
	TAG_POWER = 14,
	COMPONENT_FLUIDBOX = 15,
	COMPONENT_FLUIDBOXES = 16,
	TAG_PUMP = 17,
	TAG_MINING = 18,
	COMPONENT_ROAD = 19,
	COMPONENT_STATION = 20,
	COMPONENT_SAVE_FLUIDFLOW = 21,
};

struct entity {
	uint8_t x;
	uint8_t y;
	uint16_t prototype;
	uint8_t direction;
};

struct chest {
	uint16_t container;
};

struct assembling {
	uint16_t recipe;
	uint16_t fluidbox_in;
	uint16_t fluidbox_out;
	uint16_t container;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct laboratory {
	uint16_t tech;
	uint16_t container;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct inserter {
	uint16_t input_container;
	uint16_t output_container;
	uint16_t hold_item;
	uint16_t hold_amount;
	uint16_t progress;
	uint8_t status;
};

struct capacitance {
	uint32_t shortage;
	uint8_t network;
};

struct burner {
	uint16_t recipe;
	uint16_t container;
	uint16_t progress;
};

struct chimney {
	uint16_t recipe;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};

struct consumer {
	uint8_t low_power;
};

struct fluidbox {
	uint16_t fluid;
	uint16_t id;
};

struct fluidboxes {
	struct fluidbox in[4];
	struct fluidbox out[3];
};

struct road {
	uint16_t road_type;
	uint16_t coord;
};

struct station {
	uint16_t id;
	uint16_t coord;
};

struct save_fluidflow {
	uint16_t fluid;
	uint16_t id;
	uint32_t volume;
};
