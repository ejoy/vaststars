#pragma once

#include "roadnet_type.h"
#include "roadnet_road.h"
#include <vector>

namespace roadnet {
    class world;
    bool bfs(world& w, roadid start, roadid end, std::vector<direction>& path);
}
