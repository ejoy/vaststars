#include "roadnet/road_endpoint.h"
#include "roadnet/network.h"
#include "roadnet/route.h"

namespace roadnet::road {
    loction endpoint::getLoction(network& w) const {
        return w.StraightRoad(rev_neighbor).waitingLoction(w);
    }

    lorryid& endpoint::waitingLorry(network& w) {
        return w.StraightRoad(rev_neighbor).waitingLorry(w);
    }
    bool endpoint::isReady(network& w) {
        return w.StraightRoad(neighbor).canEntry(w);
    }
    void endpoint::setOut(network& w, lorryid id) {
        bool ok = w.StraightRoad(neighbor).tryEntry(w, id);
        (void)ok;
        assert(ok);
    }
    void endpoint::setOut(network& w) {
        auto& id = waitingLorry(w);
        setOut(w, id);
        id = lorryid::invalid();
    }
    std::optional<uint16_t> endpoint::distance(network& w, road::endpoint const& to) const {
        route_value val;
        if (!route(w, neighbor, to.rev_neighbor, val)) {
            return std::nullopt;
        }
        return (uint16_t)val.n;
    }
}
