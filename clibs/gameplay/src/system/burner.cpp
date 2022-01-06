#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "world.h"
#include "entity.h"
extern "C" {
#include "prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

static void
checkFinish(world& w, burner& b) {
	if (b.process == STATUS_DONE) {
		prototype_context recipe = w.prototype(b.recipe);
		recipe_container& container = w.query_container<recipe_container>(b.container);
		container::item* items = (container::item*)pt_results(&recipe);
		if (container.recipe_place(w, items)) {
			b.process = STATUS_IDLE;
		}
	}
}

static int
lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& v: w.select<burner, entity, capacitance>()) {
		capacitance& c = v.get<capacitance>();
		if (c.shortage <= 0) {
			checkFinish(w, v.get<burner>());
			continue;
		}
		entity& e = v.get<entity>();
		prototype_context p = w.prototype(e.prototype);
		float power = pt_power(&p);
		if (c.shortage < power) {
			checkFinish(w, v.get<burner>());
			continue;
		}
		burner& b = v.get<burner>();
		if (b.process == STATUS_DONE || b.process == STATUS_IDLE) {
			prototype_context recipe = w.prototype(b.recipe);
			recipe_container& container = w.query_container<recipe_container>(b.container);
			if (b.process == STATUS_DONE) {
				container::item* items = (container::item*)pt_results(&recipe);
				if (container.recipe_place(w, items)) {
					b.process = STATUS_IDLE;
				}
			}
			if (b.process == STATUS_IDLE) {
				container::item* items = (container::item*)pt_ingredients(&recipe);
				if (container.recipe_pickup(w, items)) {
					int time = pt_time(&recipe);
					b.process = time + STATUS_DONE;
				}
			}
		}
		if (b.process == STATUS_DONE || b.process == STATUS_IDLE) {
			continue;
		}

		c.shortage -= power;
		b.process--;
	}
	return 0;
}

extern "C" int
luaopen_vaststars_burner_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
