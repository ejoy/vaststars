#pragma once

#include "ecs/select.h"
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

}

using namespace vaststars;

namespace ecs_api {

#define ECS_COMPONENT(NAME, ID) \
template <> struct component<ecs::NAME> { \
	static inline constexpr int id = 0x80000000 + ID; \
	static inline constexpr char name[] = #NAME; \
	static inline constexpr bool tag = false; \
};

#define ECS_TAG(NAME, ID) \
template <> struct component<ecs::NAME> { \
	static inline constexpr int id = 0x80000000 + ID; \
	static inline constexpr char name[] = #NAME; \
	static inline constexpr bool tag = true; \
};

ECS_COMPONENT(REMOVED, 0)
ECS_COMPONENT(entity,1)
ECS_COMPONENT(chest,2)
ECS_COMPONENT(assembling,3)
ECS_COMPONENT(laboratory,4)
ECS_COMPONENT(inserter,5)
ECS_COMPONENT(capacitance,6)
ECS_COMPONENT(burner,7)
ECS_COMPONENT(chimney,8)
ECS_COMPONENT(consumer,9)
ECS_TAG(generator,10)
ECS_TAG(accumulator,11)
ECS_COMPONENT(fluidbox,12)
ECS_COMPONENT(fluidboxes,13)
ECS_TAG(pump,14)
ECS_TAG(mining,15)
ECS_COMPONENT(road,16)
ECS_COMPONENT(station,17)
ECS_COMPONENT(save_fluidflow,18)
ECS_TAG(solar_panel,19)
ECS_TAG(base,20)
ECS_COMPONENT(manual,21)

#undef ECS_COMPONENT

}
