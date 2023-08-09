#pragma once

#include "util/component.h"
#include "system/building.h"
#include "flatmap.h"
#include <bee/nonstd/bit.h>
#include <vector>
#include <map>

struct hub_berth {
    enum struct berth_type: uint8_t {
        hub,
        chest_red,
        chest_blue,
        home,
    };
    uint32_t unused0 : 5;
    uint32_t type : 2;
    uint32_t chest_slot : 4;
    uint32_t unused1 : 5;
    uint32_t y : 8;
    uint32_t x : 8;
    inline uint16_t hash() const {
        return ((uint16_t)x << 8) | (uint16_t)y;
    }
    inline bool operator==(const hub_berth& rhs) const {
        return std::bit_cast<uint32_t>(*this) == std::bit_cast<uint32_t>(rhs);
    }
    inline bool operator<(const hub_berth& rhs) const {
        return std::bit_cast<uint32_t>(*this) < std::bit_cast<uint32_t>(rhs);
    }
};
static_assert(sizeof(hub_berth) == sizeof(uint32_t));
struct hub_cache {
    std::vector<hub_berth> hub;
    std::vector<hub_berth> chest_red;
    std::vector<hub_berth> chest_blue;
    hub_berth homeBerth;
    building homeBuilding;
    uint8_t homeWidth;
    uint8_t homeHeight;
    uint16_t item;
    bool idle() const {
        return hub.size() <= 1 && chest_red.empty() && chest_blue.empty();
    }
};
