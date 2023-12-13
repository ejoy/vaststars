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
        l.target = lorry_target::home;
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
        l.status = lorry_status::normal;
        l.maxprogress = l.progress = l.time;
        l.prev_x = l.x;
        l.prev_y = l.y;
        l.prev_z = l.z;
        l.x = x;
        l.y = y;
        l.z = z;
        w.rw.LorryEntity(w, l).enable_tag<ecs::lorry_changed>();
    }
    void lorryGoMov1(ecs::lorry& l, uint16_t item, ecs::endpoint& mov1, ecs::endpoint& mov2) {
        l.target = lorry_target::mov1;
        l.status = lorry_status::normal;
        l.ending = mov1.rev_neighbor;
        l.mov2 = mov2.rev_neighbor;
        l.item_prototype = item;
        l.item_amount = 0;
    }
    void lorryGoMov2(ecs::lorry& l, roadnet::straightid mov2, uint16_t amount) {
        l.target = lorry_target::mov2;
        l.status = lorry_status::normal;
        l.ending = mov2;
        l.mov2 = {};
        l.item_amount = amount;
    }
    void lorryGoHome(ecs::lorry& l, ecs::endpoint& home) {
        l.target = lorry_target::home;
        l.status = lorry_status::normal;
        l.ending = home.rev_neighbor;
        l.mov2 = {};
        l.item_prototype = 0;
        l.item_amount = 0;
    }
    void lorryTargetNone(ecs::lorry& l) {
        l.target = lorry_target::home;
        l.status = lorry_status::target_none;
        l.ending = {};
        l.mov2 = {};
    }
    void lorryUpdate(ecs_api::entity<ecs::lorry>& e, ecs::lorry& l) {
        if (l.progress != 0) {
            --l.progress;
            if (l.progress == 0) {
                l.status = lorry_status::wait;
                e.enable_tag<ecs::lorry_changed>();
            }
        }
    }
    bool lorryNextDirection(ecs::lorry& l, world& w, straightid C, direction& dir) {
        if (l.status == lorry_status::target_unreachable || l.status == lorry_status::target_none) {
            return false;
        }
        if (auto direction = route_direction(w.rw, C, l.ending)) {
            dir = *direction;
            return true;
        }
        l.status = lorry_status::target_unreachable;
        return false;
    }
    bool lorryReady(ecs::lorry const& l) noexcept {
        return l.progress == 0;
    }
}
