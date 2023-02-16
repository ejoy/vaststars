#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"
#include <vector>

namespace roadnet {
    class network;
    bool route(network& w, roadid S, roadid E, direction& dir);
}
