#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "roadnet/network.h"

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    w.rw.update(w.time);
    return 0;
}

extern "C" int
luaopen_vaststars_roadnet_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
