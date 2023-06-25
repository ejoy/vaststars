#include <lua.hpp>
#include "roadnet/type.h"
#include "roadnet/network.h"
#include "core/world.h"

namespace roadnet::lua {
    static world& get_world(lua_State* L, int idx = 1) {
        return *(world*)lua_touserdata(L, idx);
    }

    static loction get_loction(lua_State* L, int idx) {
        auto v = luaL_checkinteger(L, idx);
        uint8_t x = (uint8_t)((v >>  0) & 0xFF);
        uint8_t y = (uint8_t)((v >>  8) & 0xFF);
        return {x,y};
    }

    static int reset(lua_State* L) {
        auto& w = get_world(L);
        w.rw.rebuildMap(w);
        return 0;
    }
}

extern "C" int
luaopen_vaststars_roadnet_core(lua_State* L) {
    luaL_Reg lib[] = {
        { "reset", roadnet::lua::reset },
        { NULL, NULL },
    };
    luaL_newlib(L, lib);
    return 1;
}
