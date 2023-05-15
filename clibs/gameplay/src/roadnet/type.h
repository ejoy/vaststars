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

    enum class cross_type: uint8_t {
        ll=0, lt, lr, lb,
        tl,   tt, tr, tb,
        rl,   rt, rr, rb,
        bl,   bt, br, bb,
    };

    enum class straight_type: uint8_t {
        straight = 0,
    };

    struct loction {
        union {
            struct {
                uint8_t x;
                uint8_t y;
            };
            uint16_t id;
        };
        constexpr loction() : id(0xFFFF)
        {}
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
    static_assert(std::is_trivially_copyable_v<loction>);

    using lorryid = objectid;
    using endpointid = objectid;
}
