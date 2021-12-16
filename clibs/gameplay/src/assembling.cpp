#include <lua.hpp>

#include "luaecs.h"
#include "world.h"
#include "entity.h"
#include "select.h"
extern "C" {
#include "prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

static void
assembling_update(world& w, assembling& a, entity& e, capacitance& c) {
    prototype_context p = w.prototype(e.prototype);

    // step.1
    float power = pt_power(&p);
    float drain = pt_drain(&p);
    float capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return;
    }
    c.shortage += drain;

    // step.2
    if (a.process == STATUS_DONE || a.process == STATUS_IDLE) {
        prototype_context recipe = w.prototype(a.recipe);
        assembling_container& container = w.query_container<assembling_container>(a.container);
        if (a.process == STATUS_DONE) {
            container::item* items = (container::item*)pt_results(&recipe);
            if (container.place_batch(w, items)) {
                a.process = STATUS_IDLE;
            }
        }
        if (a.process == STATUS_IDLE) {
            container::item* items = (container::item*)pt_ingredients(&recipe);
            if (container.pickup_batch(w, items)) {
                int time = pt_time(&recipe);
                a.process = time + STATUS_DONE;
            }
        }
    }
    if (a.process == STATUS_DONE || a.process == STATUS_IDLE) {
        return;
    }

    // step.3
    if (c.shortage + power > capacitance) {
        return;
    }
    c.shortage += power;

    // step.4
    a.process--;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& e : w.select<assembling, entity, capacitance>()) {
        assembling_update(w, e.get<assembling>(), e.get<entity>(), e.get<capacitance>());
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
