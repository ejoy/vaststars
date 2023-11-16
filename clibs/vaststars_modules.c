#define linit_c
#define LUA_LIB

#include <stddef.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "modules.h"

static const luaL_Reg loadedlibs[] = {
    {LUA_GNAME, luaopen_base},
    {LUA_LOADLIBNAME, luaopen_package},
    {LUA_COLIBNAME, luaopen_coroutine},
    {LUA_TABLIBNAME, luaopen_table},
    {LUA_IOLIBNAME, luaopen_io},
    {LUA_OSLIBNAME, luaopen_os},
    {LUA_STRLIBNAME, luaopen_string},
    {LUA_MATHLIBNAME, luaopen_math},
    {LUA_UTF8LIBNAME, luaopen_utf8},
    {LUA_DBLIBNAME, luaopen_debug},
    {NULL, NULL}
};


#define MODULE(CATALOG, NAME) \
    int luaopen_vaststars_##NAME##_##CATALOG(lua_State* L); \
    lua_pushcfunction(L, luaopen_vaststars_##NAME##_##CATALOG); \
    lua_setfield(L, -2, "vaststars."#NAME"."#CATALOG);

#define SYSTEM(NAME) MODULE(system, NAME)
#define CORE(NAME)   MODULE(core, NAME)

static void loadmodules(lua_State* L) {
    SYSTEM(assembling)
    SYSTEM(laboratory)
    SYSTEM(chimney)
    SYSTEM(generator)
    SYSTEM(powergrid)
    SYSTEM(pump)
    SYSTEM(fluid)
    SYSTEM(task)
    SYSTEM(roadnet)
    SYSTEM(station)
    SYSTEM(drone)
    SYSTEM(stat)
    SYSTEM(building)
    CORE(chest)
    CORE(world)
    CORE(version)
    CORE(fluidflow)
}

LUALIB_API void luaL_openlibs (lua_State *L) {
    const luaL_Reg *lib;
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }
    ant_loadmodules(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    loadmodules(L);
    lua_pop(L, 1);
}
