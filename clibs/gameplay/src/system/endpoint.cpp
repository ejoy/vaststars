#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : ecs_api::select<ecs::chest>(w.ecs)) {
        auto& c = v.get<ecs::chest>();
        if (!roadnet::endpointid{ c.endpoint }) {
            continue;
        }
        auto& ep = w.rw.Endpoint(c.endpoint);
        auto l = ep.lorry[roadnet::endpoint::EPIN];
        if (l) {
            auto& lorry = w.rw.Lorry(l);
            if (roadnet::lorryid(c.lorry) && lorry.ready()) {
                c.lorry = l.id;
                ep.lorry[roadnet::endpoint::EPIN] = roadnet::lorryid::invalid();
            }
        }
    }
    for (auto& v : ecs_api::select<ecs::station>(w.ecs)) {
        auto& c = v.get<ecs::station>();
        if (!roadnet::endpointid{ c.endpoint }) {
            continue;
        }
        auto& ep = w.rw.Endpoint(c.endpoint);
        auto l = ep.lorry[roadnet::endpoint::EPIN];
        if (l) {
            auto& lorry = w.rw.Lorry(l);
            if (roadnet::lorryid(c.lorry) && lorry.ready()) {
                c.lorry = l.id;
                ep.lorry[roadnet::endpoint::EPIN] = roadnet::lorryid::invalid();
            }
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_endpoint_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
