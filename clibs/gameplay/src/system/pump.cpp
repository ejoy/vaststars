#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

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
assembling_update(lua_State* L, world& w, ecs::select::entity<ecs::assembling, ecs::entity, ecs::capacitance>& v) {
    ecs::assembling& a = v.get<ecs::assembling>();
    ecs::entity& e = v.get<ecs::entity>();
    ecs::capacitance& c = v.get<ecs::capacitance>();
    prototype_context p = w.prototype(L, e.prototype);

    // step.1
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return;
    }
    c.shortage += drain;

    // step.2
    if (a.progress == STATUS_DONE || a.progress == STATUS_IDLE) {
        prototype_context recipe = w.prototype(L, a.recipe);
        recipe_container& container = w.query_container<recipe_container>(a.container);
        if (a.progress == STATUS_DONE) {
            recipe_items* r = (recipe_items*)pt_results(&recipe);
            if (container.recipe_place(w, r)) {
                a.progress = STATUS_IDLE;
                if (a.fluidbox_out != 0) {
                    ecs::fluidboxes* fb = w.sibling<ecs::fluidboxes>(v);
                    if (fb) {
                        sync_output_fluidbox(w, a, *fb, container);
                    }
                }
            }
        }
        if (a.progress == STATUS_IDLE) {
            recipe_items* r = (recipe_items*)pt_ingredients(&recipe);
            if (container.recipe_pickup(w, r)) {
                int time = pt_time(&recipe);
                a.progress = time + STATUS_DONE;
                if (a.fluidbox_in != 0) {
                    ecs::fluidboxes* fb = w.sibling<ecs::fluidboxes>(v);
                    if (fb) {
                        sync_input_fluidbox(w, a, *fb, container);
                    }
                }
            }
        }
    }
    if (a.progress == STATUS_DONE || a.progress == STATUS_IDLE) {
        return;
    }

    // step.3
    if (c.shortage + power > capacitance) {
        return;
    }
    c.shortage += power;

    // step.4
    a.progress--;
}

static void
block(world& w, ecs::fluidbox const& fb) {
    w.fluidflows[fb.fluid].block(fb.id);
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<ecs::pump, ecs::entity, ecs::capacitance, ecs::fluidbox>(L)) {
        ecs::entity& e = v.get<ecs::entity>();
        ecs::capacitance& c = v.get<ecs::capacitance>();
        prototype_context p = w.prototype(L, e.prototype);

        unsigned int power = pt_power(&p);
        unsigned int drain = pt_drain(&p);
        unsigned int capacitance = power * 2;
        if (c.shortage + drain > capacitance) {
            block(w, v.get<ecs::fluidbox>());
            continue;
        }
        c.shortage += drain;

        if (c.shortage + power > capacitance) {
            block(w, v.get<ecs::fluidbox>());
            continue;
        }
        c.shortage += power;
    }
    return 0;
}

extern "C" int
luaopen_vaststars_pump_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
