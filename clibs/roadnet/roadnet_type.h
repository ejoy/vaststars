#pragma once

#include <stdint.h>
#include <compare>

namespace roadnet {
    struct objectid {
        uint16_t id;

        constexpr objectid() : id(0xFFFF) {}
        constexpr objectid(uint16_t id): id(id) {}

        //TODO: use consteval
        static constexpr objectid invalid() {
            return {};
        }
        explicit operator bool() const {
            return id != 0xFFFF;
        }
        auto operator <=>(const objectid& o) const = default;
    };

    enum class direction {
        l = 0,
        t,
        r,
        b,
        n,
    };

    enum RoadType: uint8_t {
        RoadCrossLL=0, RoadCrossLT, RoadCrossLR, RoadCrossLB,
        RoadCrossTL,   RoadCrossTT, RoadCrossTR, RoadCrossTB,
        RoadCrossRL,   RoadCrossRT, RoadCrossRR, RoadCrossRB,
        RoadCrossBL,   RoadCrossBT, RoadCrossBR, RoadCrossBB,
        RoadCrossZL,   RoadCrossZT, RoadCrossZR, RoadCrossZB
    };

    struct loction {
        union {
            struct {
                uint8_t x;
                uint8_t y;
            };
            uint16_t id;
        };
        constexpr loction(uint16_t id) : id(id)
        {}
        constexpr loction(uint8_t x, uint8_t y) : x(x), y(y)
        {}
        constexpr bool operator==(const loction& r) const {
            return id == r.id;
        }
        constexpr bool operator<(const loction& r) const {
            return id < r.id;
        }
    };

    using lorryid = objectid;
    using endpointid = objectid;

    static constexpr uint8_t kTime = (uint8_t)(10 / 2);
    static constexpr uint8_t kWaitTime  = (uint8_t)(10 / 2);
    static constexpr uint8_t kCrossTime = (uint8_t)(20 / 2);
}
