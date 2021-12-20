#include "modules.h"
#include <lauxlib.h>

#define MODULE(CATALOG, NAME) \
    int luaopen_vaststars_##NAME##_##CATALOG##(lua_State* L); \
    lua_pushcfunction(L, luaopen_vaststars_##NAME##_##CATALOG); \
    lua_setfield(L, -2, "vaststars."#NAME"."#CATALOG);

#define SYSTEM(NAME) MODULE(system, NAME)
#define CORE(NAME)   MODULE(core, NAME)

static void loadmodules(lua_State* L) {
    SYSTEM(assembling)
    SYSTEM(burner)
    SYSTEM(inserter)
    SYSTEM(powergrid)
    CORE(prototype)
    CORE(container)
    CORE(world)
    //CORE(road)
}

void ant_openlibs(lua_State* L) {
    ant_loadmodules(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    loadmodules(L);
    lua_pop(L, 1);
}
