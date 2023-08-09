#pragma once

#include <stdint.h>
#include "util/component.h"

struct building {
    uint16_t chest;
    uint8_t w;
    uint8_t h;
};
struct world;

building createBuildingCache(world& w, ecs::building& b, uint16_t chest);