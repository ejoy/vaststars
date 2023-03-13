#include "roadnet/road_endpoint.h"
#include "roadnet/network.h"

namespace roadnet::road {
    lorryid& endpoint::waitingLorry(network& w) {
        return w.StraightRoad(rev_neighbor).waitingLorry(w);
    }
    bool endpoint::setOut(network& w) {
        auto& id = waitingLorry(w);
        if (w.StraightRoad(neighbor).tryEntry(w, id)) {
            id = lorryid::invalid();
            return true;
        }
        return false;
    }
}
