#include <lua.hpp>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include "world.h"
#include "container.h"

#define CONTAINER_TYPE(id)  ((id) & 0x8000)
#define CONTAINER_INDEX(id) ((id) & 0x3FFF)
#define CONTAINER_TYPE_CHEST  0x0000
#define CONTAINER_TYPE_RECIPE 0x8000

template <>
container& world::query_container<container>(uint16_t id) {
    uint16_t idx = CONTAINER_INDEX(id);
    if (CONTAINER_TYPE(id) == CONTAINER_TYPE_CHEST) {
        assert(containers.chest.size() > idx);
        return containers.chest[idx];
    }
    assert(containers.recipe.size() > idx);
    return containers.recipe[idx];
}

template <>
recipe_container& world::query_container<recipe_container>(uint16_t id) {
    uint16_t idx = CONTAINER_INDEX(id);
    assert(CONTAINER_TYPE(id) != CONTAINER_TYPE_CHEST);
    assert(containers.recipe.size() > idx);
    return containers.recipe[idx];
}

template <>
uint16_t world::container_id<chest_container>() {
    return CONTAINER_TYPE_CHEST | (uint16_t)(containers.chest.size()-1);
}

template <>
uint16_t world::container_id<recipe_container>() {
    return CONTAINER_TYPE_RECIPE | (uint16_t)(containers.recipe.size()-1);
}

namespace lua_world {
    static int
    is_researched(lua_State* L) {
        struct world* w = (struct world*)lua_touserdata(L, 1);
        uint16_t techid = (uint16_t)luaL_checkinteger(L, 2);
        lua_pushboolean(L, w->techtree.is_researched(techid));
        return 1;
    }
    
    static int
    research_queue(lua_State* L) {
        struct world* w = (struct world*)lua_touserdata(L, 1);
        if (lua_gettop(L) == 1) {
            auto& q = w->techtree.queue_get();
            size_t N = q.size();
            lua_createtable(L, (int)N, 0);
            for (size_t i = 0; i < N; ++i) {
                lua_pushinteger(L, q[i]);
                lua_rawseti(L, -2, i);
            }
            return 1;
        }
        luaL_checktype(L, 2, LUA_TTABLE);
        std::vector<uint16_t> q;
        for (lua_Integer i = 1;; ++i) {
            if (lua_rawgeti(L, 2, i) == LUA_TNIL) {
                break;
            }
            q.push_back((uint16_t)luaL_checkinteger(L, -1));
        }
        w->techtree.queue_set(q);
        return 0;
    }

    static int
    research_progress(lua_State* L) {
        struct world* w = (struct world*)lua_touserdata(L, 1);
        uint16_t techid = (uint16_t)luaL_checkinteger(L, 2);
        uint16_t progress = w->techtree.get_progress(techid);
        if (progress == 0) {
            return 0;
        }
        lua_pushinteger(L, progress);
        return 1;
    }

    static int
    reset(lua_State* L) {
        struct world* w = (struct world*)lua_touserdata(L, 1);
        w->fluidflows.clear();
        w->containers.chest.clear();
        w->containers.recipe.clear();
        return 0;
    }

    static int
    destroy(lua_State* L) {
        struct world* w = (struct world*)lua_touserdata(L, 1);
        w->~world();
        return 0;
    }
    
    static int
    create(lua_State* L) {
        struct world* w = (struct world*)lua_newuserdatauv(L, sizeof(struct world), 0);
        new (w) world;
        w->c.L = L;
        w->c.ecs = (struct ecs_context *)lua_touserdata(L, 1);
        w->c.P = (struct prototype_cache *)lua_touserdata(L, 2);
        if (luaL_newmetatable(L, "gameplay::world")) {
            lua_pushvalue(L, -1);
            lua_setfield(L, -2, "__index");
            luaL_Reg l[] = {
                // techtree
                {"is_researched", is_researched},
                {"research_queue", research_queue},
                {"research_progress", research_progress},

                {"reset", reset},
                {"__gc", destroy},
                {nullptr, nullptr},
            };
            luaL_setfuncs(L, l, 0);
        }
        lua_setmetatable(L, -2);
        return 1;
    }
}



static FILE* tofile(lua_State* L, int idx) {
    struct luaL_Stream* p = (struct luaL_Stream*)luaL_checkudata(L, 2, LUA_FILEHANDLE);
    if (!p->closef)
        luaL_error(L, "attempt to use a closed file");
    lua_assert(p->f);
    return p->f;
}

#if defined(_MSC_VER)
#define MSVC_NONSTDC() _Pragma("warning(suppress: 4996)")
#else
#define MSVC_NONSTDC() 
#endif

static int
lfileno(lua_State* L) {
    struct world* w = (struct world*)lua_touserdata(L, 1);
    FILE* f = tofile(L, 2);
    MSVC_NONSTDC();
    lua_pushinteger(L, fileno(f));
    return 1;
}

extern "C" int
luaopen_vaststars_world_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "create_world", lua_world::create },
		{ "fileno", lfileno },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
