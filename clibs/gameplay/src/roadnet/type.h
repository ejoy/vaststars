#pragma once

#include <stdint.h>
#include <compare>
#include <type_traits>

namespace roadnet {
    enum class direction: uint8_t {
        l = 0,
        t,
        r,
        b,
    };

    enum class cross_type: uint8_t {
        ll=0, lt, lr, lb,
        tl,   tt, tr, tb,
        rl,   rt, rr, rb,
        bl,   bt, br, bb,
    };

    struct loction {
        union {
            struct {
                uint8_t x;
                uint8_t y;
            };
            uint16_t id;
        };
        constexpr loction() = default;
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
    static_assert(sizeof(loction) == sizeof(uint16_t));
    static_assert(std::is_trivial_v<loction>);

    enum class map_index : uint8_t {
        w0      = 0x0,
        w1      = 0x1,
        unset   = 0xE,
        invaild = 0xF,
    };

    struct map_coord {
        constexpr map_coord() noexcept
            : x(0)
            , y(0)
            , z((uint8_t)map_index::invaild)
        { }
        constexpr map_coord(loction loc, map_index i, cross_type ct) noexcept
            : x(loc.x)
            , y(loc.y)
            , z(make_z(i, ct))
        { }
        void set(map_index i) noexcept {
            z = ((uint8_t)i & 0x0F) | (z & 0xF0);
        }
        loction get_loction() const noexcept {
            return {x,y};
        }
        static constexpr uint8_t make_z(map_index i, cross_type ct) {
            return ((uint8_t)i & 0x0F) | ((uint8_t)ct << 4);
        }
        static constexpr cross_type get_cross_type(uint8_t z) noexcept {
            return cross_type(z >> 4);
        }
        static constexpr map_index get_map_index(uint8_t z) noexcept {
            return map_index(z & 0x0F);
        }
        uint8_t x;
        uint8_t y;
        uint8_t z;
    };
    static_assert(sizeof(map_coord) == 3*sizeof(uint8_t));

    enum class lorry_status: uint8_t {
        normal,
        wait,
        error,
    };

    struct objectid {
        uint16_t index;

        constexpr objectid() noexcept : index(0xFFFF) {}
        constexpr objectid(uint16_t index) noexcept: index(index) {}

        //TODO: use consteval
        static constexpr objectid invalid() {
            return {};
        }
        explicit operator bool() const noexcept {
            return index != 0xFFFF;
        }
        auto operator <=>(const objectid& o) const noexcept = default;
        uint16_t get_index() const noexcept {
            return index;
        }
    };
    using lorryid = objectid;
    using straightid = objectid;
    using crossid = objectid;
}
