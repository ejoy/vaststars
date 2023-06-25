#include "roadnet/endpoint.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"

namespace roadnet {
    loction endpointGetLoction(network& w, ecs::endpoint const& ep) {
        return w.StraightRoad(ep.rev_neighbor).waitingLoction(w);
    }

    lorryid& endpointWaitingLorry(network& w, ecs::endpoint const& ep) {
        return w.StraightRoad(ep.rev_neighbor).waitingLorry(w);
    }
    bool endpointIsReady(network& w, ecs::endpoint const& ep) {
        return w.StraightRoad(ep.neighbor).canEntry(w);
    }
    void endpointSetOut(world& w, ecs::endpoint const& ep, lorryid id) {
        bool ok = w.rw.StraightRoad(ep.neighbor).tryEntry(w, id);
        (void)ok;
        assert(ok);
    }
    void endpointSetOut(world& w, ecs::endpoint const& ep) {
        auto& id = endpointWaitingLorry(w.rw, ep);
        endpointSetOut(w, ep, id);
        id = lorryid::invalid();
    }
    std::optional<uint16_t> endpointDistance(network& w, ecs::endpoint const& from, ecs::endpoint const& to) {
        route_value val;
        if (!route(w, from.neighbor, to.rev_neighbor, val)) {
            return std::nullopt;
        }
        return (uint16_t)val.n;
    }
}
