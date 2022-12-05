#include "roadnet_lorry.h"
#include "roadnet_world.h"
#include "roadnet_bfs.h"

namespace roadnet {
    direction lorry::getDirection(world& w, roadid C) {
        direction result;
        bool ok = route(w, C, ending.id, result);
        (void)ok; assert(ok);
        return result;
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
