#include <lua.hpp>

#include "EmbedVersion.h"

extern "C" int
luaopen_vaststars_version_core(lua_State *L) {
    lua_createtable(L, 0, 2);
    lua_pushlstring(L, gGameGitVersion, sizeof(gGameGitVersion)-1);
    lua_setfield(L, -2, "game");
    lua_pushlstring(L, gEngineGitVersion, sizeof(gEngineGitVersion)-1);
    lua_setfield(L, -2, "engine");
    return 1;
}
