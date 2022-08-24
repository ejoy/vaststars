#pragma once

#include "roadnet_type.h"
#include "roadnet_road.h"
#include <vector>

namespace roadnet {
    struct world;
    bool bfs(world& w, roadid start, roadid end, std::vector<char>& path);
}
