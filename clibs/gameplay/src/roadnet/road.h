#pragma once

#include <vector>
#include "roadnet/type.h"
#include "util/dynarray.h"

namespace roadnet {
    class world;

    struct roadid {
        uint16_t cross : 1;
        uint16_t id    : 15;

        constexpr roadid() : cross(0), id(0x7FFF) {}
        constexpr roadid(uint16_t v) : cross((v & 0x8000) >> 15), id(v & 0x7FFF) {}
        constexpr roadid(uint16_t cross, uint16_t id) : cross(cross), id(id) {}

        constexpr uint16_t toint() const {
            return (cross << 15) | id;
        }

        //TODO: use consteval
        static constexpr roadid invalid() {
            return {};
        }
        explicit operator bool() const {
            return id != 0x7FFF;
        }
        auto operator <=>(const roadid& o) const = default;
    };
    static_assert(sizeof(roadid)==2);
}
