#pragma once

#include "roadnet/type.h"

struct world;

namespace roadnet {
    class network;
}

namespace roadnet::road {
    struct straight {
        static inline const uint16_t N = 2;

        straightid id;
        uint16_t len;
        uint32_t lorryOffset;
        uint32_t coordOffset;
        crossid neighbor;
        direction dir;

        void init(straightid id, uint16_t len, direction dir, crossid neighbor);
        void update(world& w, uint64_t ti);
        bool canEntry(network& w, uint16_t offset);
        bool canEntry(network& w);
        bool tryEntry(world& w, lorryid l, uint16_t offset);
        bool tryEntry(world& w, lorryid l);
        void setNeighbor(crossid id);
        void setLorryOffset(uint32_t offset) { lorryOffset = offset; }
        void setCoordOffset(uint32_t offset) { coordOffset = offset; }
        bool hasLorry(network& w, uint16_t offset);
        void delLorry(network& w, uint16_t offset);
        lorryid& waitingLorry(network& w);
        loction waitingLoction(network& w) const;
        map_coord getCoord(network& w, uint16_t offset);
        bool insertLorry(network& w, lorryid lorryId, uint16_t offset, map_index index);
    };
}
