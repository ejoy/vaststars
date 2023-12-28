#pragma once

#include "roadnet/type.h"
#include "util/component.h"
#include <optional>

struct world;

namespace roadnet {
    class network;
    bool startingIsReady(network& w, component::starting const& ep);
    void startingSetOut(world& w, component::starting const& st, lorryid id);

    lorryid& endpointWaitingLorry(network& w, component::endpoint const& ep);
    bool endpointIsReady(network& w, component::endpoint const& ep);
    void endpointSetOut(world& w, component::endpoint const& ep);
    std::optional<uint16_t> endpointDistance(network& w, component::starting const& from, component::endpoint const& to);
    std::optional<uint16_t> endpointDistance(network& w, component::endpoint const& from, component::endpoint const& to);
}
