#pragma once

#include "roadnet/road.h"
#include "roadnet/coord.h"
#include "roadnet/lorry.h"

namespace roadnet::road {
    struct crossroad {
        roadid     neighbor[4] = {};
        roadid     rev_neighbor[4] = {};
        lorryid    cross_lorry[2] = {};
        cross_type cross_status[2];
        bool u_turn = true;
        void update(network& w, uint64_t ti);
        bool hasNeighbor(direction dir) const;
        void setNeighbor(direction dir, roadid id);
        void setRevNeighbor(direction dir, roadid id);
        void addLorry(network& w, lorryid l, uint16_t offset);
        bool hasLorry(network& w, uint16_t offset);
        void delLorry(network& w, uint16_t offset);

        lorryid& waitingLorry(network& w, direction dir);
    };
}
