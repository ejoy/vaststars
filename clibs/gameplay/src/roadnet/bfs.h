#pragma once

#include "roadnet/type.h"
#include "roadnet/road.h"
#include <vector>

namespace roadnet {
    class world;
    bool route(world& w, roadid S, roadid E, direction& dir);
}
