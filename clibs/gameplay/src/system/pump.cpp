#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
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
