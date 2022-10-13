#include "roadnet_road_straight.h"
#include "roadnet_world.h"

namespace roadnet::road {
    static constexpr uint8_t kTime = 10;

    void straight::init(uint16_t id, uint16_t len, direction dir) {
        this->id = id;
        this->len = len;
        this->dir = dir;
    }
    bool straight::canEntry(world& w, direction dir)  {
        return !hasLorry(w, len-1);
    }
    bool straight::tryEntry(world& w, lorryid l, direction dir) {
        if (hasLorry(w, len-1)) {
            return false;
        }
        addLorry(w, l, len-1);
        return true;
    }
    void straight::setNeighbor(roadid id) {
        assert(neighbor == roadid::invalid());
        neighbor = id;
    }
    void straight::pushLorry(world& w, lorryid l, uint16_t offset) {
        endpointManager m = w.endpointsAry[id];
        m.pushLorry(l, offset);
    }
    lorryid straight::popLorry(world& w, uint16_t offset) {
        endpointManager m = w.endpointsAry[id];
        return m.popLorry(offset);
    }
    void straight::addLorry(world& w, lorryid l, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = l;
        w.Lorry(l).initTick(kTime);
    }
    bool straight::hasLorry(world& w, uint16_t offset) {
        return !!w.LorryInRoad(lorryOffset + offset);
    }
    void straight::delLorry(world& w, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = lorryid::invalid();
    }
    void straight::update(world& w, uint64_t ti) {
        endpointManager m = w.endpointsAry[id];
        m.update(w);

        lorryid l = w.LorryInRoad(lorryOffset + 0);
        if (l) {
            auto f = m.getLorry(w, 0);
            if( f != lorryid::invalid() ) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    if (tryEntry(w, f, dir)) {
                        m.exit(w, 0);
                    }
                }
            }

            auto& lorry = w.Lorry(l);
            if (lorry.ready()) {
                auto& n = w.Road(neighbor);
                if (n.tryEntry(w, l, dir)) {
                    delLorry(w, 0);
                }
            }
        }
        for (uint16_t i = 1; i < len; ++i) {
            auto f = m.getLorry(w, i-1);
            if( f != lorryid::invalid() ) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    if (tryEntry(w, f, dir)) {
                        m.exit(w, i-1);
                    }
                }
            }

            lorryid l = w.LorryInRoad(lorryOffset + i);
            if (l) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    if (lorry.ending.id == id && lorry.ending.offset == i-1) {
                        if (m.tryEntry(w, i-1, l)) {
                            delLorry(w, i);
                        }
                    } else {
                        if (!w.LorryInRoad(lorryOffset+i+1)) {
                            addLorry(w, l, i+1);
                            delLorry(w, i);
                        }
                    }
                }
            }
         }
    }
}
