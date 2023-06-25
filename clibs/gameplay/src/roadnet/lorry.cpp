#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"
#include "util/prototype.h"

namespace roadnet {
    void lorryInit(ecs::lorry& l) {
        l.classid = 0;
    }
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid) {
        auto speed = prototype::get<"speed">(w, classid);
        l.classid = classid;
        l.item_classid = 0;
        l.item_amount = 0;
        l.status = lorry_status::normal;
        l.time = 1000 / speed;
    }
    void lorryDestroy(ecs::lorry& l) {
        l.classid = 0;
    }
    bool lorryInvalid(ecs::lorry& l) {
        return l.classid == 0;
    }
    void lorryEntry(ecs::lorry& l, uint8_t x, uint8_t y, uint8_t z) {
        l.maxprogress = l.progress = l.time;
        l.x = x;
        l.y = y;
        l.z = z;
    }
    void lorryGo(ecs::lorry& l, ecs::endpoint& ending, uint16_t item_classid, uint16_t item_amount) {
        l.status = lorry_status::normal;
        l.ending = ending.rev_neighbor;
        l.item_classid = item_classid;
        l.item_amount = item_amount;
        ending.lorry++;
    }
    void lorryReset(ecs::lorry& l, world& w) {
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
        return l.progress == 0;
    }
}
