#pragma once

#include "roadnet_dynarray.h"
#include "roadnet_type.h"

namespace roadnet {
    using lineid = objectid;
    struct line {
        dynarray<direction> path;

        direction getDirection(uint8_t n) {
            return path[n];
        }

        void nextDirection(uint8_t& n) {
            n++;
            if (n == path.size()) {
                n = 0;
            }
        }
    };
}
