#include "roadnet/road_straight.h"
#include "roadnet/network.h"

namespace roadnet::road {
    void straight::init(straightid id, uint16_t len, direction dir, crossid neighbor) {
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
            w.LorryInRoad(lorryOffset + offset) = l;
            w.Lorry(l).entry(roadtype::straight);
            return true;
        }
        return false;
    }
    bool straight::tryEntry(network& w, lorryid l)  {
        return tryEntry(w, l, len-1);
    }
    void straight::setNeighbor(crossid id) {
        assert(neighbor == crossid::invalid());
        neighbor = id;
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
                if (w.Lorry(l).ready() && tryEntry(w, l, i-1)) {
                    delLorry(w, i);
                }
            }
        }
    }
    lorryid& straight::waitingLorry(network& w) {
        return w.LorryInRoad(lorryOffset);
    }
    loction straight::waitingLoction(network& w) const {
        return w.LorryInCoord(coordOffset);
    }
    map_coord straight::getCoord(network& w, uint16_t offset) {
        offset = (len-1) - offset;
        auto coord = w.LorryInCoord(coordOffset + offset / N);
        switch (offset % N) {
        case 0: coord.set(map_index::w0); break;
        case 1: coord.set(map_index::w1); break;
        default:
            std::unreachable();
        }
        return coord;
    }
}
