#pragma once

#include "util/component.h"
#include "system/building.h"
#include "flatmap.h"
#include <bee/nonstd/bit.h>
#include <vector>
#include <map>

struct airport {
    struct berth {
        uint8_t unused0;
        uint8_t slot;
        uint8_t y;
        uint8_t x;
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
