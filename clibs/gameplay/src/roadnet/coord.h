#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"

namespace roadnet {
    struct road_coord {
        roadid id;
        uint16_t offset;
        static constexpr road_coord invalid() {
            return {roadid::invalid(), (uint16_t)-1};
        }
        explicit operator bool() const {
            return id != roadid::invalid();
        }
        bool operator ==(road_coord const& rhs) const {
            return id == rhs.id && offset == rhs.offset;
        }
    };

    struct map_coord: public loction {
        uint8_t z;
        constexpr map_coord(uint8_t x, uint8_t y, uint8_t z)
        : loction(x,y), z(z)
        { }
        static constexpr map_coord invalid() {
            return {(uint8_t)-1,(uint8_t)-1, (uint8_t)-1};
        }
        explicit operator bool() const {
            return z != (uint8_t)-1;
        }
        bool operator ==(map_coord const& rhs) const {
            return x == rhs.x && y == rhs.y && z == rhs.z;
        }
    };
}
