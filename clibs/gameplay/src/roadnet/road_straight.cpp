#include "roadnet/road_straight.h"
#include "roadnet/world.h"

namespace roadnet::road {
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
            endpointid& e = w.EndpointInRoad(lorryOffset+i);
            if (e) {
                endpoint& ep = w.Endpoint(e);
                auto l = ep.getLorry(w, endpoint::type::out);
                if (l) {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready() && !w.LorryInRoad(lorryOffset+i)) {
                        ep.delLorry(w, endpoint::type::out);
                        addLorry(w, l, i);
                    }
                }
            }

            lorryid l = w.LorryInRoad(lorryOffset+i);
            if (l) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    endpointid& e = w.EndpointInRoad(lorryOffset+i);
                    if (e) {
                        endpoint& ep = w.Endpoint(e);
                        // next offset is endpoint
                        if (lorry.ending.id == id && lorry.ending.offset == i) {
                            if (!ep.hasLorry(w, endpoint::type::in)) {
                                delLorry(w, i);
                                w.Lorry(l).initTick(kTime);
                                ep.addLorry(w, l, endpoint::type::in);
                            }
                        }
                        else {
                            if (!w.LorryInRoad(lorryOffset+i-1)) {
                                delLorry(w, i);
                                addLorry(w, l, i-1);
                            }
                        }
                    }
                    else {
                        if (!w.LorryInRoad(lorryOffset+i-1)) {
                            delLorry(w, i);
                            addLorry(w, l, i-1);
                        }
                    }
                }
            }
        }
    }
}
