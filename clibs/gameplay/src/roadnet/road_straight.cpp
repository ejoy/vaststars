#include "roadnet/road_straight.h"
#include "roadnet/network.h"
#include "core/world.h"
#include <bee/nonstd/unreachable.h>

namespace roadnet::road {
    void straight::init(straightid id, uint16_t len, direction dir, crossid neighbor) {
        this->id = id;
        this->len = len;
        this->dir = dir;
        this->neighbor = neighbor;
    }
    bool straight::canEntry(network& w)  {
        return !hasLorry(w, len-1);
    }
    bool straight::tryEntry(world& w, lorryid l)  {
        if (!hasLorry(w.rw, len-1)) {
            w.rw.LorryInRoad(lorryOffset + len-1) = l;
            auto coord = getCoord(w.rw, len-1);
            lorryEntry(w.rw.Lorry(w, l), coord.x, coord.y, coord.z);
            return true;
        }
        return false;
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
    void straight::update(world& w, uint64_t ti) {
        for (uint16_t i = 1; i < len; ++i) {
            if (lorryid lorryId = w.rw.LorryInRoad(lorryOffset+i)) {
                auto offset = i-1;
                auto& l = w.rw.Lorry(w, lorryId);
                if (lorryReady(l) && !hasLorry(w.rw, offset)) {
                    w.rw.LorryInRoad(lorryOffset + offset) = lorryId;
                    auto coord = getCoord(w.rw, offset);
                    lorryEntry(l, coord.x, coord.y, coord.z);
                    delLorry(w.rw, i);
                }
            }
        }
    }
    lorryid& straight::waitingLorry(network& w) {
        return w.LorryInRoad(lorryOffset);
    }
    loction straight::waitingLoction(network& w) const {
        return w.LorryInCoord(coordOffset).get_loction();
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

    bool straight::insertLorry(network& w, lorryid lorryId, uint16_t offset, map_index index) {
        uint8_t z;
        switch ((map_index)index) {
        case map_index::w0: z = 0; break;
        case map_index::w1: z = 1; break;
        default:
            std::unreachable();
        }
        uint32_t o = lorryOffset + ((len-1) - offset * N - z);
        if (w.LorryInRoad(o)) {
            return false;
        }
        w.LorryInRoad(o) = lorryId;
        return true;
    }
}
