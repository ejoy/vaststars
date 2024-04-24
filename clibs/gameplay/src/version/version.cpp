#include <lua.hpp>
#include <string_view>

static std::string_view GameVersion = {
    #include "GameVersion.h"
};

static std::string_view EngineVersion = {
    #include "EngineVersion.h"
};

extern "C" int
luaopen_vaststars_version_core(lua_State *L) {
    lua_createtable(L, 0, 2);
    lua_pushlstring(L, GameVersion.data(), GameVersion.size());
    lua_setfield(L, -2, "game");
    lua_pushlstring(L, EngineVersion.data(), EngineVersion.size());
    lua_setfield(L, -2, "engine");
    return 1;
}
