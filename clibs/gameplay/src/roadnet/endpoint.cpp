#include "roadnet/endpoint.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"

namespace roadnet {
    bool startingIsReady(network& w, component::starting const& st) {
        return w.StraightRoad(st.neighbor).canEntry(w);
    }
    void startingSetOut(world& w, component::starting const& st, lorryid id) {
        w.rw.StraightRoad(st.neighbor).blink(w, id);
    }

    lorryid& endpointWaitingLorry(network& w, component::endpoint const& ep) {
        return w.StraightRoad(ep.rev_neighbor).waitingLorry(w);
    }
    bool endpointIsReady(network& w, component::endpoint const& ep) {
        return w.StraightRoad(ep.neighbor).canEntry(w);
    }
    void endpointSetOut(world& w, component::endpoint const& ep) {
        auto& id = endpointWaitingLorry(w.rw, ep);
        w.rw.StraightRoad(ep.neighbor).move(w, id);
        id = lorryid::invalid();
    }
    std::optional<uint16_t> endpointDistance(network& w, component::starting const& from, component::endpoint const& to) {
        return route_distance(w, from.neighbor, to.rev_neighbor);
    }
    std::optional<uint16_t> endpointDistance(network& w, component::endpoint const& from, component::endpoint const& to) {
        return route_distance(w, from.neighbor, to.rev_neighbor);
    }
}
