#pragma once

#include "util/component.h"
#include "system/building.h"
#include "flatmap.h"
#include <bee/nonstd/bit.h>
#include <vector>
#include <map>

struct airport {
    struct berth {
        uint32_t unused0 : 4;
        uint32_t type : 3;
        uint32_t chest_slot : 4;
        uint32_t unused1 : 5;
        uint32_t y : 8;
        uint32_t x : 8;
        inline uint16_t hash() const {
            return ((uint16_t)x << 8) | (uint16_t)y;
        }
        inline bool operator==(const berth& rhs) const {
            return std::bit_cast<uint32_t>(*this) == std::bit_cast<uint32_t>(rhs);
        }
        inline bool operator<(const berth& rhs) const {
            return std::bit_cast<uint32_t>(*this) < std::bit_cast<uint32_t>(rhs);
        }
    };
    static_assert(sizeof(berth) == sizeof(uint32_t));
    std::vector<berth> hub;
    std::vector<berth> chest_red;
    std::vector<berth> chest_blue;
    berth homeBerth;
    uint8_t width;
    uint8_t height;
    uint16_t item;
    uint16_t prototype;
    ecs::capacitance* capacitance;
    bool idle() const {
        return hub.size() <= 1 && chest_red.empty() && chest_blue.empty();
    }
};
