#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

struct world;
struct lua_State;

namespace roadnet {
    class network;
    struct road_coord;
    struct lorry {
        enum class status: uint8_t {
            normal,
            error,
            fatal,
        };
        void init(world& w, uint16_t classid);
        void init_tick(uint8_t tick);
        void go(roadid ending, uint16_t item_classid, uint16_t item_amount);
        void reset(world& w);
        void update(network& w, uint64_t ti);
        bool next_direction(network& w, roadid C, direction& dir);
        bool ready();
        uint8_t get_tick() const { return tick; }
        uint16_t get_item_amount() const { return item_amount; }
    private:
        roadid ending;
        uint16_t classid;
        uint16_t item_classid;
        uint16_t item_amount;
        uint8_t tick;
        enum status status;
    };
}
