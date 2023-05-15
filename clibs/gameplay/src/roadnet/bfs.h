#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"
#include <vector>

namespace roadnet {
    class network;
    struct route_info;
    bool route(network& w, roadid S, roadid E, route_info& info);
}
