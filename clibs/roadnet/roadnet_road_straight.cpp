#include "roadnet_road_straight.h"
#include "roadnet_world.h"

namespace roadnet::road {
    static constexpr uint8_t kTime = 10;
    static bool reservation(straight *r, uint16_t offset) {
        auto m = r->reservationMap;
        return m.find(offset) != m.end();
    }

    void straight::init(uint16_t len, direction dir, const std::vector<uint16_t>& endpoints) {
        this->len = len;
        this->dir = dir;
        for (auto offset : endpoints) {
            endpointMap[offset] = std::list<lorryid>();
        }
    }
    bool straight::canEntry(world& w, direction dir)  {
        return !reservation(this, len-1) && !hasLorry(w, len-1);
    }
    bool straight::tryEntry(world& w, lorryid l, direction dir) {
        if (hasLorry(w, len-1) || reservation(this, len-1)) {
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
        auto iter = endpointMap.find(offset);
        assert(iter != endpointMap.end());
        iter->second.push_back(l);
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
    void straight::preupdate(world& w, uint64_t ti) {
        for (auto iter = endpointMap.begin(); iter != endpointMap.end(); iter++) {
            auto& list = iter->second;
            auto l = list.front();
            if (l != *list.end()) {                
                auto& lorry = w.Lorry(l);
                if (!lorry.updateTick(w)) {
                    if (tryEntry(w, l, dir)) {
                        list.pop_front();
                    }
                    else {
                        reservationMap[iter->first] = true;
                    }
                }
            }
        }        
    }
    void straight::update(world& w, uint64_t ti) {
        lorryid l = w.LorryInRoad(lorryOffset + 0);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (!lorry.updateTick(w)) {
                auto& n = w.Road(neighbor);
                if (n.tryEntry(w, l, dir)) {
                    delLorry(w, 0);
                }
            }
        }
        for (uint16_t i = 1; i < len; ++i) {
            lorryid l = w.LorryInRoad(lorryOffset + i);
            if (l) {
                if (!w.Lorry(l).updateTick(w) && !w.LorryInRoad(lorryOffset+i-1) && !reservation(this, i-1)) {
                    delLorry(w, i);
                    addLorry(w, l, i-1);
                }
            }
         }
    }
    void straight::postupdate(world& w, uint64_t ti) {
        for (auto iter = reservationMap.begin(); iter != reservationMap.end(); iter++) {
            auto& list = endpointMap[iter->first];
            if (list.size() > 0) {
                if (!w.LorryInRoad(lorryOffset+iter->first)) {
                    auto l = list.front();
                    addLorry(w, l, iter->first);
                    list.pop_front();
                }
            }
        }
        reservationMap.clear();
    }
}
