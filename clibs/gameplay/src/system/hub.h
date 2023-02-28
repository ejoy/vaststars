#pragma once

#include "util/component.h"
#include "util/flatmap.h"
#include <vector>
#include <map>

struct hub_mgr {
    enum struct berth_type: uint8_t {
        hub,
        chest_red,
        chest_blue,
    };
    struct berth {
        uint32_t unused : 5;
        uint32_t type : 2;
        uint32_t chest : 4;
        uint32_t slot : 3;
        uint32_t y : 9;
        uint32_t x : 9;
        inline uint32_t toint() const {
            auto h = *(const uint32_t*)this;
            return h;
        }
        inline uint32_t hash() const {
            return toint() & 0x0003FFFF;
        }
        inline bool operator==(const berth& rhs) const {
            return toint() == rhs.toint();
        }
        inline bool operator<(const berth& rhs) const {
            return toint() < rhs.toint();
        }
    };
    static_assert(sizeof(berth) == sizeof(uint32_t));
    struct hub_info {
        uint16_t item;
        std::vector<berth> hub;
        std::vector<berth> chest_red;
        std::vector<berth> chest_blue;
    };
    std::map<berth, hub_info> hubs;
    flatmap<uint32_t, uint16_t> chests;
};
