#pragma once

#include <vector>
#include <type_traits>
#include "roadnet/type.h"
#include <bee/nonstd/unreachable.h>
#include <cassert>

namespace roadnet {
    enum class roadtype: uint8_t {
        straight,
        cross,
    };

    struct straightid {
    public:
        constexpr straightid() = default;
        constexpr straightid(uint16_t index)
            : index(index+1)
        {}

        //TODO: use consteval
        static constexpr straightid invalid() {
            return {};
        }
        explicit operator bool() const {
            return invalid() != *this;
        }
        auto operator <=>(const straightid& o) const = default;

        uint16_t get_index() const {
            assert(index > 0);
            return index - 1;
        }
    private:
        uint16_t index;
    };
    static_assert(sizeof(straightid)==sizeof(uint16_t));
    static_assert(std::is_trivial_v<straightid>);

    struct crossid {
    public:
        constexpr crossid() = default;
        constexpr crossid(uint16_t index)
            : index(index+1)
        {}

        //TODO: use consteval
        static constexpr crossid invalid() {
            return {};
        }
        explicit operator bool() const {
            return invalid() != *this;
        }
        auto operator <=>(const crossid& o) const = default;

        uint16_t get_index() const {
            assert(index > 0);
            return index - 1;
        }
    private:
        uint16_t type  : 1;
        uint16_t index : 15;
    };
    static_assert(sizeof(crossid)==sizeof(uint16_t));
    static_assert(std::is_trivial_v<crossid>);
}
