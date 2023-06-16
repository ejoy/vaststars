#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"
#include "util/prototype.h"
#include <bee/nonstd/unreachable.h>

namespace roadnet {
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid) {
        auto speed = prototype::get<"speed">(w, classid);
        l.classid = classid;
        l.item_classid = 0;
        l.item_amount = 0;
        l.status = lorry_status::normal;
        l.time = 1000 / speed;
    }
    void lorryEntry(ecs::lorry& l, roadtype type) {
        switch (type) {
        case roadtype::cross:
            l.maxprogress = l.progress = l.time;
            break;
        case roadtype::straight:
            l.maxprogress = l.progress = l.time;
            break;
        default:
            std::unreachable();
        }
    }
    void lorryGo(ecs::lorry& l, straightid ending, uint16_t item_classid, uint16_t item_amount) {
        l.status = lorry_status::normal;
        l.ending = ending;
        l.item_classid = item_classid;
        l.item_amount = item_amount;
    }
    void lorryReset(ecs::lorry& l, world& w) {
        l.classid = 0;
    }
    void lorryUpdate(ecs::lorry& l, network& w, uint64_t ti) {
        if (l.progress != 0) {
            --l.progress;
        }
    }
    bool lorryNextDirection(ecs::lorry& l, network& w, straightid C, direction& dir) {
        if (l.status != lorry_status::normal) {
            return false;
        }
        route_value val;
        if (route(w, C, l.ending, val)) {
            dir = (direction)val.dir;
            return true;
        }
        l.status = lorry_status::error;
        return false;
    }
    bool lorryReady(ecs::lorry const& l) noexcept {
        if (l.status != lorry_status::normal) {
            return false;
        }
        return l.progress == 0;
    }
    bool lorryInvaild(ecs::lorry const& l) noexcept {
        return l.classid == 0;
    }
}
