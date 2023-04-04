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
    struct roadid {
    public:
        constexpr roadid() = default;
        constexpr roadid(roadtype type, uint16_t index)
            : type(0)
            , index(index+1)
        {
            switch (type) {
            case roadtype::cross:
                this->type = 1;
                break;
            case roadtype::straight:
                this->type = 0;
                break;
            default:
                std::unreachable();
            }
        }

        //TODO: use consteval
        static constexpr roadid invalid() {
            return {};
        }
        explicit operator bool() const {
            return invalid() != *this;
        }
        auto operator <=>(const roadid& o) const = default;

        roadtype get_type() const {
            switch (type) {
            case 1:
                return roadtype::cross;
            case 0:
                return roadtype::straight;
            default:
                std::unreachable();
            }
        }
        uint16_t get_index() const {
            assert(index > 0);
            return index - 1;
        }
    private:
        uint16_t type  : 1;
        uint16_t index : 15;
    };
    static_assert(sizeof(roadid)==sizeof(uint16_t));
    static_assert(std::is_trivial_v<roadid>);
}
