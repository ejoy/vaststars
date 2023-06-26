#pragma once

#include "roadnet/type.h"
#include "util/component.h"
#include <optional>

struct world;

namespace roadnet {
    class network;
    lorryid& endpointWaitingLorry(network& w, ecs::endpoint const& ep);
    bool endpointIsReady(network& w, ecs::endpoint const& ep);
    void endpointSetOut(world& w, ecs::endpoint const& ep, lorryid id);
    void endpointSetOut(world& w, ecs::endpoint const& ep);
    std::optional<uint16_t> endpointDistance(network& w, ecs::endpoint const& from, ecs::endpoint const& to);
}
