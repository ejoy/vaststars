#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

struct world;
struct lua_State;

namespace roadnet {
    class network;
    struct road_coord;
    enum class lorry_status : uint8_t {
        want_sell,
        go_sell,
        want_buy,
        go_buy,
        want_home,
        go_home,
    };
    struct lorry {
        uint32_t capacitance;
        road_coord ending;
        uint16_t classid;
        uint16_t item;
        uint16_t sell_endpoint;
        uint16_t buy_endpoint;
        uint8_t tick;
        lorry_status status;
        bool nextDirection(network& w, roadid C, direction& dir);
        void initTick(uint8_t tick);
        void update(network& w, uint64_t ti);
        bool ready();
        void reset(world& w);
        void init(world& w, lua_State* L, uint16_t classid);
    };
}
