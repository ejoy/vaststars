#include "roadnet/lorry.h"
#include "roadnet/world.h"
#include "roadnet/bfs.h"

namespace roadnet {
    bool lorry::nextDirection(world& w, roadid C, direction& dir) {
        if (ending.id == roadid::invalid()) {
            return false;
        }
        return route(w, C, ending.id, dir);
    }
    void lorry::initTick(uint8_t v) {
        tick = v;
    }
    void lorry::update(world& w, uint64_t ti) {
        if (capacitance != 0) {
            --capacitance;
        }
        if (tick != 0) {
            --tick;
        }
    }
    bool lorry::ready() {
        return tick == 0;
    }
    void lorry::reset(::world& w) {
        switch (status) {
        case lorry_status::go_buy:
        case lorry_status::want_buy:
            // unlock buy
            [[fallthrough]];
        case lorry_status::go_sell:
        case lorry_status::want_sell:
            // unlock sell
            break;
        case lorry_status::go_home:
        case lorry_status::want_home:
            break;
        default:
            break;
        }
    }
}
