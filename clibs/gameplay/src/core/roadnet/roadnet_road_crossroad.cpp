#include "roadnet_road_crossroad.h"
#include "roadnet_world.h"
#include <assert.h>

namespace roadnet::road {
    static constexpr uint8_t kWaitTime  = 10;
    static constexpr uint8_t kCrossTime = 20;
    static constexpr bool constIsCross(RoadType a, RoadType b) {
        if ((a & 0x03) == (b & 0x03)) {
            return true;
        }
        if ((a & 0x0C) == (b & 0x0C)) {
            return true;
        }
        if (((a == RoadCrossLR) || (a == RoadCrossRL)) && ((b == RoadCrossTB) || (b == RoadCrossBT))) {
            return true;
        }
        if (((a == RoadCrossTB) || (a == RoadCrossBT)) && ((b == RoadCrossLR) || (b == RoadCrossRL))) {
            return true;
        }
        if (a == RoadCrossLR && (b == RoadCrossBL || b == RoadCrossRB)) {
            return true;
        }
        if (a == RoadCrossRL && (b == RoadCrossTR || b == RoadCrossLT)) {
            return true;
        }
        if (a == RoadCrossTB && (b == RoadCrossLT || b == RoadCrossBL)) {
            return true;
        }
        if (a == RoadCrossBT && (b == RoadCrossRB || b == RoadCrossTR)) {
            return true;
        }
        return false;
    }
    static constexpr uint16_t constGetCrossMask(RoadType a) {
        uint16_t m = 0;
        for (uint8_t i = 0; i < 16; ++i) {
            if (constIsCross(a, RoadType(i))) {
                m |= 1 << i;
            }
        }
        return m;
    }
    static constexpr uint16_t CrossMap[16] = {
        constGetCrossMask(RoadType(0)),  constGetCrossMask(RoadType(1)),
        constGetCrossMask(RoadType(2)),  constGetCrossMask(RoadType(3)),
        constGetCrossMask(RoadType(4)),  constGetCrossMask(RoadType(5)),
        constGetCrossMask(RoadType(6)),  constGetCrossMask(RoadType(7)),
        constGetCrossMask(RoadType(8)),  constGetCrossMask(RoadType(9)),
        constGetCrossMask(RoadType(10)), constGetCrossMask(RoadType(11)),
        constGetCrossMask(RoadType(12)), constGetCrossMask(RoadType(13)),
        constGetCrossMask(RoadType(14)), constGetCrossMask(RoadType(15)),
    };
    static bool isCross(RoadType a, RoadType b) {
        return (CrossMap[a] & (1 << (uint16_t)b)) != 0;
    }

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        case direction::n: default: return direction::n;
        }
    }

    bool crossroad::hasNeighbor(direction dir) const {
        return neighbor[(uint8_t)dir] != roadid::invalid();
    }

    void crossroad::setNeighbor(direction dir, roadid id) {
        assert(!hasNeighbor(dir));
        neighbor[(uint8_t)dir] = id;
    }

    bool crossroad::canEntry(world& w, direction dir) {
        uint8_t idx = (uint8_t)dir;
        return !wait_lorry[idx];
    }

    bool crossroad::tryEntry(world& w, lorryid id, direction dir) {
        uint8_t idx = (uint8_t)dir;
        if (wait_lorry[idx]) {
            return false;
        }
        wait_lorry[idx] = id;
        auto& l = w.Lorry(id);
        l.initTick(w, kWaitTime);
        return true;
    }

    void crossroad::addLorry(world& w, lorryid id, uint16_t offset) {
        RoadType type = RoadType(offset);
        if (type >= RoadCrossZL) {
            delLorry(w, offset);
            tryEntry(w, id, direction(type & 0x03u));
            return;
        }
        for (size_t i = 0; i < 2; ++i) {
            if (!cross_lorry[i]) {
                auto& l = w.Lorry(id);
                cross_lorry[i] = id;
                cross_status[i] = type;
                l.initTick(w, kCrossTime);
                l.nextDirection(w);
                return;
            }
        }
    }

    bool crossroad::hasLorry(world& w, uint16_t offset) {
        RoadType type = RoadType(offset);
        if (type >= RoadCrossZL) {
            return !wait_lorry[type & 0x03u];
        }
        if (cross_lorry[0] && cross_lorry[1]) {
            return false;
        }
        if (!cross_lorry[0] && !cross_lorry[1]) {
            return true;
        }
        if (!cross_lorry[0]) {
            return !isCross(RoadType(offset), cross_status[0]);
        }
        return !isCross(RoadType(offset), cross_status[1]);
    }

    void crossroad::delLorry(world& w, uint16_t offset) {
        RoadType type = RoadType(offset);
        if (type >= RoadCrossZL) {
            wait_lorry[type & 0x03u] = lorryid::invalid();
            return;
        }
        for (size_t i = 0; i < 2; ++i) {
            if (cross_lorry[i] && cross_status[i] == type) {
                cross_lorry[i] = lorryid::invalid();
                return;
            }
        }
    }

    void crossroad::update(world& w, uint64_t ti) {
        for (size_t i = 0; i < 2; ++i) {
            lorryid id = cross_lorry[i];
            if (!id) {
                continue;
            }
            auto& l = w.Lorry(id);
            if (l.updateTick(w)) {
                continue;
            }
            RoadType t = cross_status[i];
            auto& road = w.Road(neighbor[t & 0x03u]);
            if (road.tryEntry(w, id, direction(t & 0x03u))) {
                cross_lorry[i] = lorryid::invalid();
            }
        }
        for (uint8_t ii = 0; ii < 4; ++ii) {
            uint8_t i = (ii + (ti>>4)) % 4;
            lorryid id = wait_lorry[i];
            if (!id) {
                continue;
            }
            auto& l = w.Lorry(id);
            if (l.updateTick(w)) {
                continue;
            }
            if (cross_lorry[0] && cross_lorry[1]) {
                continue;
            }
            direction out = l.getDirection(w);
            assert((direction)i != out);
            if (!w.Road(neighbor[(uint8_t)out]).canEntry(w, out)) {
                continue;
            }
            RoadType type = RoadType(((uint8_t)i << 2) | (uint8_t)out);
            size_t idx;
            if (!cross_lorry[0] && !cross_lorry[1]) {
                idx = 0;
            }
            else if (cross_lorry[0]) {
                if (isCross(type, cross_status[0])) {
                    continue;
                }
                idx = 1;
            }
            else {
                if (isCross(type, cross_status[1])) {
                    continue;
                }
                idx = 0;
            }
            wait_lorry[i] = lorryid::invalid();
            cross_lorry[idx] = id;
            cross_status[idx] = type;
            l.initTick(w, kCrossTime);
            l.nextDirection(w);
        }
    }
}
