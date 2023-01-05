#include <lua.hpp>

#include "EmbedVersion.h"

extern "C" int
luaopen_vaststars_version_core(lua_State *L) {
    if (LUA_OK != luaL_loadbuffer(L, gEmbedVersionData, sizeof(gEmbedVersionData), "=(version)")) {
        return lua_error(L);
    }
    lua_call(L, 0, 1);
    return 1;
}
