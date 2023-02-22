#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
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
    for (auto& v : ecs_api::select<ecs::pump, ecs::building, ecs::capacitance, ecs::fluidbox>(w.ecs)) {
        auto consumer = get_consumer(L, w, v);
        if (!consumer.cost_drain() || !consumer.cost_power()) {
            block(w, v.get<ecs::fluidbox>());
            continue;
        }
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
