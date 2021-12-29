#include <lua.hpp>
#include "world.h"
#include "fluid.h"

extern "C" {
    #include "fluidflow.h"
}

fluidflow::fluidflow()
: network(fluidflow_new())
{}

fluidflow::~fluidflow() {
	fluidflow_delete(network);
}

uint16_t fluidflow::build(struct fluid_box *box) {
	if (maxid >= 0xFFFF) {
		return 0;
	}
	if (fluidflow_build(network, ++maxid, box)) {
		return 0;
	}
	return maxid;
}

int fluidflow::teardown(int id) {
	return fluidflow_teardown(network, id);
}

bool fluidflow::connect(int* IDs, size_t n) {
	return 0 == fluidflow_connect(network, (int)n / 2, IDs);
}

void fluidflow::dump() {
	fluidflow_dump(network);
}

fluid_state* fluidflow::query(int id, fluid_state* output) {
	return fluidflow_query(network, id, output);
}

void fluidflow::block(int id) {
	fluidflow_block(network, id);
}

void fluidflow::update() {
	fluidflow_update(network);
}

void fluidflow::change(int id, change_type type, float fluid) {
	float r;
	switch (type) {
	case change_type::Import:
		r = fluidflow_import(network, id, fluid);
		break;
	case change_type::Export:
		r = fluidflow_export(network, id, fluid);
		break;
	}
	assert(r == 0.f);
}

static int
lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& [_,f] : w.fluidflows) {
		f.update();
	}
	return 0;
}

static int
lfluidflow_reset(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	w.fluidflows.clear();
	return 0;
}

static int
lfluidflow_build(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
	float area = (float)luaL_checknumber(L, 3);
	float height = (float)luaL_checknumber(L, 4);
	float base_level = (float)luaL_checknumber(L, 5);
	float pumping_speed = (float)luaL_optnumber(L, 6, 0.0);
	fluid_box box {
		.area = area,
		.height = height,
		.base_level = base_level,
		.pumping_speed = pumping_speed,
	};
	uint16_t id = w.fluidflows[fluid].build(&box);
	if (id == 0) {
		return luaL_error(L, "fluidflow build failed.");
	}
	lua_pushinteger(L, id);
	return 1;
}

static int
lfluidflow_connect(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
	luaL_checktype(L, 3, LUA_TTABLE);
	lua_Integer n = luaL_len(L, 3);
	std::vector<int> connects(n);
	for (lua_Integer i = 1; i <= n; ++i) {
		lua_rawgeti(L, 3, i);
		uint16_t id = (uint16_t)luaL_checkinteger(L, -1);
		connects[i-1] = id;
		lua_pop(L, 1);
	}
	bool ok =  w.fluidflows[fluid].connect(connects.data(), connects.size());
	if (!ok) {
		luaL_error(L, "fluidflow connect failed.");
		return 0;
	}
	return 0;
}

extern "C" int
luaopen_vaststars_fluidflow_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "reset", lfluidflow_reset },
		{ "build", lfluidflow_build },
		{ "connect", lfluidflow_connect },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}

extern "C" int
luaopen_vaststars_fluid_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
