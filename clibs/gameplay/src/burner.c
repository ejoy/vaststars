#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "world.h"
#include "entity.h"
#include "prototype.h"

static int
lupdate(lua_State *L) {
	struct world* w = (struct world *)lua_touserdata(L, 1);
	struct ecs_context *ctx = w->ecs;
	struct prototype_cache *cache = w->P;
	struct prototype_context p = { L, cache, 0 };
	int i;
	struct bunker *b;
	for (i=0;(b = entity_iter(ctx, COMPONENT_BUNKER, i));i++) {
		if (b->number > 0) {
			p.id = b->type;
			struct capacitance * c = entity_sibling(ctx, COMPONENT_BUNKER, i , COMPONENT_CAPACITANCE);
			if (c == NULL)
				luaL_error(L, "No capacitance");
			if (c->shortage > 0) {
				// need charge
				float need_energy = c->shortage;
				float energy = pt_fuel_energy(&p);
				float fuel_energy = energy * b->number; 
				if (need_energy >= fuel_energy) {
					c->shortage -= fuel_energy;
					b->number = 0;
				} else {
					b->number -= need_energy / energy;
					c->shortage = 0;
				}
			}
		}
	}
    return 0;
}

LUAMOD_API int
luaopen_vaststars_burner_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
