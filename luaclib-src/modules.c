#include "modules.h"
#include <lauxlib.h>

int luaopen_vaststars_road(lua_State* L);

static void loadmodules(lua_State* L) {
    static const luaL_Reg modules[] = {
        { "vaststars.road", luaopen_vaststars_road },
        { NULL, NULL },
    };

    const luaL_Reg *lib;
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    for (lib = modules; lib->func; lib++) {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 1);
}


void ant_openlibs(lua_State* L) {
    ant_loadmodules(L);
    loadmodules(L);
}
