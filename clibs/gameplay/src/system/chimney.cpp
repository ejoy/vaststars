#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"
extern "C" {
#include "core/fluidflow.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_WORKING 2

static bool fluidbox_pickup(world& w, component::fluidbox& f, recipe_items const& r) {
    if (r.n != 1 || r.items[0].item != f.fluid) {
        return false;
    }
    auto& ff = w.fluidflows[f.fluid];
    fluid_state state;
    if (!ff.query(f.id, state)) {
        return false;
    }
    int v = state.volume;
    if (v < r.items[0].amount * ff.multiple) {
        return false;
    }
    v -= r.items[0].amount * ff.multiple;
    ff.set(f.id, v, 1);
    return true;
}

static void
chimney_update(world& w, ecs::entity<component::chimney, component::fluidbox>& v) {
    component::chimney& c = v.get<component::chimney>();
    if (c.recipe == 0) {
        return;
    }

    while (c.progress <= 0) {
        if (c.status == STATUS_DONE) {
            //recipe_items* r = (recipe_items*)pt_results(&recipe);
            //if (false) {
            //    //TODO
            //    return;
            //}
            w.stat.finish_recipe(w, c.recipe);
            c.status = STATUS_IDLE;
        }
        if (c.status == STATUS_IDLE) {
            auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, c.recipe);
            component::fluidbox& f = v.get<component::fluidbox>();
            if (!fluidbox_pickup(w, f, ingredients)) {
                return;
            }
            auto time = prototype::get<"time">(w, c.recipe);
            c.progress += time * 100;
            c.status = STATUS_DONE;
        }
    }

    c.progress -= c.speed;
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (auto& v : ecs::select<component::chimney, component::fluidbox>(w.ecs)) {
        chimney_update(w, v);
    }
    return 0;
}

extern "C" int
luaopen_vaststars_chimney_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
