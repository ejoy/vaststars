#pragma once

#include "roadnet_road.h"

namespace roadnet::road {
    struct crossroad: public basic_road {
        roadid   neighbor[4] = {};
        lorryid  wait_lorry[4] = {};
        lorryid  cross_lorry[2] = {};
        RoadType cross_status[2];
        void update(world& w, uint64_t ti);
        bool canEntry(world& w, direction dir) override;
        bool tryEntry(world& w, lorryid l, direction dir) override;
        bool hasNeighbor(direction dir) const;
        void setNeighbor(direction dir, roadid id);
        void addLorry(world& w, lorryid l, uint16_t offset);
        bool hasLorry(world& w, uint16_t offset);
        void delLorry(world& w, uint16_t offset);
    };
}
