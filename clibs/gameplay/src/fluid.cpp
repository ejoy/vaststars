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
	box->capacity *= multiple;
	box->height *= multiple;
	box->base_level *= multiple;
	box->pumping_speed *= multiple;
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

bool fluidflow::query(int id, state& state) {
	fluid_state output;
	if (!fluidflow_query(network, id, &output)) {
		return false;
	}
	state.volume = output.volume;
	state.flow = output.flow;
	state.multiple = multiple;
	return true;
}

void fluidflow::block(int id) {
	fluidflow_block(network, id);
}

void fluidflow::update() {
	fluidflow_update(network);
}

void fluidflow::change(int id, change_type type, int fluid) {
	int r;
	switch (type) {
	case change_type::Import:
		r = fluidflow_import(network, id, fluid, multiple);
		break;
	case change_type::Export:
		r = fluidflow_export(network, id, fluid, multiple);
		break;
	}
	assert(r != -1);
}

static int
lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& e : w.select<fluidboxes, assembling>()) {
		fluidboxes& fb = e.get<fluidboxes>();
		assembling& a = e.get<assembling>();
		recipe_container& container = w.query_container<recipe_container>(a.container);
		for (size_t i = 0; i < 4; ++i) {
			uint16_t fluid = fb.in[i].fluid;
			if (fluid != 0) {
				uint8_t index = ((a.fluidbox >> (i*4)) & 0xF) - 1;
				uint16_t value = 0;
				if (container.recipe_get(recipe_container::slot_type::in, index, value)) {
					w.fluidflows[fluid].change(fb.in[i].id, fluidflow::change_type::Import, value);
				}
			}
		}
		for (size_t i = 0; i < 3; ++i) {
			uint16_t fluid = fb.out[i].fluid;
			if (fluid != 0) {
				uint8_t index = ((a.fluidbox >> ((i+4)*4)) & 0xF) - 1;
				uint16_t value = 0;
				if (container.recipe_get(recipe_container::slot_type::out, index, value)) {
					w.fluidflows[fluid].change(fb.out[i].id, fluidflow::change_type::Export, value);
				}
			}
		}
	}
	for (auto& [_,f] : w.fluidflows) {
		f.update();
	}
	for (auto& e : w.select<fluidboxes, assembling>()) {
		fluidboxes& fb = e.get<fluidboxes>();
		assembling& a = e.get<assembling>();
		recipe_container& container = w.query_container<recipe_container>(a.container);
		for (size_t i = 0; i < 4; ++i) {
			uint16_t fluid = fb.in[i].fluid;
			if (fluid != 0) {
				uint8_t index = ((a.fluidbox >> (i*4)) & 0xF) - 1;
				fluidflow::state state;
				if (w.fluidflows[fluid].query(fb.in[i].id, state)) {
					container.recipe_set(recipe_container::slot_type::in, index, state.volume / state.multiple);
				}
			}
		}
		for (size_t i = 0; i < 3; ++i) {
			uint16_t fluid = fb.out[i].fluid;
			if (fluid != 0) {
				uint8_t index = ((a.fluidbox >> ((i+4)*4)) & 0xF) - 1;
				fluidflow::state state;
				if (w.fluidflows[fluid].query(fb.out[i].id, state)) {
					container.recipe_set(recipe_container::slot_type::out, index, state.volume / state.multiple);
				}
			}
		}
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
	int capacity = (int)luaL_checkinteger(L, 3);
	int height = (int)luaL_checkinteger(L, 4);
	int base_level = (int)luaL_checkinteger(L, 5);
	int pumping_speed = (int)luaL_optinteger(L, 6, 0);
	fluid_box box {
		.capacity = capacity,
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
		return luaL_error(L, "fluidflow connect failed.");
	}
	return 0;
}

static int
lfluidflow_query(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
	uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
	fluidflow::state state;
	if (!w.fluidflows[fluid].query(id, state)) {
		return luaL_error(L, "fluidflow query failed.");
	}
	lua_createtable(L, 0, 2);
	lua_pushinteger(L, state.volume);
	lua_setfield(L, -2, "volume");
	lua_pushinteger(L, state.flow);
	lua_setfield(L, -2, "flow");
	lua_pushinteger(L, state.multiple);
	lua_setfield(L, -2, "multiple");
	return 1;
}

static int
lfluidflow_change(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
	uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
	static const char *const CHANGETYPE[] = {"import", "export", NULL};
	fluidflow::change_type type = (fluidflow::change_type)luaL_checkoption(L, 4, "import", CHANGETYPE);
	int value = (int)luaL_checkinteger(L, 5);
	w.fluidflows[fluid].change(id, type, value);
	return 0;
}

static int
lfluidflow_dump(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
	w.fluidflows[fluid].dump();
	return 0;
}

extern "C" int
luaopen_vaststars_fluidflow_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "reset", lfluidflow_reset },
		{ "build", lfluidflow_build },
		{ "connect", lfluidflow_connect },
		{ "query", lfluidflow_query },
		{ "change", lfluidflow_change },
		{ "dump", lfluidflow_dump },
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
