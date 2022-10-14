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
        for (uint16_t i = 0; i < len; ++i) {
            endpointid& eid = w.EndpointInRoad(lorryOffset + i);
            if ( eid != endpointid::invalid() ) {
                endpoint e = w.Endpoint(eid);

                auto l = e.lorry[endpoint::IN];
                if (l != lorryid::invalid()) {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready()) {
                        e.popMap.push_back(e.lorry[endpoint::IN]);
                        e.lorry[endpoint::IN] = lorryid::invalid();
                    }
                }

                l = e.lorry[endpoint::OUT];
                if (l == lorryid::invalid() && e.pushMap.size() > 0) {
                    e.lorry[endpoint::OUT] = e.pushMap.front();
                    e.pushMap.pop_front();
                }
            }
        }

        lorryid l = w.LorryInRoad(lorryOffset + 0);
        if (l) {
            endpointid& eid = w.EndpointInRoad(lorryOffset + 0);
            if ( eid != endpointid::invalid() ) {
                auto& e = w.Endpoint(eid);
                auto f = e.lorry[endpoint::OUT];
                if( f != lorryid::invalid() ) {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready()) {
                        if (tryEntry(w, f, dir)) {
                            e.lorry[endpoint::OUT] = lorryid::invalid();
                        }
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
            endpointid& eid = w.EndpointInRoad(lorryOffset + i);
            if ( eid != endpointid::invalid() ) {
                auto& e = w.Endpoint(eid);
                auto f = e.lorry[endpoint::OUT];
                if( f != lorryid::invalid() ) {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready()) {
                        if (tryEntry(w, f, dir)) {
                            e.lorry[endpoint::OUT] = lorryid::invalid();
                        }
                    }
                }
            }

            lorryid l = w.LorryInRoad(lorryOffset + i);
            if (l) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    if (lorry.ending.id == id && lorry.ending.offset == i-1) {
                        endpointid& eid = w.EndpointInRoad(lorryOffset + i);
                        assert(eid != endpointid::invalid());
                        auto& e = w.Endpoint(eid);
                        if (e.lorry[endpoint::IN] == lorryid::invalid()) {
                            e.lorry[endpoint::IN] = l;
                            auto& lorry = w.Lorry(l);
                            lorry.initTick(kTime);

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
