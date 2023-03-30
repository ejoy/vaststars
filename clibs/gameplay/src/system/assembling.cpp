#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static void
sync_input_fluidbox(world& w, ecs::chest& c2, ecs::fluidboxes& fb) {
	for (size_t i = 0; i < 4; ++i) {
		uint16_t fluid = fb.in[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((c2.fluidbox_in >> (i*4)) & 0xF) - 1;
			uint16_t value = chest::get_fluid(w, container::index::from(c2.chest), index);
			w.fluidflows[fluid].set(fb.in[i].id, value);
		}
	}
}

static void
sync_output_fluidbox(world& w, ecs::chest& c2, ecs::fluidboxes& fb) {
	for (size_t i = 0; i < 3; ++i) {
		uint16_t fluid = fb.out[i].fluid;
		if (fluid != 0) {
			uint8_t index = ((c2.fluidbox_out >> (i*4)) & 0xF) - 1;
			uint16_t value = chest::get_fluid(w, container::index::from(c2.chest), index);
			w.fluidflows[fluid].set(fb.out[i].id, value);
		}
	}
}

static void
assembling_update(world& w, ecs_api::entity<ecs::assembling, ecs::chest, ecs::capacitance, ecs::building>& v) {
    ecs::assembling& a = v.get<ecs::assembling>();
    ecs::chest& c2 = v.get<ecs::chest>();
    auto consumer = get_consumer(w, v);

    // step.1
    if (!consumer.cost_drain()) {
        return;
    }

    if (a.recipe == 0) {
        return;
    }

    // step.2
    while (a.progress <= 0) {
        if (a.status == STATUS_DONE) {
            if (!chest::place(w, container::index::from(c2.chest), a.recipe)) {
                return;
            }
            w.stat.finish_recipe(w, a.recipe);
            a.status = STATUS_IDLE;
            if (c2.fluidbox_out != 0) {
                ecs::fluidboxes* fb = v.sibling<ecs::fluidboxes>();
                if (fb) {
                    sync_output_fluidbox(w, c2, *fb);
                }
            }
        }
        if (a.status == STATUS_IDLE) {
            if (!chest::pickup(w, container::index::from(c2.chest), a.recipe)) {
                return;
            }
            auto time = prototype::get<"time">(w, a.recipe);
            a.progress += time * 100;
            a.status = STATUS_DONE;
            if (c2.fluidbox_in != 0) {
                ecs::fluidboxes* fb = v.sibling<ecs::fluidboxes>();
                if (fb) {
                    sync_input_fluidbox(w, c2, *fb);
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
    auto& w = getworld(L);
    for (auto& v : ecs_api::select<ecs::assembling, ecs::chest, ecs::capacitance, ecs::building>(w.ecs)) {
        assembling_update(w, v);
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
