#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "roadnet/network.h"

constexpr uint64_t kDirtyRoadnet = 1 << 4;

static int
lbuild(lua_State *L) {
	auto& w = getworld(L);
	if (w.dirty & kDirtyRoadnet) {
		w.rw.build(w);
	}
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
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
