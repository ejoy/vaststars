#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static void
sync_input_fluidbox(world& w, ecs::assembling& a, ecs::fluidboxes& fb, chest& chest) {
	for (size_t i = 0; i < 4; ++i) {
		uint16_t fluid = fb.in[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((a.fluidbox_in >> (i*4)) & 0xF) - 1;
			uint16_t value = chest.get_fluid(index);
			w.fluidflows[fluid].set(fb.in[i].id, value);
		}
	}
}

static void
sync_output_fluidbox(world& w, ecs::assembling& a, ecs::fluidboxes& fb, chest& chest) {
	for (size_t i = 0; i < 3; ++i) {
		uint16_t fluid = fb.out[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((a.fluidbox_out >> (i*4)) & 0xF) - 1;
			uint16_t value = chest.get_fluid(index);
			w.fluidflows[fluid].set(fb.out[i].id, value);
		}
	}
}

static void
assembling_update(lua_State* L, world& w, ecs_api::entity<ecs::assembling, ecs::capacitance, ecs::entity>& v) {
    ecs::assembling& a = v.get<ecs::assembling>();
    auto consumer = get_consumer(L, w, v);

    // step.1
    if (!consumer.cost_drain()) {
        return;
    }

    if (a.recipe == 0) {
        return;
    }

    // step.2
    while (a.progress <= 0) {
        prototype_context recipe = w.prototype(L, a.recipe);
        if (a.status == STATUS_DONE) {
            chest& chest = w.query_chest(a.chest_out);
            recipe_items* r = (recipe_items*)pt_results(&recipe);
            if (!chest.place(w, r)) {
                return;
            }
            w.stat.finish_recipe(L, w, a.recipe, false);
            a.status = STATUS_IDLE;
            if (a.fluidbox_out != 0) {
                ecs::fluidboxes* fb = v.sibling<ecs::fluidboxes>(w);
                if (fb) {
                    sync_output_fluidbox(w, a, *fb, chest);
                }
            }
        }
        if (a.status == STATUS_IDLE) {
            chest& chest = w.query_chest(a.chest_in);
            recipe_items* r = (recipe_items*)pt_ingredients(&recipe);
            if (!chest.pickup(w, r)) {
                return;
            }
            int time = pt_time(&recipe);
            a.progress += time * 100;
            a.status = STATUS_DONE;
            if (a.fluidbox_in != 0) {
                ecs::fluidboxes* fb = v.sibling<ecs::fluidboxes>(w);
                if (fb) {
                    sync_input_fluidbox(w, a, *fb, chest);
                }
            }
        }
    }

    // step.3
    if (!consumer.cost_power()) {
        return;
    }

    // step.4
    a.progress -= a.speed;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<ecs::assembling, ecs::capacitance, ecs::entity>(L)) {
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
