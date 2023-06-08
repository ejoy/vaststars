#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"

namespace roadnet {
    enum class map_index : uint8_t {
        w0      = 0x0,
        w1      = 0x1,
        unset   = 0xE,
        invaild = 0xF,
    };

    struct map_coord: public loction {
        uint8_t z: 4;
        uint8_t w: 4;
        constexpr map_coord()
            : loction(0, 0)
            , z(0)
            , w((uint8_t)map_index::invaild)
        { }
        constexpr map_coord(loction loc, cross_type z, map_index w)
            : loction(loc)
            , z((uint8_t)z)
            , w((uint8_t)w)
        { }
    };
}
