#pragma once

#include <map>
#include <list>
#include "roadnet_road.h"
#include "roadnet_lorry.h"
#include "roadnet_coord.h"

namespace roadnet::road {
    struct straight: public basic_road {
        static inline const size_t N = 2;

        uint16_t len;
        uint32_t lorryOffset;
        roadid neighbor = roadid::invalid();
        direction dir = direction::n;

        std::map<uint16_t, std::list<lorryid>> pushMap; // offset -> lorryid list
        std::map<uint16_t, std::list<lorryid>> popMap;  // same as above
        std::map<uint16_t, bool> offsetLockMap; // offset -> true

        void init(uint16_t len, direction dir, const std::vector<uint16_t>& endpoints);
        void preupdate(world& w, uint64_t ti);
        void update(world& w, uint64_t ti);
        void postupdate(world& w, uint64_t ti);
        bool canEntry(world& w, direction dir) override;
        bool tryEntry(world& w, lorryid l, direction dir) override;
        void setNeighbor(roadid id);
        void setLorryOffset(uint32_t offset) { lorryOffset = offset; }
        void pushLorry(lorryid l, uint16_t offset);
        lorryid popLorry(uint16_t offset);
        void addLorry(world& w, lorryid l, uint16_t offset);
        bool hasLorry(world& w, uint16_t offset);
        void delLorry(world& w, uint16_t offset);
    };
}
