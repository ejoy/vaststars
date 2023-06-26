#pragma once

#include "roadnet/type.h"
#include "util/component.h"
#include <optional>

struct world;

namespace roadnet {
    class network;
    bool startingIsReady(network& w, ecs::starting const& ep);
    void startingSetOut(world& w, ecs::starting const& st, lorryid id);

    lorryid& endpointWaitingLorry(network& w, ecs::endpoint const& ep);
    bool endpointIsReady(network& w, ecs::endpoint const& ep);
    void endpointSetOut(world& w, ecs::endpoint const& ep);
    std::optional<uint16_t> endpointDistance(network& w, ecs::starting const& from, ecs::endpoint const& to);
    std::optional<uint16_t> endpointDistance(network& w, ecs::endpoint const& from, ecs::endpoint const& to);
}
