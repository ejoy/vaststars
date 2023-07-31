#include "roadnet/road_cross.h"
#include "roadnet/network.h"
#include "roadnet/lorry.h"
#include "core/world.h"
#include <bee/nonstd/unreachable.h>
#include <assert.h>

namespace roadnet::road {
    static constexpr bool constIsCross(cross_type a, cross_type b) {
        if (((uint8_t)a & 0x03) == ((uint8_t)b & 0x03)) {
            return true;
        }
        if (((uint8_t)a & 0x0C) == ((uint8_t)b & 0x0C)) {
            return true;
        }
        if (((a == cross_type::lr) || (a == cross_type::rl)) && ((b == cross_type::tb) || (b == cross_type::bt))) {
            return true;
        }
        if (a == cross_type::lr && (b == cross_type::bl || b == cross_type::rb)) {
            return true;
        }
        if (a == cross_type::rl && (b == cross_type::tr || b == cross_type::lt)) {
            return true;
        }
        if (a == cross_type::tb && (b == cross_type::lt || b == cross_type::bl)) {
            return true;
        }
        if (a == cross_type::bt && (b == cross_type::rb || b == cross_type::tr)) {
            return true;
        }
        return false;
    }
    static constexpr uint16_t constGetCrossMask(cross_type a) {
        uint16_t m = 0;
        for (uint8_t i = 0; i < 16; ++i) {
            if (constIsCross(a, cross_type(i)) || constIsCross(cross_type(i), a)) {
                m |= 1 << i;
            }
        }
        return m;
    }
    static constexpr uint16_t CrossMap[16] = {
        constGetCrossMask(cross_type(0)),  constGetCrossMask(cross_type(1)),
        constGetCrossMask(cross_type(2)),  constGetCrossMask(cross_type(3)),
        constGetCrossMask(cross_type(4)),  constGetCrossMask(cross_type(5)),
        constGetCrossMask(cross_type(6)),  constGetCrossMask(cross_type(7)),
        constGetCrossMask(cross_type(8)),  constGetCrossMask(cross_type(9)),
        constGetCrossMask(cross_type(10)), constGetCrossMask(cross_type(11)),
        constGetCrossMask(cross_type(12)), constGetCrossMask(cross_type(13)),
        constGetCrossMask(cross_type(14)), constGetCrossMask(cross_type(15)),
    };
    static bool isCross(cross_type a, cross_type b) {
        return (CrossMap[(uint8_t)a] & (1 << (uint16_t)b)) != 0;
    }

    loction cross::getLoction(network& w) const {
        return loc;
        //TODO
        //return w.StraightRoad(rev_neighbor).waitingLoction(w);
    }

    bool cross::hasNeighbor(direction dir) const {
        return neighbor[(uint8_t)dir] != straightid::invalid();
    }

    bool cross::hasRevNeighbor(direction dir) const {
        return rev_neighbor[(uint8_t)dir] != straightid::invalid();
    }

    void cross::setNeighbor(direction dir, straightid id) {
        assert(!hasNeighbor(dir));
        neighbor[(uint8_t)dir] = id;
    }

    void cross::setRevNeighbor(direction dir, straightid id) {
        assert(rev_neighbor[(uint8_t)dir] == straightid::invalid());
        rev_neighbor[(uint8_t)dir] = id;
    }

    void cross::update(world& w, uint64_t ti) {
        for (size_t i = 0; i < 2; ++i) {
            lorryid id = cross_lorry[i];
            if (!id) {
                continue;
            }
            auto& l = w.rw.Lorry(w, id);
            if (!lorryReady(l)) {
                continue;
            }
            cross_type t = cross_status[i];
            auto& road = w.rw.StraightRoad(neighbor[(uint8_t)t & 0x03u]);
            if (road.canEntry(w.rw)) {
                road.move(w, id);
                cross_lorry[i] = lorryid::invalid();
            }
        }
        for (uint8_t ii = 0; ii < 4; ++ii) {
            uint8_t i = (ii + (ti>>4)) % 4; // swap the order of the lorries every 16 ticks
            if (!rev_neighbor[i]) {
                continue;
            }
            auto& straight = w.rw.StraightRoad(rev_neighbor[(size_t)i]);
            lorryid id = straight.waitingLorry(w.rw);
            if (!id) {
                continue;
            }
            auto& l = w.rw.Lorry(w, id);
            if (!lorryReady(l)) {
                continue;
            }
            if (cross_lorry[0] && cross_lorry[1]) {
                continue;
            }
            direction out;
            if (!lorryNextDirection(l, w.rw, rev_neighbor[i], out)) {
                continue;
            }
            if (!w.rw.StraightRoad(neighbor[(uint8_t)out]).canEntry(w.rw)) {
                continue;
            }
            cross_type type = crossType(direction(i), out);
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
            straight.waitingLorry(w.rw) = lorryid::invalid();
            cross_lorry[idx] = id;
            cross_status[idx] = type;
            auto loc = getLoction(w.rw);
            lorryMove(l, w, loc.x, loc.y, map_coord::make_z(map_index::w1, cross_status[idx]));
        }
    }

    bool cross::allowed(direction from, direction to) const {
        return (ban & crossTypeMask(from, to)) == 0;
    }

    bool cross::insertLorry0(network& w, lorryid lorryId, cross_type type) {
        direction from = direction((uint8_t)type >> 2);
        if (!hasRevNeighbor(from)) {
            return false;
        }
        auto& straight = w.StraightRoad(rev_neighbor[(size_t)from]);
        if (straight.waitingLorry(w)) {
            return false;
        }
        straight.waitingLorry(w) = lorryId;
        return true;
    }

    bool cross::insertLorry1(network& w, lorryid lorryId, cross_type type) {
        if (cross_lorry[0] && cross_lorry[1]) {
            return false;
        }
        bool has_lorry = cross_lorry[0] || cross_lorry[1];
        size_t empty_idx = cross_lorry[0]? 1: 0;
        size_t lorry_idx = cross_lorry[0]? 0: 1;
        uint8_t from_v = (uint8_t)crossFrom(type);
        uint8_t to_v = (uint8_t)crossTo(type);
        for (uint8_t j = 0; j < 4; ++j) {
            for (uint8_t i = 0; i < 4; ++i) {
                direction from = direction((from_v + i) % 4);
                direction to = direction((to_v + j) % 4);
                if (hasNeighbor(to) && hasRevNeighbor(from) && allowed(from, to)) {
                    if (!has_lorry || !isCross(cross_status[lorry_idx], crossType(from, to))) {
                        cross_lorry[empty_idx] = lorryId;
                        cross_status[empty_idx] = crossType(from, to);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    bool cross::insertLorry(network& w, lorryid lorryId, map_index i, cross_type ct) {
        switch (i) {
        case map_index::w0:
            return insertLorry0(w, lorryId, ct);
        case map_index::w1:
            return insertLorry1(w, lorryId, ct);
        default:
            std::unreachable();
        }
    }
}
