#include "roadnet/endpoint.h"

#include "core/world.h"
#include "roadnet/network.h"
#include "roadnet/route.h"

namespace roadnet {
    bool startingIsReady(network& w, const component::starting& st) {
        return w.StraightRoad(st.neighbor).canEntry(w);
    }
    void startingSetOut(world& w, const component::starting& st, lorryid id) {
        w.rw.StraightRoad(st.neighbor).blink(w, id);
    }

    lorryid& endpointWaitingLorry(network& w, const component::endpoint& ep) {
        return w.StraightRoad(ep.rev_neighbor).waitingLorry(w);
    }
    bool endpointIsReady(network& w, const component::endpoint& ep) {
        return w.StraightRoad(ep.neighbor).canEntry(w);
    }
    void endpointSetOut(world& w, const component::endpoint& ep) {
        auto& id = endpointWaitingLorry(w.rw, ep);
        w.rw.StraightRoad(ep.neighbor).move(w, id);
        id = lorryid::invalid();
    }
    std::optional<uint16_t> endpointDistance(network& w, const component::starting& from, const component::endpoint& to) {
        return route_distance(w, from.neighbor, to.rev_neighbor);
    }
    std::optional<uint16_t> endpointDistance(network& w, const component::endpoint& from, const component::endpoint& to) {
        return route_distance(w, from.neighbor, to.rev_neighbor);
    }
}
