#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <list>
#include <map>
#include <vector>
#include <functional>

namespace roadnet {
    class network;
}

namespace roadnet::road {
    struct endpoint {
        loction loc;
        road_coord coord;
        bool canEntry(straight_type offset);
        bool tryEntry(network& w, lorryid l, straight_type offset);
        void setOut(network& w, lorryid lorryId, endpointid ending);
        bool setOut(network& w, endpointid ending);

        lorryid getWaitLorry() const;
        void delWaitLorry();

        void update(network& w, uint64_t ti);
        void updateStraight(network& w, std::function<bool(lorryid)> tryEntry);
        lorryid& getOutOrStraight();
        lorryid getLorry(straight_type offset) const;

    private:
        void addLorry(network& w, lorryid l, straight_type offset);
        bool hasLorry(straight_type offset) const;
        void delLorry(straight_type offset);

        lorryid lorry[(size_t)straight_type::max] = {
            lorryid::invalid(),
            lorryid::invalid(),
            lorryid::invalid(),
            lorryid::invalid(),
        };
    };
}
