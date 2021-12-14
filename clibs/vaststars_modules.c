#include "modules.h"
#include <lauxlib.h>

int luaopen_vaststars_assembling_system(lua_State* L);
int luaopen_vaststars_burner_system(lua_State* L);
int luaopen_vaststars_inserter_system(lua_State* L);
int luaopen_vaststars_powergrid_system(lua_State* L);
int luaopen_vaststars_container_core(lua_State* L);
int luaopen_vaststars_prototype_core(lua_State* L);
int luaopen_vaststars_core(lua_State* L);

static void loadmodules(lua_State* L) {
    static const luaL_Reg modules[] = {
        { "vaststars.assembling.system", luaopen_vaststars_assembling_system },
        { "vaststars.burner.system", luaopen_vaststars_burner_system },
        { "vaststars.inserter.system", luaopen_vaststars_inserter_system },
        { "vaststars.powergrid.system", luaopen_vaststars_powergrid_system },
        { "vaststars.container.core", luaopen_vaststars_container_core },
        { "vaststars.prototype.core", luaopen_vaststars_prototype_core },
        { "vaststars.core", luaopen_vaststars_core },
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
