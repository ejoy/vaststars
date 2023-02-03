#include "roadnet/road_endpoint.h"
#include "roadnet/world.h"

namespace roadnet::road {
    void endpoint::addLorry(world& w, lorryid l, type offset) {
        lorry[(size_t)offset] = l;
    }

    bool endpoint::hasLorry(world& w, type offset) const {
        return !!lorry[(size_t)offset];
    }

    void endpoint::delLorry(world& w, type offset) {
        lorry[(size_t)offset] = lorryid::invalid();
    }

    lorryid endpoint::getLorry(world& w, type offset) const {
        return lorry[(size_t)offset];
    }

    bool endpoint::setOut(world& w, lorryid lorryId, endpointid ending) {
        if (!hasLorry(w, type::out)) {
            return false;
        }
        auto& e = w.Endpoint(ending);
        auto& lorry = w.Lorry(lorryId);
        lorry.ending = e.coord;
        lorry.initTick(kTime);
        addLorry(w, lorryId, type::out);
        return true;
    }

    bool endpoint::setOut(world& w, endpointid ending) {
        if (!hasLorry(w, type::out)) {
            return false;
        }
        auto lorryId = getLorry(w, type::wait);
        delLorry(w, type::wait);
        auto& e = w.Endpoint(ending);
        auto& lorry = w.Lorry(lorryId);
        lorry.ending = e.coord;
        lorry.initTick(kTime);
        addLorry(w, lorryId,type::out);
        return true;
    }

    void endpoint::update(world& w, uint64_t ti) {
        auto l = getLorry(w, type::in);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (lorry.ready() && !hasLorry(w, type::wait)) {
                addLorry(w, l, type::wait);
                delLorry(w, type::in);
            }
        }
    }
}

