#pragma once

#include "roadnet/type.h"
#include "roadnet/coord.h"
#include <list>
#include <map>
#include <vector>
#include <functional>
#include <optional>

namespace roadnet {
    class network;
}

namespace roadnet::road {
    struct endpoint {
        roadid neighbor;
        roadid rev_neighbor;
        loction loc;
        lorryid& waitingLorry(network& w);
        bool isReady(network& w);
        void setOut(network& w, lorryid id);
        void setOut(network& w);
        std::optional<uint16_t> distance(network& w, road::endpoint const& to) const;
    };
    static_assert(std::is_trivial_v<endpoint>);
}
