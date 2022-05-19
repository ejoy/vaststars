#include <lua.hpp>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include "world.h"
#include "container.h"
#include "system/fluid.h"
extern "C" {
    #include "fluidflow.h"
}

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
    fluidflow_build(lua_State *L) {
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
    fluidflow_rebuild(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
        uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
        w.fluidflows[fluid].rebuild(id);
        return 0;
    }

    static int
    fluidflow_restore(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
        uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
        int capacity = (int)luaL_checkinteger(L, 4);
        int height = (int)luaL_checkinteger(L, 5);
        int base_level = (int)luaL_checkinteger(L, 6);
        int pumping_speed = (int)luaL_optinteger(L, 7, 0);
        fluid_box box {
            .capacity = capacity,
            .height = height,
            .base_level = base_level,
            .pumping_speed = pumping_speed,
        };
        bool ok = w.fluidflows[fluid].restore(id, &box);
        if (!ok) {
            return luaL_error(L, "fluidflow restore failed.");
        }
        return 0;
    }

    static int
    fluidflow_teardown(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
        uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
        bool ok = w.fluidflows[fluid].teardown(id);
        if (!ok) {
            return luaL_error(L, "fluidflow teardown failed.");
        }
        return 0;
    }

    static int
    fluidflow_connect(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);
        fluidflow& flow = w.fluidflows[fluid];
        luaL_checktype(L, 3, LUA_TTABLE);
        lua_Integer n = luaL_len(L, 3);
        for (lua_Integer i = 1; i+2 <= n; i += 3) {
            lua_rawgeti(L, 3, i);
            lua_rawgeti(L, 3, i+1);
            lua_rawgeti(L, 3, i+2);
            uint16_t from = (uint16_t)luaL_checkinteger(L, -3);
            uint16_t to = (uint16_t)luaL_checkinteger(L, -2);
            bool oneway = !!lua_toboolean(L, -1);
            bool ok =  flow.connect(from, to, oneway);
            if (!ok) {
                return luaL_error(L, "fluidflow connect failed.");
            }
            lua_pop(L, 3);
        }
        return 0;
    }

    static int
    fluidflow_query(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);

        auto& f = w.fluidflows[fluid];
        uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
        fluid_state state;
        if (!f.query(id, state)) {
            return luaL_error(L, "fluidflow query failed.");
        }
        lua_createtable(L, 0, 7);
        lua_pushinteger(L, f.multiple);
        lua_setfield(L, -2, "multiple");
        lua_pushinteger(L, state.volume);
        lua_setfield(L, -2, "volume");
        lua_pushinteger(L, state.flow);
        lua_setfield(L, -2, "flow");
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

    static int
    fluidflow_set(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        uint16_t fluid = (uint16_t)luaL_checkinteger(L, 2);

        auto& f = w.fluidflows[fluid];
        uint16_t id = (uint16_t)luaL_checkinteger(L, 3);
        int value = (int)luaL_checkinteger(L, 4);
        int multiple = (int)luaL_optinteger(L, 5, f.multiple);
        f.set(id, value, multiple);
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
                // fluidflow
                { "fluidflow_build", fluidflow_build },
                { "fluidflow_restore", fluidflow_restore },
                { "fluidflow_teardown", fluidflow_teardown },
                { "fluidflow_connect", fluidflow_connect },
                { "fluidflow_query", fluidflow_query },
                { "fluidflow_set", fluidflow_set },
                { "fluidflow_rebuild", fluidflow_rebuild },
                // misc
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
