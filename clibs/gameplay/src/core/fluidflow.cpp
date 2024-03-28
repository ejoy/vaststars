#include <lua.hpp>
#include <bee/lua/binding.h>
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
        .capacity = capacity * fluidflow::multiple,
        .height = height * fluidflow::multiple,
        .base_level = base_level * fluidflow::multiple,
        .pumping_speed = pumping_speed * fluidflow::multiple,
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
    fluidflow& flow = w.fluidflows[fluid];
    bool ok = flow.teardown(id);
    if (!ok) {
        return luaL_error(L, "fluidflow teardown failed.");
    }
    if (flow.size() == 0) {
        w.fluidflows.erase(fluid);
    }
    return 0;
}

static int fluidflow_connect(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    fluidflow& flow = w.fluidflows[fluid];
    flow.resetconnect();
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

struct fnetwork {
	uint16_t fluid;
	uint16_t n;
	uint16_t id[1];
};

static int fluidflow_marknet(lua_State *L) {
    auto& w = getworld(L);
    uint16_t fluid = bee::lua::checkinteger<uint16_t>(L, 2);
    auto& f = w.fluidflows[fluid];
    uint16_t id = bee::lua::checkinteger<uint16_t>(L, 3);
	int output[0x10000];
	int n = fluidflow_query_net(f.network, id, output, sizeof(output)/sizeof(output[0]));
	if (n == 0)
		return luaL_error(L, "Invalid pipe id");
	struct fnetwork * net = (struct fnetwork *)lua_newuserdatauv(L, sizeof(struct fnetwork) + (n - 1) * sizeof(uint16_t), 0);
	net->fluid = fluid;
	net->n = n;
	int i;
	for (i=0;i<n;i++) {
		net->id[i] = (uint16_t)output[i];
	}
	return 1;
}

static int fluidflow_querynet(lua_State *L) {
	auto& w = getworld(L);
	struct fnetwork *net = (struct fnetwork *)lua_touserdata(L, 2);
	if (net == NULL)
		return luaL_error(L, "Invalid pipe network");
	auto& f = w.fluidflows[net->fluid];
	int i;
	uint64_t v = 0;
	for (i=0;i<net->n;i++) {
		fluid_state state;
		if (!f.query(net->id[i], state)) {
			return luaL_error(L, "fluidflow querynet failed.");
		}
		v += state.volume;
	}
	lua_pushinteger(L, v);
	lua_pushinteger(L, f.multiple);
	return 2;
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
        { "mark", fluidflow_marknet },
        { "querynet", fluidflow_querynet },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
