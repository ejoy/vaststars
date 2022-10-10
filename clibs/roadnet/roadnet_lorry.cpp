#include "roadnet_lorry.h"
#include "roadnet_world.h"

namespace roadnet {
    direction lorry::getDirection(world& w) {
        return direction::n; // TODO call roadmap.c
    }
    void lorry::nextDirection(world& w) {
        // TODO call roadmap.c
    }
    void lorry::initTick(world& w, uint8_t v) {
        tick = v - 1; // [0, v), total v ticks
        marked = w.marked;
    }
    uint8_t lorry::updateTick(world& w) {
        if (marked != w.marked) {
            marked = w.marked;
            if (tick != 0) {
                --tick;
            }
        }
        return tick;
    }
}
