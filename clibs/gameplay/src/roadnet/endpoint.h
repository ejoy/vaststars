#pragma once

#include "roadnet/type.h"
#include "util/component.h"
#include <optional>

namespace roadnet {
    class network;
    loction endpointGetLoction(network& w, ecs::endpoint const& ep);
    lorryid& endpointWaitingLorry(network& w, ecs::endpoint const& ep);
    bool endpointIsReady(network& w, ecs::endpoint const& ep);
    void endpointSetOut(network& w, ecs::endpoint const& ep, lorryid id);
    void endpointSetOut(network& w, ecs::endpoint const& ep);
    std::optional<uint16_t> endpointDistance(network& w, ecs::endpoint const& from, ecs::endpoint const& to);
}
