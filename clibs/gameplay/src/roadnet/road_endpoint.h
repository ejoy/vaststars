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
        bool setOut(network& w);
    };
}
