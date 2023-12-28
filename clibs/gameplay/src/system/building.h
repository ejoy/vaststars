#pragma once

#include <stdint.h>
#include "util/component.h"

struct building {
    uint32_t pickup_time;
    uint32_t place_time;
    uint16_t chest;
    uint8_t w;
    uint8_t h;
};
struct world;

building createBuildingCache(world& w, component::building& b, uint16_t chest);
