#pragma once

#include "roadnet_type.h"
#include <list>
#include <map>
#include <vector>

namespace roadnet {
    class world;

    struct endpoint {
        static inline const size_t IN = 0;
        static inline const size_t OUT = 1;

        loction loc;
        std::list<lorryid> pushMap;
        std::list<lorryid> popMap;
        lorryid lorry[2] = {lorryid::invalid(), lorryid::invalid()};

        endpoint(loction loc)
            : loc(loc) {}
    };
}
