#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "roadnet/network.h"

static int
lrestore_finish(lua_State *L) {
    auto& w = getworld(L);
    w.rw.init(w);
    return 0;
}

static int
lbuild(lua_State *L) {
	auto& w = getworld(L);
	if (!(w.dirty & kDirtyRoadnet)) {
		return 0;
	}
	w.rw.build(w);
	return 0;
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    w.rw.update(w, w.time);
    return 0;
}


extern "C" int
luaopen_vaststars_roadnet_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "restore_finish", lrestore_finish },
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
