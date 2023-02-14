#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <list>
#include <map>
#include <vector>
#include <functional>

namespace roadnet {
    class world;
}

namespace roadnet::road {
    struct endpoint {
        enum class type : uint8_t {
            in = 0,
            wait,
            out,
            straight,
            max,
        };
        loction loc;
        road_coord coord;
        bool canEntry(world& w, type offset);
        bool tryEntry(world& w, lorryid l, type offset);
        void setOut(world& w, lorryid lorryId, endpointid ending);
        bool setOut(world& w, endpointid ending);

        lorryid getWaitLorry(world& w) const;
        void delWaitLorry(world& w);

        void update(world& w, uint64_t ti);
        void updateStraight(world& w, std::function<bool(lorryid)> tryEntry);
        lorryid& getOutOrStraight(world& w);

    private:
        void addLorry(world& w, lorryid l, type offset);
        lorryid getLorry(world& w, type offset) const;
        bool hasLorry(world& w, type offset) const;
        void delLorry(world& w, type offset);

        lorryid lorry[(size_t)type::max] = {
            lorryid::invalid(),
            lorryid::invalid(),
            lorryid::invalid(),
        };
    };
}
