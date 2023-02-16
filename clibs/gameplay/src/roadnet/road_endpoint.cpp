#include "roadnet/road_endpoint.h"
#include "roadnet/world.h"

namespace roadnet::road {
    void endpoint::addLorry(world& w, lorryid l, straight_type offset) {
        w.Lorry(l).initTick(kTime);
        lorry[(size_t)offset] = l;
    }

    bool endpoint::hasLorry(straight_type offset) const {
        return !!lorry[(size_t)offset];
    }

    void endpoint::delLorry(straight_type offset) {
        lorry[(size_t)offset] = lorryid::invalid();
    }

    lorryid endpoint::getLorry(straight_type offset) const {
        return lorry[(size_t)offset];
    }

    lorryid endpoint::getWaitLorry() const {
        return lorry[(size_t)straight_type::endpoint_wait];
    }
    void endpoint::delWaitLorry() {
        lorry[(size_t)straight_type::endpoint_wait] = lorryid::invalid();
    }

    bool endpoint::canEntry(straight_type offset) {
        switch (offset) {
        case straight_type::endpoint_in:
            return !hasLorry(straight_type::endpoint_in) && !hasLorry(straight_type::straight);
        case straight_type::endpoint_out:
            return !hasLorry(straight_type::endpoint_out) && !hasLorry(straight_type::straight);
        case straight_type::endpoint_wait:
            return !hasLorry(straight_type::endpoint_wait);
        case straight_type::straight:
            return !hasLorry(straight_type::endpoint_in) && !hasLorry(straight_type::endpoint_out);
        }
        return false;
    }

    bool endpoint::tryEntry(world& w, lorryid l, straight_type offset) {
        if (!canEntry(offset)) {
            return false;
        }
        addLorry(w, l, offset);
        return true;
    }

    void endpoint::setOut(world& w, lorryid lorryId, endpointid ending) {
        auto& e = w.Endpoint(ending);
        auto& lorry = w.Lorry(lorryId);
        lorry.ending = e.coord;
        addLorry(w, lorryId, straight_type::endpoint_out);
    }

    bool endpoint::setOut(world& w, endpointid ending) {
        if (!canEntry(straight_type::endpoint_out)) {
            return false;
        }
        auto lorryId = getLorry(straight_type::endpoint_wait);
        delLorry(straight_type::endpoint_wait);
        setOut(w, lorryId, ending);
        return true;
    }

    void endpoint::update(world& w, uint64_t ti) {
        auto l = getLorry(straight_type::endpoint_in);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (lorry.ready() && canEntry(straight_type::endpoint_wait)) {
                addLorry(w, l, straight_type::endpoint_wait);
                delLorry(straight_type::endpoint_in);
            }
        }
    }
    void endpoint::updateStraight(world& w, std::function<bool(lorryid)> tryEntry) {
        if (auto l = getLorry(straight_type::straight)) {
            if (w.Lorry(l).ready() && tryEntry(l)) {
                delLorry(straight_type::straight);
            }
        }
        else if (auto l = getLorry(straight_type::endpoint_out)) {
            if (w.Lorry(l).ready() && tryEntry(l)) {
                delLorry(straight_type::endpoint_out);
            }
        }
    }

    lorryid& endpoint::getOutOrStraight() {
        if (hasLorry(straight_type::endpoint_out)) {
            return lorry[(size_t)straight_type::endpoint_out];
        }
        return lorry[(size_t)straight_type::straight];
    }
}

