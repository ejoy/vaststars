#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"

static int
lupdate(lua_State *L) {
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
