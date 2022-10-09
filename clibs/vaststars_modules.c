#include "modules.h"
#include <lauxlib.h>

#define MODULE(CATALOG, NAME) \
    int luaopen_vaststars_##NAME##_##CATALOG(lua_State* L); \
    lua_pushcfunction(L, luaopen_vaststars_##NAME##_##CATALOG); \
    lua_setfield(L, -2, "vaststars."#NAME"."#CATALOG);

#define SYSTEM(NAME) MODULE(system, NAME)
#define CORE(NAME)   MODULE(core, NAME)

static void loadmodules(lua_State* L) {
    SYSTEM(assembling)
    SYSTEM(laboratory)
    SYSTEM(burner)
    SYSTEM(chimney)
    SYSTEM(generator)
    SYSTEM(powergrid)
    SYSTEM(pump)
    SYSTEM(fluid)
    SYSTEM(task)
    SYSTEM(manual)
    SYSTEM(trading)
    CORE(prototype)
    CORE(container)
    CORE(roadnet)
    CORE(roadmap)
    CORE(world)
}

void ant_openlibs(lua_State* L) {
    ant_loadmodules(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    loadmodules(L);
    lua_pop(L, 1);
}
