#include "roadnet_road_straight.h"
#include "roadnet_world.h"

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
        endpointid& e = w.EndpointInRoad(lorryOffset + 0);
        if (e) {
            endpoint& ep = w.Endpoint(e);

            auto l = ep.lorry[endpoint::IN];
            if (l) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    ep.popMap.push_back(ep.lorry[endpoint::IN]);
                    ep.lorry[endpoint::IN] = lorryid::invalid();
                }
            }

            l = ep.lorry[endpoint::OUT];
            if (!l) {
                if (ep.pushMap.size() > 0) {
                    auto l = ep.pushMap.front();
                    w.Lorry(l).initTick(kTime);
                    ep.lorry[endpoint::OUT] = l;
                    ep.pushMap.pop_front();
                }
            }
            else {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    auto& n = w.Road(neighbor);
                    if (n.tryEntry(w, l, dir)) {
                        ep.lorry[endpoint::OUT] = lorryid::invalid();
                    }
                }
            }
        }
        lorryid l = w.LorryInRoad(lorryOffset + 0);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (!lorry.ready()) {
                auto& n = w.Road(neighbor);
                if (n.tryEntry(w, l, dir)) {
                    delLorry(w, 0);
                }
            }
        }

        for (uint16_t i = 1; i < len; ++i) {
            endpointid& e = w.EndpointInRoad(lorryOffset+i);
            if (e) {
                endpoint& ep = w.Endpoint(e);

                auto l = ep.lorry[endpoint::IN];
                if (l) {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready()) {
                        ep.popMap.push_back(ep.lorry[endpoint::IN]);
                        ep.lorry[endpoint::IN] = lorryid::invalid();
                    }
                }

                l = ep.lorry[endpoint::OUT];
                if (!l) {
                    if (ep.pushMap.size() > 0) {
                        auto l = ep.pushMap.front();
                        w.Lorry(l).initTick(kTime);
                        ep.lorry[endpoint::OUT] = l;
                        ep.pushMap.pop_front();
                    }
                }
                else {
                    auto& lorry = w.Lorry(l);
                    if (lorry.ready() && !w.LorryInRoad(lorryOffset+i-1)) {
                        ep.lorry[endpoint::OUT] = lorryid::invalid();
                        addLorry(w, l, i-1);
                    }
                }
            }
            lorryid l = w.LorryInRoad(lorryOffset+i);
            if (l) {
                auto& lorry = w.Lorry(l);
                if (lorry.ready()) {
                    delLorry(w, i);
                    endpointid& e = w.EndpointInRoad(lorryOffset+i-1);
                    if (e) {
                        endpoint& ep = w.Endpoint(e);
                        // next offset is endpoint
                        if(lorry.ending.id == id && lorry.ending.offset == i-1) {
                            delLorry(w, i);
                            w.Lorry(l).initTick(kTime);
                            ep.lorry[endpoint::IN] = l;
                        }
                        if (!ep.lorry[endpoint::OUT] && !ep.lorry[endpoint::IN] && !w.LorryInRoad(lorryOffset+i-1)) {
                            delLorry(w, i);
                            addLorry(w, l, i-1);
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
