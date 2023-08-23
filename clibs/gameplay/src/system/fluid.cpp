#include <lua.hpp>
#include "core/world.h"
#include "system/fluid.h"

extern "C" {
    #include "core/fluidflow.h"
}

fluidflow::fluidflow()
: network(fluidflow_new())
{}

fluidflow::~fluidflow() {
	fluidflow_delete(network);
}

uint16_t fluidflow::build(struct fluid_box *box) {
	uint16_t newid = 0;
	if (freelist.empty()) {
		if (maxid >= 0xFFFF) {
			return 0;
		}
		newid = ++maxid;
	}
	else {
		newid = freelist.back();
		freelist.pop_back();
	}
	box->capacity *= multiple;
	box->height *= multiple;
	box->base_level *= multiple;
	box->pumping_speed *= multiple;
	if (fluidflow_build(network, newid, box)) {
		freelist.push_back(newid);
		return 0;
	}
	return newid;
}

bool fluidflow::restore(uint16_t id, struct fluid_box *box) {
	if (id <= maxid) {
		freelist.erase(std::remove_if(freelist.begin(), freelist.end(),
			[=](uint16_t x) {
				return x == id;
			}
		), freelist.end());
	}
	else {
		for (auto i = maxid + 1; i < id; ++i) {
			freelist.push_back(i);
		}
		maxid = id;
	}
	box->capacity *= multiple;
	box->height *= multiple;
	box->base_level *= multiple;
	box->pumping_speed *= multiple;
	if (fluidflow_build(network, id, box)) {
		freelist.push_back(id);
		return false;
	}
	return true;
}

bool fluidflow::teardown(int id) {
	if (0 == fluidflow_teardown(network, id)) {
		freelist.push_back(id);
		return true;
	}
	return false;
}

bool fluidflow::connect(int from, int to, bool oneway) {
	return 0 == fluidflow_connect(network, from, to, oneway? 1: 0);
}

void fluidflow::dump() {
	fluidflow_dump(network);
}

bool fluidflow::query(int id, fluid_state& state) {
	if (!fluidflow_query(network, id, &state)) {
		return false;
	}
	return true;
}

void fluidflow::block(int id) {
	fluidflow_block(network, id);
}

void fluidflow::update() {
	fluidflow_update(network);
}

void fluidflow::set(int id, int fluid) {
	int r = fluidflow_set(network, id, fluid, multiple);
	assert(r != -1);
}

void fluidflow::set(int id, int fluid, int user_multiple) {
	int r = fluidflow_set(network, id, fluid, user_multiple);
	assert(r != -1);
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
	for (auto& [_,f] : w.fluidflows) {
		f.update();
	}
	for (auto& e : ecs_api::select<ecs::fluidboxes, ecs::assembling, ecs::chest>(w.ecs)) {
		ecs::assembling& a = e.get<ecs::assembling>();
		ecs::chest& c2 = e.get<ecs::chest>();
		if (a.recipe != 0) {
			ecs::fluidboxes& fb = e.get<ecs::fluidboxes>();
			if (a.fluidbox_in != 0) {
				for (size_t i = 0; i < 4; ++i) {
					uint16_t fluid = fb.in[i].fluid;
					if (fluid != 0) {
						auto& f = w.fluidflows[fluid];
						uint8_t index = ((a.fluidbox_in >> (i*4)) & 0xF) - 1;
						fluid_state state;
						if (f.query(fb.in[i].id, state)) {
							chest::set_fluid(w, container::index::from(c2.chest), index, state.volume / f.multiple);
						}
					}
				}
			}
			if (a.fluidbox_out != 0) {
				for (size_t i = 0; i < 3; ++i) {
					uint16_t fluid = fb.out[i].fluid;
					if (fluid != 0) {
						auto& f = w.fluidflows[fluid];
						uint8_t index = ((a.fluidbox_out >> (i*4)) & 0xF) - 1;
						fluid_state state;
						if (f.query(fb.out[i].id, state)) {
							chest::set_fluid(w, container::index::from(c2.chest), index, state.volume / f.multiple);
						}
					}
				}
			}
		}
	}
	return 0;
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
