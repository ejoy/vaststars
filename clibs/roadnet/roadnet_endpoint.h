#pragma once

#include "roadnet_type.h"
#include <list>
#include <map>
#include <vector>

namespace roadnet {
    struct world;

    struct endpoint {
        static inline const size_t IN = 0;
        static inline const size_t OUT = 1;

        std::list<lorryid> pushMap;
        std::list<lorryid> popMap;
        lorryid lorry[2] = {lorryid::invalid(), lorryid::invalid()};
    };

    struct straight_endpoints {
        std::map<uint16_t, endpoint> endpoints; // offset -> endpoint

        void init(const std::vector<uint16_t>& endpoints);
        void pushLorry(lorryid l, uint16_t offset);
        lorryid popLorry(uint16_t offset);
        bool tryEntry(world& w, uint16_t offset, lorryid id);
        lorryid getLorry(world& w, uint16_t offset);
        void exit(world& w, uint16_t offset);
        void update(world& w);
    };
}
