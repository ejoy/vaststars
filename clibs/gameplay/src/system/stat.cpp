#include <lua.hpp>
#include "core/world.h"

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    w.stat.update(w.time);
    return 0;
}

extern "C" int
luaopen_vaststars_stat_system(lua_State *L) {
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
