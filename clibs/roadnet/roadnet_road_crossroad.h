#pragma once

#include "roadnet_road.h"
#include "roadnet_coord.h"
#include "roadnet_lorry.h"

namespace roadnet::road {
    struct crossroad {
        roadid   neighbor[4] = {};
        lorryid  cross_lorry[2] = {};
        RoadType cross_status[2];
        uint32_t waiting[4] = {};
        bool u_turn = false;
        void update(world& w, uint64_t ti);
        bool hasNeighbor(direction dir) const;
        void setNeighbor(direction dir, roadid id);
        void addLorry(world& w, lorryid l, uint16_t offset);
        bool hasLorry(world& w, uint16_t offset);
        void delLorry(world& w, uint16_t offset);

        void setWaiting(direction dir, uint32_t offset);
        lorryid& waitingLorry(world& w, direction dir);
    };
}
