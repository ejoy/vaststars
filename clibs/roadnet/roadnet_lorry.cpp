#include "roadnet_lorry.h"
#include "roadnet_world.h"

namespace roadnet {
    void lorry::initLine(lineid id, uint8_t idx, road_coord ending) {
        lineIdx = idx;
        lineId = id;
        ending = ending;
    }
    direction lorry::getDirection(world& w) {
        return w.Line(lineId).getDirection(lineIdx);
    }
    void lorry::nextDirection(world& w) {
        w.Line(lineId).nextDirection(lineIdx);
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
