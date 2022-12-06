#pragma once

#include "roadnet_type.h"
#include "roadnet_road.h"
#include <vector>

namespace roadnet {
    class world;
    bool route(world& w, roadid S, roadid E, direction& dir);
}
