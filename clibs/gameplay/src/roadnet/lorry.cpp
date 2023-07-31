#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/route.h"
#include "core/world.h"
#include "core/backpack.h"
#include "util/prototype.h"

namespace roadnet {
    void lorryInit(ecs::lorry& l) {
        l.prototype = 0;
    }
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid) {
        auto speed = prototype::get<"speed">(w, classid);
        l.prototype = classid;
        l.item_prototype = 0;
        l.item_amount = 0;
        l.status = lorry_status::normal;
        l.time = 1000 / speed;
    }
    void lorryDestroy(ecs::lorry& l, world& w) {
        assert(l.prototype != 0);
        backpack_place(w, l.prototype, 1);
        l.prototype = 0;
        if (l.item_prototype != 0 && l.item_amount != 0) {
            backpack_place(w, l.item_prototype, l.item_amount);
            l.item_prototype = 0;
            l.item_amount = 0;
        }
    }
    bool lorryInvalid(ecs::lorry& l) {
        return l.prototype == 0;
    }
    void lorryBlink(ecs::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z) {
        l.maxprogress = l.progress = 0;
        l.prev_x = x;
        l.prev_y = y;
        l.prev_z = z;
        l.x = x;
        l.y = y;
        l.z = z;
        w.rw.LorryEntity(w, l).enable_tag<ecs::lorry_changed>();
    }
    void lorryMove(ecs::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z) {
        l.maxprogress = l.progress = l.time;
        l.prev_x = l.x;
        l.prev_y = l.y;
        l.prev_z = l.z;
        l.x = x;
        l.y = y;
        l.z = z;
        w.rw.LorryEntity(w, l).enable_tag<ecs::lorry_changed>();
    }
    void lorryItemReset(ecs::lorry& l) {
        l.item_prototype = 0;
        l.item_amount = 0;
    }
    void lorryItemSet(ecs::lorry& l, uint16_t item, uint16_t amount) {
        assert(l.item_prototype == 0 && l.item_amount == 0);
        l.item_prototype = item;
        l.item_amount = amount;
    }
    void lorryGo(ecs::lorry& l, ecs::endpoint& ending) {
        l.status = lorry_status::normal;
        l.ending = ending.rev_neighbor;
        ending.lorry++;
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
