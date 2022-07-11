#pragma once

#include <stdint.h>

namespace vaststars {

namespace ecs {

struct REMOVED {};

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

struct generator {};

struct accumulator {};

struct fluidbox {
	uint16_t fluid;
	uint16_t id;
};

struct fluidboxes {
	struct fluidbox in[4];
	struct fluidbox out[3];
};

struct pump {};

struct mining {};

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

struct solar_panel {};

struct base {};

struct manual {
	uint16_t recipe;
	uint16_t speed;
	uint8_t status;
	int32_t progress;
};


}

struct ecs_component_id {
	inline static int id = 0x80000000;
	inline static int gen() {
		return id++;
	}
};

}

using namespace vaststars;

namespace ecs_api {

template <typename T> struct component {};

#define ECS_COMPONENT(NAME) \
template <> struct component<ecs::##NAME> { \
	static inline const int id = ecs_component_id::gen(); \
	static inline const char name[] = #NAME; \
};

ECS_COMPONENT(REMOVED)
ECS_COMPONENT(entity)
ECS_COMPONENT(chest)
ECS_COMPONENT(assembling)
ECS_COMPONENT(laboratory)
ECS_COMPONENT(inserter)
ECS_COMPONENT(capacitance)
ECS_COMPONENT(burner)
ECS_COMPONENT(chimney)
ECS_COMPONENT(consumer)
ECS_COMPONENT(generator)
ECS_COMPONENT(accumulator)
ECS_COMPONENT(fluidbox)
ECS_COMPONENT(fluidboxes)
ECS_COMPONENT(pump)
ECS_COMPONENT(mining)
ECS_COMPONENT(road)
ECS_COMPONENT(station)
ECS_COMPONENT(save_fluidflow)
ECS_COMPONENT(solar_panel)
ECS_COMPONENT(base)
ECS_COMPONENT(manual)

#undef ECS_COMPONENT

}
