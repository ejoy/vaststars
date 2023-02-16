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

        uint16_t id;
        uint16_t len;
        uint32_t lorryOffset;
        roadid neighbor = roadid::invalid();
        direction dir = direction::n;

        void init(uint16_t id, uint16_t len, direction dir);
        void update(network& w, uint64_t ti);
        bool canEntry(network& w, lorryid l, uint16_t offset);
        bool canEntry(network& w, lorryid l);
        bool tryEntry(network& w, lorryid l, uint16_t offset);
        bool tryEntry(network& w, lorryid l);
        void setNeighbor(roadid id);
        void setLorryOffset(uint32_t offset) { lorryOffset = offset; }
        void setEndpoint(network& w, uint16_t offset, endpointid id);
        void addLorry(network& w, lorryid l, uint16_t offset);
        bool hasLorry(network& w, uint16_t offset);
        void delLorry(network& w, uint16_t offset);
        lorryid& waitingLorry(network& w);
    };
}
