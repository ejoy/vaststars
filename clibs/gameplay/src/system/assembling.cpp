#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static void
sync_input_fluidbox(world& w, ecs::assembling& a, ecs::fluidboxes& fb, recipe_container& container) {
	for (size_t i = 0; i < 4; ++i) {
		uint16_t fluid = fb.in[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((a.fluidbox_in >> (i*4)) & 0xF) - 1;
			uint16_t value = 0;
			if (container.recipe_get(recipe_container::slot_type::in, index, value)) {
				w.fluidflows[fluid].set(fb.in[i].id, value);
			}
		}
	}
}

static void
sync_output_fluidbox(world& w, ecs::assembling& a, ecs::fluidboxes& fb, recipe_container& container) {
	for (size_t i = 0; i < 3; ++i) {
		uint16_t fluid = fb.out[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((a.fluidbox_out >> (i*4)) & 0xF) - 1;
			uint16_t value = 0;
			if (container.recipe_get(recipe_container::slot_type::out, index, value)) {
				w.fluidflows[fluid].set(fb.out[i].id, value);
			}
		}
	}
}

static void
assembling_update(lua_State* L, world& w, ecs_api::entity<ecs::assembling, ecs::entity, ecs::consumer, ecs::capacitance>& v) {
    ecs::assembling& a = v.get<ecs::assembling>();
    ecs::entity& e = v.get<ecs::entity>();
    ecs::capacitance& c = v.get<ecs::capacitance>();
    ecs::consumer& co = v.get<ecs::consumer>();
    prototype_context p = w.prototype(L, e.prototype);

    // step.1
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return;
    }
    c.shortage += drain;

    if (a.recipe == 0) {
        return;
    }

    // step.2
    while (a.progress <= 0) {
        co.low_power = 0;
        prototype_context recipe = w.prototype(L, a.recipe);
        recipe_container& container = w.query_container<recipe_container>(a.container);
        if (a.status == STATUS_DONE) {
            recipe_items* r = (recipe_items*)pt_results(&recipe);
            if (!container.recipe_place(w, r)) {
                return;
            }
            w.stat.finish_recipe(L, w, a.recipe, false);
            a.status = STATUS_IDLE;
            if (a.fluidbox_out != 0) {
                ecs::fluidboxes* fb = w.sibling<ecs::fluidboxes>(v);
                if (fb) {
                    sync_output_fluidbox(w, a, *fb, container);
                }
            }
        }
        if (a.status == STATUS_IDLE) {
            recipe_items* r = (recipe_items*)pt_ingredients(&recipe);
            if (!container.recipe_pickup(w, r)) {
                return;
            }
            int time = pt_time(&recipe);
            a.progress += time * 100;
            a.status = STATUS_DONE;
            if (a.fluidbox_in != 0) {
                ecs::fluidboxes* fb = w.sibling<ecs::fluidboxes>(v);
                if (fb) {
                    sync_input_fluidbox(w, a, *fb, container);
                }
            }
        }
    }

    // step.3
    if (c.shortage + power > capacitance) {
        co.low_power = 50;
        return;
    }
    c.shortage += power;

    // step.4
    a.progress -= a.speed;
    if (co.low_power > 0) co.low_power--;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<ecs::assembling, ecs::entity, ecs::consumer, ecs::capacitance>(L)) {
        assembling_update(L, w, v);
    }
    return 0;
}

extern "C" int
luaopen_vaststars_assembling_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
