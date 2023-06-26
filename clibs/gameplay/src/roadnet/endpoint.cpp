#include "roadnet/endpoint.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"

namespace roadnet {
    bool startingIsReady(network& w, ecs::starting const& st) {
        return w.StraightRoad(st.neighbor).canEntry(w);
    }
    void startingSetOut(world& w, ecs::starting const& st, lorryid id) {
        bool ok = w.rw.StraightRoad(st.neighbor).tryEntry(w, id);
        (void)ok;
        assert(ok);
    }

    lorryid& endpointWaitingLorry(network& w, ecs::endpoint const& ep) {
        return w.StraightRoad(ep.rev_neighbor).waitingLorry(w);
    }
    bool endpointIsReady(network& w, ecs::endpoint const& ep) {
        return w.StraightRoad(ep.neighbor).canEntry(w);
    }
    void endpointSetOut(world& w, ecs::endpoint const& ep) {
        auto& id = endpointWaitingLorry(w.rw, ep);
        bool ok = w.rw.StraightRoad(ep.neighbor).tryEntry(w, id);
        (void)ok;
        assert(ok);
        id = lorryid::invalid();
    }
    std::optional<uint16_t> endpointDistance(network& w, ecs::starting const& from, ecs::endpoint const& to) {
        route_value val;
        if (!route(w, from.neighbor, to.rev_neighbor, val)) {
            return std::nullopt;
        }
        return (uint16_t)val.n;
    }
    std::optional<uint16_t> endpointDistance(network& w, ecs::endpoint const& from, ecs::endpoint const& to) {
        route_value val;
        if (!route(w, from.neighbor, to.rev_neighbor, val)) {
            return std::nullopt;
        }
        return (uint16_t)val.n;
    }
}
