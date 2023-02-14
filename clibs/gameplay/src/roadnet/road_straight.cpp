#include "roadnet/road_straight.h"
#include "roadnet/world.h"

namespace roadnet::road {
    void straight::init(uint16_t id, uint16_t len, direction dir) {
        this->id = id;
        this->len = len;
        this->dir = dir;
    }
    bool straight::canEntry(world& w, lorryid l, uint16_t offset)  {
        if (endpointid& e = w.EndpointInRoad(lorryOffset+offset)) {
            endpoint& ep = w.Endpoint(e);
            auto& lorry = w.Lorry(l);
            bool arrive = lorry.ending.id == id && lorry.ending.offset == offset;
            return ep.canEntry(w, arrive? endpoint::type::in: endpoint::type::straight);
        }
        return !hasLorry(w, offset);
    }
    bool straight::canEntry(world& w, lorryid l)  {
        return canEntry(w, l, len-1);
    }
    bool straight::tryEntry(world& w, lorryid l, uint16_t offset) {
        if (endpointid& e = w.EndpointInRoad(lorryOffset+offset)) {
            endpoint& ep = w.Endpoint(e);
            auto& lorry = w.Lorry(l);
            bool arrive = lorry.ending.id == id && lorry.ending.offset == offset;
            return ep.tryEntry(w, l, arrive? endpoint::type::in: endpoint::type::straight);
        }
        if (!hasLorry(w, offset)) {
            addLorry(w, l, offset);
            return true;
        }
        return false;
    }
    bool straight::tryEntry(world& w, lorryid l)  {
        return tryEntry(w, l, len-1);
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
            if (endpointid& e = w.EndpointInRoad(lorryOffset+i)) {
                endpoint& ep = w.Endpoint(e);
                ep.updateStraight(w, [&](lorryid l){ return tryEntry(w, l, i-1); });
            }
            else if (lorryid l = w.LorryInRoad(lorryOffset+i)) {
                if (tryEntry(w, l, i-1)) {
                    delLorry(w, i);
                }
            }
        }
    }
    lorryid& straight::waitingLorry(world& w) {
        if (endpointid& e = w.EndpointInRoad(lorryOffset)) {
            endpoint& ep = w.Endpoint(e);
            return ep.getOutOrStraight(w);
        }
        else {
            return w.LorryInRoad(lorryOffset);
        }
    }
}
