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
        roadid neighbor;
        roadid rev_neighbor;
        lorryid& waitingLorry(network& w);
        bool isReady(network& w);
        bool setOut(network& w, lorryid id);
        bool setOut(network& w);
        void setOutForce(network& w, lorryid id);
        void setOutForce(network& w);
    };
    static_assert(std::is_trivial_v<endpoint>);
}
