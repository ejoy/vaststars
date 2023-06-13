#pragma once

#include "roadnet/type.h"
#include <vector>

namespace roadnet {
    class network;
    struct route_value;
    bool route(network& w, straightid S, straightid E, route_value& val);
}
