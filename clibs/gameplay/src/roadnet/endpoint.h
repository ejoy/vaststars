#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <list>
#include <map>
#include <vector>

namespace roadnet {
    class world;

    struct endpoint {
        static inline const size_t EPIN = 0;
        static inline const size_t EPOUT = 1;

        loction loc;
        road_coord coord;
        std::list<lorryid> pushMap;
        std::list<lorryid> popMap;
        lorryid lorry[2] = {lorryid::invalid(), lorryid::invalid()};
    };
}
