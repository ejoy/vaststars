#include "roadnet/road_endpoint.h"
#include "roadnet/network.h"

namespace roadnet::road {
    lorryid& endpoint::waitingLorry(network& w) {
        return w.StraightRoad(rev_neighbor).waitingLorry(w);
    }
    bool endpoint::isReady(network& w) {
        return w.StraightRoad(neighbor).canEntry(w);
    }
    bool endpoint::setOut(network& w, lorryid id) {
        return w.StraightRoad(neighbor).tryEntry(w, id);
    }
    bool endpoint::setOut(network& w) {
        auto& id = waitingLorry(w);
        if (setOut(w, id)) {
            id = lorryid::invalid();
            return true;
        }
        return false;
    }
    void endpoint::setOutForce(network& w, lorryid id) {
        bool ok = w.StraightRoad(neighbor).tryEntry(w, id);
        (void)ok;
        assert(ok);
    }
    void endpoint::setOutForce(network& w) {
        auto& id = waitingLorry(w);
        setOutForce(w, id);
        id = lorryid::invalid();
    }
}
