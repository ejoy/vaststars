#pragma once

#include "roadnet/type.h"
#include <optional>

namespace roadnet {
    class network;
}

namespace roadnet::road {
    struct endpoint {
        straightid neighbor;
        straightid rev_neighbor;
        loction getLoction(network& w) const;
        lorryid& waitingLorry(network& w);
        bool isReady(network& w);
        void setOut(network& w, lorryid id);
        void setOut(network& w);
        std::optional<uint16_t> distance(network& w, road::endpoint const& to) const;
    };
}
