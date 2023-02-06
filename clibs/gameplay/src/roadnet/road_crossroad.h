#pragma once

#include "roadnet/road.h"
#include "roadnet/coord.h"
#include "roadnet/lorry.h"

namespace roadnet::road {
    struct crossroad {
#ifdef _DEBUG_ROADNET
        loction loc = {0, 0};
        roadid id;
#endif//_DEBUG
        roadid   neighbor[4] = {};
        roadid   rev_neighbor[4] = {};
        lorryid  cross_lorry[2] = {};
        RoadType cross_status[2];
        bool u_turn = true;
        void update(world& w, uint64_t ti);
        bool hasNeighbor(direction dir) const;
        void setNeighbor(direction dir, roadid id);
        void setRevNeighbor(direction dir, roadid id);
        void addLorry(world& w, lorryid l, uint16_t offset);
        bool hasLorry(world& w, uint16_t offset);
        void delLorry(world& w, uint16_t offset);

        lorryid& waitingLorry(world& w, direction dir);
    };
}
