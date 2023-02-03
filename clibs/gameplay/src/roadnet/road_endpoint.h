#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <list>
#include <map>
#include <vector>

namespace roadnet {
    class world;
}

namespace roadnet::road {
    struct endpoint {
        enum class type : uint8_t {
            in = 0,
            wait,
            out,
            max,
        };
        loction loc;
        road_coord coord;
        void addLorry(world& w, lorryid l, type offset);
        bool hasLorry(world& w, type offset) const;
        void delLorry(world& w, type offset);
        lorryid getLorry(world& w, type offset) const;
        bool setOut(world& w, lorryid lorryId, endpointid ending);
        bool setOut(world& w, endpointid ending);
        void update(world& w, uint64_t ti);
    private:
        lorryid lorry[(size_t)type::max] = {
            lorryid::invalid(),
            lorryid::invalid(),
            lorryid::invalid(),
        };
    };
}
