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
        if (tick != 0) {
            --tick;
        }
    }
    bool lorry::ready() {
        return tick == 0;
    }
}
