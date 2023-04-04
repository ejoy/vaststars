#pragma once

#include <map>
#include <list>
#include "roadnet/road.h"
#include "roadnet/lorry.h"
#include "roadnet/coord.h"

namespace roadnet {
    class network;
}

namespace roadnet::road {
    struct straight {
        static inline const uint16_t N = 2;

        roadid id;
        uint16_t len;
        uint32_t lorryOffset;
        roadid neighbor;
        direction dir;

        void init(roadid id, uint16_t len, direction dir, roadid neighbor);
        void update(network& w, uint64_t ti);
        bool canEntry(network& w, uint16_t offset);
        bool canEntry(network& w);
        bool tryEntry(network& w, lorryid l, uint16_t offset);
        bool tryEntry(network& w, lorryid l);
        void setNeighbor(roadid id);
        void setLorryOffset(uint32_t offset) { lorryOffset = offset; }
        bool hasLorry(network& w, uint16_t offset);
        void delLorry(network& w, uint16_t offset);
        lorryid& waitingLorry(network& w);
    };
    static_assert(std::is_trivial_v<straight>);
}
