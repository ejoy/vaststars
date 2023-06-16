#pragma once

#include <stdint.h>
#include <assert.h>
#include <memory.h>
#include <compare>

namespace roadnet {
    enum class direction: uint8_t {
        l = 0,
        t,
        r,
        b,
    };

    enum class roadtype: uint8_t {
        straight,
        cross,
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
        uint8_t x;
        uint8_t y;
        uint8_t z: 4;
        uint8_t w: 4;
        constexpr map_coord() noexcept
            : x(0)
            , y(0)
            , z((uint8_t)map_index::invaild)
            , w(0)
        { }
        constexpr map_coord(loction loc, map_index z, cross_type w) noexcept
            : x(loc.x)
            , y(loc.y)
            , z((uint8_t)z)
            , w((uint8_t)w)
        { }
        void set(map_index z) noexcept {
            this->z = (uint8_t)z;
        }
        uint32_t get_value() const noexcept {
            uint32_t v = 0;
            memcpy(&v, this, sizeof(map_coord));
            return v;
        }
        loction get_loction() const noexcept {
            return {x,y};
        }
    };
    static_assert(sizeof(map_coord) == 3*sizeof(uint8_t));

    enum class lorry_status: uint8_t {
        normal,
        error,
        fatal,
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
    using endpointid = objectid;
    using straightid = objectid;
    using crossid = objectid;
}
