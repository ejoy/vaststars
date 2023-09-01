#pragma once

#include "util/component.h"
#include "system/building.h"
#include "flatmap.h"
#include <bee/nonstd/bit.h>
#include <vector>
#include <map>

struct airport {
    std::vector<airport_berth> hub;
    std::vector<airport_berth> chest_red;
    std::vector<airport_berth> chest_blue;
    airport_berth homeBerth;
    uint8_t width;
    uint8_t height;
    uint16_t item;
    uint16_t prototype;
    ecs::capacitance* capacitance;
    bool idle() const {
        return hub.size() <= 1 && chest_red.empty() && chest_blue.empty();
    }
};
