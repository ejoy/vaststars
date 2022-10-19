#include "roadnet_lorry.h"
#include "roadnet_world.h"

namespace roadnet {
    direction lorry::getDirection(world& w) {
        assert(pathIdx < path.size());
        return path[pathIdx];
    }
    void lorry::nextDirection(world& w) {
        pathIdx++;
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
