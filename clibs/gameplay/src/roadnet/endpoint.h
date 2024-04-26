#pragma once

#include <optional>

#include "roadnet/type.h"
#include "util/component.h"

struct world;

namespace roadnet {
    class network;
    bool startingIsReady(network& w, const component::starting& ep);
    void startingSetOut(world& w, const component::starting& st, lorryid id);

    lorryid& endpointWaitingLorry(network& w, const component::endpoint& ep);
    bool endpointIsReady(network& w, const component::endpoint& ep);
    void endpointSetOut(world& w, const component::endpoint& ep);
    std::optional<uint16_t> endpointDistance(network& w, const component::starting& from, const component::endpoint& to);
    std::optional<uint16_t> endpointDistance(network& w, const component::endpoint& from, const component::endpoint& to);
}
