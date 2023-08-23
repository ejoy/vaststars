#include <lua.hpp>
#include <binding/binding.h>
#include "core/world.h"
extern "C" {
    #include "core/fluidflow.h"
}

static int fluidflow_build(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    int capacity = bee::lua::checkinteger<int>(L, 3);
    int height = bee::lua::checkinteger<int>(L, 4);
    int base_level = bee::lua::checkinteger<int>(L, 5);
    int pumping_speed = bee::lua::optinteger<int, 0>(L, 6);
    fluid_box box {
        .capacity = capacity,
        .height = height,
        .base_level = base_level,
        .pumping_speed = pumping_speed,
    };
    auto& flow = w.fluidflows[fluid];
    uint16_t id = flow.create_id();
    if (!flow.build(id, &box)) {
        flow.remove_id(id);
        return luaL_error(L, "fluidflow build failed.");
    }
    lua_pushinteger(L, id);
    return 1;
}

static int fluidflow_teardown(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    uint16_t id = bee::lua::checkinteger<uint16_t>(L, 3);
    bool ok = w.fluidflows[fluid].teardown(id);
    if (!ok) {
        return luaL_error(L, "fluidflow teardown failed.");
    }
    return 0;
}

static int fluidflow_connect(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    fluidflow& flow = w.fluidflows[fluid];
    luaL_checktype(L, 3, LUA_TTABLE);
    lua_Integer n = luaL_len(L, 3);
    for (lua_Integer i = 1; i+2 <= n; i += 3) {
        lua_rawgeti(L, 3, i);
        lua_rawgeti(L, 3, i+1);
        lua_rawgeti(L, 3, i+2);
        uint16_t from = bee::lua::checkinteger<uint16_t>(L, -3);
        uint16_t to = bee::lua::checkinteger<uint16_t>(L, -2);
        bool oneway = !!lua_toboolean(L, -1);
        bool ok =  flow.connect(from, to, oneway);
        if (!ok) {
            return luaL_error(L, "fluidflow connect failed.");
        }
        lua_pop(L, 3);
    }
    return 0;
}

static int fluidflow_query(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    auto& f = w.fluidflows[fluid];
    uint16_t id = bee::lua::checkinteger<uint16_t>(L, 3);
    fluid_state state;
    if (!f.query(id, state)) {
        return luaL_error(L, "fluidflow query failed.");
    }
    lua_createtable(L, 0, 8);
    lua_pushinteger(L, f.multiple);
    lua_setfield(L, -2, "multiple");
    lua_pushinteger(L, state.volume);
    lua_setfield(L, -2, "volume");
    lua_pushinteger(L, state.flow);
    lua_setfield(L, -2, "flow");
    lua_pushboolean(L, state.blocking);
    lua_setfield(L, -2, "blocking");
    lua_pushinteger(L, state.box.capacity);
    lua_setfield(L, -2, "capacity");
    lua_pushinteger(L, state.box.height);
    lua_setfield(L, -2, "height");
    lua_pushinteger(L, state.box.base_level);
    lua_setfield(L, -2, "base_level");
    lua_pushinteger(L, state.box.pumping_speed);
    lua_setfield(L, -2, "pumping_speed");
    return 1;
}

static int fluidflow_set(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    auto& f = w.fluidflows[fluid];
    uint16_t id = bee::lua::checkinteger<uint16_t>(L, 3);
    int value = bee::lua::checkinteger<int>(L, 4);
    int multiple = bee::lua::optinteger<int, fluidflow::multiple>(L, 5);
    f.set(id, value, multiple);
    return 0;
}

extern "C" int
luaopen_vaststars_fluidflow_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "build", fluidflow_build },
        { "teardown", fluidflow_teardown },
        { "connect", fluidflow_connect },
        { "query", fluidflow_query },
        { "set", fluidflow_set },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
