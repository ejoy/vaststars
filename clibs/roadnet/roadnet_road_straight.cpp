#include "roadnet_road_straight.h"
#include "roadnet_world.h"

namespace roadnet::road {
    static constexpr uint8_t kTime = 10;

    void straight::init(uint16_t len, direction dir) {
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
    void straight::addLorry(world& w, lorryid l, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = l;
        w.Lorry(l).initTick(w, kTime);
    }
    bool straight::hasLorry(world& w, uint16_t offset) {
        return !!w.LorryInRoad(lorryOffset + offset);
    }
    void straight::delLorry(world& w, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = lorryid::invalid();
    }
    void straight::update(world& w, uint64_t ti) {
        uint16_t i = 0;
        lorryid l = w.LorryInRoad(lorryOffset + i);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (!lorry.updateTick(w)) {
                auto& n = w.Road(neighbor);
                if (n.tryEntry(w, l, dir)) {
                    delLorry(w, i);
                }
            }
        }
        for (uint16_t i = 1; i < len; ++i) {
            lorryid l = w.LorryInRoad(lorryOffset + i);
            if (l) {
                if (!w.Lorry(l).updateTick(w) && !w.LorryInRoad(lorryOffset+i-1)) {
                    delLorry(w, i);
                    addLorry(w, l, i-1);
                }
            }
         }
    }
}
