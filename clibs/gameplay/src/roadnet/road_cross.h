#pragma once

#include "roadnet/type.h"

struct world;

namespace roadnet {
    class network;
}

namespace roadnet::road {
    constexpr cross_type crossType(direction from, direction to) {
        return (cross_type)(((uint8_t)from << 2) | (uint8_t)to);
    }
    constexpr direction crossFrom(cross_type type) {
        return direction(((uint8_t)type >> 2) & 0x3);
    }
    constexpr direction crossTo(cross_type type) {
        return direction((uint8_t)type & 0x3);
    }
    constexpr uint16_t crossTypeMask(direction from, direction to) {
        return 1 << (uint16_t)crossType(from, to);
    }

    constexpr uint16_t NoNorth = 0
        | crossTypeMask(direction::t, direction::t)
        | crossTypeMask(direction::r, direction::l)
        | crossTypeMask(direction::r, direction::b)
        | crossTypeMask(direction::b, direction::l)
    ;
    constexpr uint16_t NoEast = 0
        | crossTypeMask(direction::r, direction::r)
        | crossTypeMask(direction::b, direction::t)
        | crossTypeMask(direction::b, direction::l)
        | crossTypeMask(direction::l, direction::t)
    ;
    constexpr uint16_t NoSouth = 0
        | crossTypeMask(direction::b, direction::b)
        | crossTypeMask(direction::l, direction::r)
        | crossTypeMask(direction::l, direction::t)
        | crossTypeMask(direction::t, direction::r)
    ;
    constexpr uint16_t NoWest = 0
        | crossTypeMask(direction::l, direction::l)
        | crossTypeMask(direction::t, direction::b)
        | crossTypeMask(direction::t, direction::r)
        | crossTypeMask(direction::r, direction::b)
    ;

    struct cross {
        straightid neighbor[4] = {};
        straightid rev_neighbor[4] = {};
        lorryid    cross_lorry[2] = {};
        cross_type cross_status[2];
        uint16_t   ban = 0;
        roadnet::loction loc;
        loction getLoction(network& w) const;
        void update(world& w, uint64_t ti);
        bool hasNeighbor(direction dir) const;
        bool hasRevNeighbor(direction dir) const;
        void setNeighbor(direction dir, straightid id);
        void setRevNeighbor(direction dir, straightid id);
        bool allowed(direction from, direction to) const;
        bool insertLorry(network& w, lorryid lorryId, map_index i, cross_type ct);
        bool insertLorry0(network& w, lorryid lorryId, cross_type type);
        bool insertLorry1(network& w, lorryid lorryId, cross_type type);
    };
}
