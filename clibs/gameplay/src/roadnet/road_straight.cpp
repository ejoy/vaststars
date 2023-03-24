#include "roadnet/road_straight.h"
#include "roadnet/network.h"

namespace roadnet::road {
    void straight::init(roadid id, uint16_t len, direction dir, roadid neighbor) {
        this->id = id;
        this->len = len;
        this->dir = dir;
        this->neighbor = neighbor;
    }
    bool straight::canEntry(network& w, uint16_t offset)  {
        return !hasLorry(w, offset);
    }
    bool straight::canEntry(network& w)  {
        return canEntry(w, len-1);
    }
    bool straight::tryEntry(network& w, lorryid l, uint16_t offset) {
        if (!hasLorry(w, offset)) {
            addLorry(w, l, offset);
            return true;
        }
        return false;
    }
    bool straight::tryEntry(network& w, lorryid l)  {
        return tryEntry(w, l, len-1);
    }
    void straight::setNeighbor(roadid id) {
        assert(neighbor == roadid::invalid());
        neighbor = id;
    }
    void straight::addLorry(network& w, lorryid l, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = l;
        w.Lorry(l).initTick(kTime);
    }
    bool straight::hasLorry(network& w, uint16_t offset) {
        return !!w.LorryInRoad(lorryOffset + offset);
    }
    void straight::delLorry(network& w, uint16_t offset) {
        w.LorryInRoad(lorryOffset + offset) = lorryid::invalid();
    }
    void straight::update(network& w, uint64_t ti) {
        // The last offset of straight(0) is the waiting area of crossroad, driven by crossroad.
        // see also: crossroad::waitingLorry()
        for (uint16_t i = 1; i < len; ++i) {
            if (lorryid l = w.LorryInRoad(lorryOffset+i)) {
                if (tryEntry(w, l, i-1)) {
                    delLorry(w, i);
                }
            }
        }
    }
    lorryid& straight::waitingLorry(network& w) {
        return w.LorryInRoad(lorryOffset);
    }
}
