#include <lua.hpp>
#include <optional>
#include <algorithm>

#include "luaecs.h"
#include "world.h"
#include "entity.h"
#include "select.h"
extern "C" {
#include "prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static void
laboratory_set_tech(world& w, entity& e, laboratory& l, uint16_t techid) {
    l.tech = techid;
    auto& container = w.query_container<recipe_container>(l.container);
    std::vector<uint16_t> limit(container.inslots.size());
    if (techid == 0) {
        for (auto& v : limit) {
            v = 2;
        }
    }
    else {
        recipe_items& r = w.techtree.get_ingredients(w, e.prototype, techid);
        for (size_t i = 0; i < limit.size(); ++i) {
            limit[i] = 2 * (std::min)((uint16_t)1, r.items[i].amount);
        }
    }
    container.recipe_limit(w, limit.data());
}

static void
laboratory_next_tech(world& w, entity& e, laboratory& l, uint16_t techid) {
    if (l.tech == techid) {
        return;
    }
    auto& container = w.query_container<recipe_container>(l.container);
    if (l.tech) {
        recipe_items& oldr = w.techtree.get_ingredients(w, e.prototype, l.tech);
        container.recipe_recover(w, &oldr);
    }
    if (techid) {
        recipe_items& newr = w.techtree.get_ingredients(w, e.prototype, techid);
        if (container.recipe_pickup(w, &newr)) {
            laboratory_set_tech(w, e, l, techid);
            prototype_context tech = w.prototype(techid);
            int time = pt_time(&tech);
            l.progress = time * 100;
            l.status = STATUS_IDLE;
            return;
        }
    }
    laboratory_set_tech(w, e, l, 0);
    l.progress = 0;
    l.status = STATUS_IDLE;
}

static void
laboratory_update(world& w, entity& e, laboratory& l, capacitance& c, bool& updated) {
    prototype_context p = w.prototype(e.prototype);

    // step.1
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return;
    }
    c.shortage += drain;
    if (l.tech == 0) {
        return;
    }

    // step.2
    while (l.progress <= 0) {
        l.low_power = 0;
        prototype_context tech = w.prototype(l.tech);
        recipe_container& container = w.query_container<recipe_container>(l.container);
        if (l.status == STATUS_DONE) {
            int count = pt_count(&tech);
            if (w.techtree.research(l.tech, count, 1)) {
                w.techtree.queue_pop();
                l.tech = 0;
                l.progress = 0;
                l.status = STATUS_IDLE;
                updated = true;
                return;
            }
            l.status = STATUS_IDLE;
        }
        if (l.status == STATUS_IDLE) {
            recipe_items& r = w.techtree.get_ingredients(w, e.prototype, l.tech);
            if (!container.recipe_pickup(w, &r)) {
                return;
            }
            int time = pt_time(&tech);
            l.progress += time * 100;
            l.status = STATUS_DONE;
        }
    }

    // step.3
    if (c.shortage + power > capacitance) {
        l.low_power = 50;
        return;
    }
    c.shortage += power;

    // step.4
    l.progress -= l.speed;
    if (l.low_power > 0) l.low_power--;
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<laboratory, entity>()) {
        entity& e = v.get<entity>();
        laboratory& l = v.get<laboratory>();
        laboratory_set_tech(w, e, l, l.tech);
    }
    return 0;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    bool updated = false;
    for (auto& v : w.select<laboratory, entity, capacitance>()) {
        entity& e = v.get<entity>();
        laboratory& l = v.get<laboratory>();
        capacitance& c = v.get<capacitance>();
        uint16_t techid = w.techtree.queue_top();
        if (techid != l.tech) {
            laboratory_next_tech(w, e, l, techid);
        }
        laboratory_update(w, e, l, c, updated);
    }
    if (updated) {
        uint16_t techid = w.techtree.queue_top();
        for (auto& v : w.select<laboratory, entity>()) {
            entity& e = v.get<entity>();
            laboratory& l = v.get<laboratory>();
            laboratory_next_tech(w, e, l, techid);
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_laboratory_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
