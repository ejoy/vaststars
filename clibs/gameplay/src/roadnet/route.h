#pragma once

#include <optional>

#include "roadnet/type.h"

namespace roadnet {
    class network;
    std::optional<direction> route_direction(network& w, straightid S, straightid E);
    std::optional<uint16_t> route_distance(network& w, straightid S, straightid E);
}
