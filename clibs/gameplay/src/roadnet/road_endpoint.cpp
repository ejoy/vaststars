#include "roadnet/road_endpoint.h"
#include "roadnet/world.h"

namespace roadnet::road {
    void endpoint::addLorry(world& w, lorryid l, type offset) {
        w.Lorry(l).initTick(kTime);
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

    lorryid endpoint::getWaitLorry(world& w) const {
        return lorry[(size_t)type::wait];
    }
    void endpoint::delWaitLorry(world& w) {
        lorry[(size_t)type::wait] = lorryid::invalid();
    }

    bool endpoint::canEntry(world& w, type offset) {
        switch (offset) {
        case type::in:
            return !hasLorry(w, type::in) && !hasLorry(w, type::straight);
        case type::out:
            return !hasLorry(w, type::out) && !hasLorry(w, type::straight);
        case type::wait:
            return !hasLorry(w, type::wait);
        case type::straight:
            return !hasLorry(w, type::in) && !hasLorry(w, type::out);
        }
        return false;
    }

    bool endpoint::tryEntry(world& w, lorryid l, type offset) {
        if (!canEntry(w, offset)) {
            return false;
        }
        addLorry(w, l, offset);
        return true;
    }

    void endpoint::setOut(world& w, lorryid lorryId, endpointid ending) {
        auto& e = w.Endpoint(ending);
        auto& lorry = w.Lorry(lorryId);
        lorry.ending = e.coord;
        addLorry(w, lorryId, type::out);
    }

    bool endpoint::setOut(world& w, endpointid ending) {
        if (!canEntry(w, type::out)) {
            return false;
        }
        auto lorryId = getLorry(w, type::wait);
        delLorry(w, type::wait);
        setOut(w, lorryId, ending);
        return true;
    }

    void endpoint::update(world& w, uint64_t ti) {
        auto l = getLorry(w, type::in);
        if (l) {
            auto& lorry = w.Lorry(l);
            if (lorry.ready() && canEntry(w, type::wait)) {
                addLorry(w, l, type::wait);
                delLorry(w, type::in);
            }
        }
    }
    void endpoint::updateStraight(world& w, std::function<bool(lorryid)> tryEntry) {
        if (auto l = getLorry(w, type::straight)) {
            if (w.Lorry(l).ready() && tryEntry(l)) {
                delLorry(w, type::straight);
            }
        }
        else if (auto l = getLorry(w, type::out)) {
            if (w.Lorry(l).ready() && tryEntry(l)) {
                delLorry(w, type::out);
            }
        }
    }

    lorryid& endpoint::getOutOrStraight(world& w) {
        if (hasLorry(w, type::out)) {
            return lorry[(size_t)type::out];
        }
        return lorry[(size_t)type::straight];
    }
}

