#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <vector>

namespace roadnet {
    class world;
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
        uint8_t tick;
        road_coord ending;
        struct where {
            uint16_t endpoint;
        };
        struct  {
            uint16_t item;
            where sell;
            where buy;
            lorry_status status;
        } gameplay;
        bool nextDirection(world& w, roadid C, direction& dir);
        void initTick(uint8_t v);
        void update(world& w, uint64_t ti);
        bool ready();
    };
}
