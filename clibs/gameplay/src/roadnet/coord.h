#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"

namespace roadnet {
    struct road_coord {
        roadid id;
        uint16_t type: 2;
        uint16_t offset: 14;
        static constexpr road_coord invalid() {
            return {};
        }
        explicit operator bool() const {
            return id != roadid::invalid();
        }
        bool operator ==(road_coord const& rhs) const {
            return id == rhs.id && offset == rhs.offset;
        }
        constexpr road_coord()
            : id(roadid::invalid())
            , type(0)
            , offset(0)
        {}
        constexpr road_coord(roadid id, cross_type type)
            : id(id)
            , type(0)
            , offset((uint8_t)type)
        {}
        constexpr road_coord(roadid id, straight_type type, uint16_t offset)
            : id(id)
            , type((uint8_t)type)
            , offset(offset)
        {}
    };

    struct map_coord: public loction {
        uint8_t z;
        constexpr map_coord(uint8_t x, uint8_t y, uint8_t z)
        : loction(x,y), z(z)
        { }
        explicit operator bool() const {
            return z != (uint8_t)-1;
        }
        bool operator ==(map_coord const& rhs) const {
            return x == rhs.x && y == rhs.y && z == rhs.z;
        }
    };
}
