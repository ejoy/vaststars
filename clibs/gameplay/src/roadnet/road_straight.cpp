#include "roadnet/road_straight.h"
#include "roadnet/world.h"

namespace roadnet::road {
    void straight::init(uint16_t id, uint16_t len, direction dir) {
        this->id = id;
        this->len = len;
        this->dir = dir;
    }
    bool straight::canEntry(world& w, lorryid l, uint16_t offset)  {
        if (offset == std::numeric_limits<uint16_t>::max()) {
            offset = len-1;
        }

        if(endpointid& e = w.EndpointInRoad(lorryOffset+offset)) {
            auto& lorry = w.Lorry(l);
            endpoint& ep = w.Endpoint(e);
            // the lorry arrived at the destination?
            if (lorry.ending.id == id && lorry.ending.offset == offset) {
                if(ep.hasLorry(w, endpoint::type::in)) {
                    return false;
                }
            }
            else {
                if(ep.hasLorry(w, endpoint::type::out)) {
                    return false;
                }
            }
        }

        return !hasLorry(w, offset);
    }
    bool straight::tryEntry(world& w, lorryid l, uint16_t offset) {
        if (offset == std::numeric_limits<uint16_t>::max()) {
            offset = len-1;
        }

        if (!canEntry(w, l, offset)) {
            return false;
        }

        if(endpointid& e = w.EndpointInRoad(lorryOffset+offset)) {
            auto& lorry = w.Lorry(l);
            // the lorry arrived at the destination?
            if (lorry.ending.id == id && lorry.ending.offset == offset) {
                endpoint& ep = w.Endpoint(e);
                ep.addLorry(w, l, endpoint::type::in);
                return true;
            }
        }

        addLorry(w, l, offset);
        return true;
    }
    void straight::setNeighbor(roadid id) {
        assert(neighbor == roadid::invalid());
        neighbor = id;
    }
    void straight::setEndpoint(world& w, uint16_t offset, endpointid id) {
        w.EndpointInRoad(lorryOffset + offset) = id;
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
        // The last offset of straight(0) is the waiting area of crossroad, driven by crossroad.
        // see also: crossroad::waitingLorry()
        for (uint16_t i = 1; i < len; ++i) {
            if(lorryid l = w.LorryInRoad(lorryOffset+i)) {
                if(tryEntry(w, l, i-1)) {
                    delLorry(w, i);
                }
            }

            if(endpointid& e = w.EndpointInRoad(lorryOffset+i)) {
                endpoint& ep = w.Endpoint(e);
                if (auto l = ep.getLorry(w, endpoint::type::out)) {
                    if (w.Lorry(l).ready() && tryEntry(w, l, i-1)) {
                        ep.delLorry(w, endpoint::type::out);
                    }
                }
            }
        }
    }
}
