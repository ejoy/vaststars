#pragma once

#include "../util/flatmap.h"

struct statistics {
    void finish_recipe(world& w, uint16_t id, bool manual);
    flatmap<uint16_t, uint32_t> production;
    flatmap<uint16_t, uint32_t> manual_production;
    flatmap<uint16_t, uint32_t> consumption;
	uint64_t generate_power = 0;
	uint64_t consume_power = 0;
};
