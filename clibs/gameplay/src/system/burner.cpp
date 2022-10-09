#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

static void
checkFinish(lua_State* L, world& w, ecs::burner& b) {
	if (b.progress == STATUS_DONE) {
		prototype_context recipe = w.prototype(L, b.recipe);
		chest& chest = w.query_chest(b.chest_out);
		recipe_items* r = (recipe_items*)pt_results(&recipe);
		if (chest.place(w, r)) {
			b.progress = STATUS_IDLE;
		}
	}
}

static int
lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& v: w.select<ecs::burner, ecs::entity, ecs::capacitance>(L)) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.shortage <= 0) {
			checkFinish(L, w, v.get<ecs::burner>());
			continue;
		}
		ecs::entity& e = v.get<ecs::entity>();
		prototype_context p = w.prototype(L, e.prototype);
		unsigned int power = pt_power(&p);
		if (c.shortage < power) {
			checkFinish(L, w, v.get<ecs::burner>());
			continue;
		}
		ecs::burner& b = v.get<ecs::burner>();
		if (b.progress == STATUS_DONE || b.progress == STATUS_IDLE) {
			prototype_context recipe = w.prototype(L, b.recipe);
			if (b.progress == STATUS_DONE) {
				chest& chest = w.query_chest(b.chest_out);
				recipe_items* items = (recipe_items*)pt_results(&recipe);
				if (chest.place(w, items)) {
					b.progress = STATUS_IDLE;
				}
			}
			if (b.progress == STATUS_IDLE) {
				chest& chest = w.query_chest(b.chest_in);
				recipe_items* items = (recipe_items*)pt_ingredients(&recipe);
				if (chest.pickup(w, items)) {
					int time = pt_time(&recipe);
					b.progress = time + STATUS_DONE;
				}
			}
		}
		if (b.progress == STATUS_DONE || b.progress == STATUS_IDLE) {
			continue;
		}

		c.shortage -= power;
		b.progress--;
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
