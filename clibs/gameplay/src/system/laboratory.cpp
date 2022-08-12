#include <lua.hpp>
#include <optional>
#include <algorithm>

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_INVALID 2

static void
laboratory_set_tech(lua_State* L, world& w, ecs::entity& e, ecs::laboratory& l, uint16_t techid) {
    l.tech = techid;
    auto& container = w.query_container<recipe_container>(l.container);
    std::vector<uint16_t> limit(container.inslots.size());
    if (techid == 0 || l.status == STATUS_INVALID) {
        for (auto& v : limit) {
            v = 2;
        }
    }
    else {
        auto& r = w.techtree.get_ingredients(L, w, e.prototype, techid);
        assert(r);
        for (size_t i = 0; i < limit.size(); ++i) {
            limit[i] = 2 * (std::max)((uint16_t)1, (*r)[i+1].amount);
        }
    }
    container.recipe_limit(w, limit.data());
}

static void
laboratory_next_tech(lua_State* L, world& w, ecs::entity& e, ecs::laboratory& l, uint16_t techid) {
    if (l.tech == techid) {
        return;
    }
    auto& container = w.query_container<recipe_container>(l.container);
    if (l.tech) {
        auto& oldr = w.techtree.get_ingredients(L, w, e.prototype, l.tech);
        if (oldr) {
            container.recipe_recover(w, to_recipe(oldr));
        }
    }
    if (!techid) {
        laboratory_set_tech(L, w, e, l, 0);
        l.progress = 0;
        l.status = STATUS_IDLE;
        return;
    }

    auto& newr = w.techtree.get_ingredients(L, w, e.prototype, techid);
    if (!newr) {
        l.tech = techid;
        l.progress = 0;
        l.status = STATUS_INVALID;
        return;
    }
    laboratory_set_tech(L, w, e, l, techid);
    if (container.recipe_pickup(w, to_recipe(newr))) {
        prototype_context tech = w.prototype(L, techid);
        int time = pt_time(&tech);
        l.progress = time * 100;
        l.status = STATUS_DONE;
    }
    else {
        l.progress = 0;
        l.status = STATUS_IDLE;
    }
}

static void
laboratory_update(lua_State* L, world& w, ecs::entity& e, ecs::laboratory& l, ecs::consumer& co, ecs::capacitance& c, bool& updated) {
    prototype_context p = w.prototype(L, e.prototype);

    // step.1
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return;
    }
    c.shortage += drain;
    co.working = 1;
    if (l.tech == 0 || l.status == STATUS_INVALID) {
        return;
    }

    // step.2
    while (l.progress <= 0) {
        prototype_context tech = w.prototype(L, l.tech);
        recipe_container& container = w.query_container<recipe_container>(l.container);
        if (l.status == STATUS_DONE) {
            int count = pt_count(&tech);
            if (w.techtree.research_add(l.tech, count, 1)) {
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
            auto& r = w.techtree.get_ingredients(L, w, e.prototype, l.tech);
            if (!r || !container.recipe_pickup(w, to_recipe(r))) {
                return;
            }
            int time = pt_time(&tech);
            l.progress += time * 100;
            l.status = STATUS_DONE;
        }
    }

    // step.3
    if (c.shortage + power > capacitance) {
        return;
    }
    c.shortage += power;
    co.working = 2;

    // step.4
    l.progress -= l.speed;
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<ecs::laboratory, ecs::entity>(L)) {
        ecs::entity& e = v.get<ecs::entity>();
        ecs::laboratory& l = v.get<ecs::laboratory>();
        laboratory_set_tech(L, w, e, l, l.tech);
    }
    return 0;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    bool updated = false;
    for (auto& v : w.select<ecs::laboratory, ecs::consumer, ecs::capacitance, ecs::entity>(L)) {
        ecs::entity& e = v.get<ecs::entity>();
        ecs::laboratory& l = v.get<ecs::laboratory>();
        ecs::capacitance& c = v.get<ecs::capacitance>();
        ecs::consumer& co = v.get<ecs::consumer>();
        uint16_t techid = w.techtree.queue_top();
        if (techid != l.tech) {
            laboratory_next_tech(L, w, e, l, techid);
        }
        laboratory_update(L, w, e, l, co, c, updated);
    }
    if (updated) {
        uint16_t techid = w.techtree.queue_top();
        for (auto& v : w.select<ecs::laboratory, ecs::entity>(L)) {
            ecs::entity& e = v.get<ecs::entity>();
            ecs::laboratory& l = v.get<ecs::laboratory>();
            laboratory_next_tech(L, w, e, l, techid);
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
