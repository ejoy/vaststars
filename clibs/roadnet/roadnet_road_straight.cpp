#include "roadnet_road_straight.h"
#include "roadnet_world.h"

namespace roadnet::road {
    static constexpr uint8_t kTime = 10;

    void straight::init(uint16_t len, direction dir, const std::vector<uint16_t>& endpoints) {
        this->len = len;
        this->dir = dir;
        for (auto offset : endpoints) {
            pushMap[offset] = std::list<lorryid>();
        }
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
    void straight::pushLorry(lorryid l, uint16_t offset) {
        auto iter = pushMap.find(offset);
        assert(iter != pushMap.end());
        iter->second.push_back(l);
    }
    lorryid straight::popLorry(uint16_t offset) {
        auto iter = popMap.find(offset);
        assert(iter != popMap.end());
        if (iter->second.empty()) {
            return lorryid::invalid();
        }
        auto l = iter->second.front();
        iter->second.pop_front();
        return l;
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
        lorryid l = w.LorryInRoad(lorryOffset + 0);
        if (l) {
            auto iter = pushMap.find(lorryOffset + 0);
            if( iter != pushMap.end() ) {
                auto& list = iter->second;
                auto l = list.front();
                if (l != *list.end()) {
                    if (tryEntry(w, l, dir))
                        list.pop_front();
                }
            }

            auto& lorry = w.Lorry(l);
            if (!lorry.updateTick(w)) {
                auto& n = w.Road(neighbor);
                if (n.tryEntry(w, l, dir)) {
                    delLorry(w, 0);
                }
            }
        }
        for (uint16_t i = 1; i < len; ++i) {
            auto iter = pushMap.find(lorryOffset + i);
            if( iter != pushMap.end() ) {
                auto& list = iter->second;
                auto l = list.front();
                if (l != *list.end()) {
                    if (!w.LorryInRoad(lorryOffset+i-1)) {
                        auto l = list.front();
                        list.pop_front();
                        addLorry(w, l, i-1);
                    }
                }
            }

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
