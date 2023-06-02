#pragma once

#include "roadnet/road.h"
#include "roadnet/coord.h"
#include "roadnet/lorry.h"

namespace roadnet::road {
    constexpr cross_type crossType(direction from, direction to) {
        return (cross_type)(((uint8_t)from << 2) | (uint8_t)to);
    }
    constexpr uint16_t crossTypeMask(direction from, direction to) {
        return 1 << (uint16_t)crossType(from, to);
    }

    constexpr uint16_t NoUTurn = 0
        | crossTypeMask(direction::l, direction::l)
        | crossTypeMask(direction::r, direction::r)
        | crossTypeMask(direction::t, direction::t)
        | crossTypeMask(direction::b, direction::b)
    ;

    constexpr uint16_t NoLeftTurn = 0
        | crossTypeMask(direction::l, direction::t)
        | crossTypeMask(direction::r, direction::b)
        | crossTypeMask(direction::t, direction::r)
        | crossTypeMask(direction::b, direction::l)
    ;

    struct crossroad {
        #ifdef DEBUG_ROADNET
        roadnet::loction loc;
        #endif

        roadid     neighbor[4] = {};
        roadid     rev_neighbor[4] = {};
        lorryid    cross_lorry[2] = {};
        cross_type cross_status[2];
        uint16_t   ban = 0;
        void update(network& w, uint64_t ti);
        bool hasNeighbor(direction dir) const;
        void setNeighbor(direction dir, roadid id);
        void setRevNeighbor(direction dir, roadid id);
        lorryid& waitingLorry(network& w, direction dir);
        bool allowed(direction from, direction to) const;
    };
}
