#include <lua.hpp>
#include <binding/binding.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include "core/world.h"
#include "core/chest.h"
#include "system/fluid.h"
#include "util/prototype.h"
extern "C" {
    #include "core/fluidflow.h"
}

#if defined(_WIN32)
    #include <windows.h>
#endif

namespace lua_world {
    static int
    is_researched(lua_State* L) {
        auto& w = getworld(L);
        uint16_t techid = bee::lua::checkinteger<uint16_t>(L, 2);
        lua_pushboolean(L, w.techtree.is_researched(techid));
        return 1;
    }
    
    static int
    research_queue(lua_State* L) {
        auto& w = getworld(L);
        if (lua_gettop(L) == 1) {
            auto& q = w.techtree.queue_get();
            size_t N = q.size();
            lua_createtable(L, (int)N, 0);
            for (size_t i = 0; i < N; ++i) {
                lua_pushinteger(L, q[i]);
                lua_rawseti(L, -2, i+1);
            }
            return 1;
        }
        luaL_checktype(L, 2, LUA_TTABLE);
        std::vector<uint16_t> q;
        for (lua_Integer i = 1;; ++i) {
            if (lua_rawgeti(L, 2, i) == LUA_TNIL) {
                break;
            }
            q.push_back(bee::lua::checkinteger<uint16_t>(L, -1));
        }
        w.techtree.queue_set(q);
        return 0;
    }

    static int
    research_progress(lua_State* L) {
        auto& w = getworld(L);
        uint16_t techid = bee::lua::checkinteger<uint16_t>(L, 2);
        if (lua_gettop(L) == 2) {
            uint16_t progress = w.techtree.get_progress(techid);
            if (progress == 0) {
                return 0;
            }
            lua_pushinteger(L, progress);
            return 1;
        }
        uint16_t value = bee::lua::checkinteger<uint16_t>(L, 3);
        bool ok = w.techtree.research_set(w, techid, value);
        lua_pushboolean(L, ok);
        return 1;
    }

    static int set_dirty(lua_State* L) {
        auto& w = getworld(L);
        w.dirty |= bee::lua::checkinteger<uint64_t>(L, 2);
        return 0;
    }

    static int is_dirty(lua_State* L) {
        auto& w = getworld(L);
        uint64_t mask = bee::lua::optinteger<uint64_t, (uint64_t)-1>(L, 2);
        lua_pushboolean(L, (w.dirty & mask) != 0);
        return 1;
    }

    static int reset_dirty(lua_State* L) {
        auto& w = getworld(L);
        w.dirty = 0;
        return 0;
    }

    static int prototype_bind(lua_State* L) {
        auto& w = getworld(L);
        prototype::bind(w, L, 2);
        return 0;
    }

    static int
    destroy(lua_State* L) {
        auto& w = getworld(L);
        w.~world();
        return 0;
    }

    int backup_world(lua_State* L);
    int restore_world(lua_State* L);

    constexpr static intptr_t LuaFunction = 0x7000000000000000;

    static int system_call(lua_State* L) {
        intptr_t* list = (intptr_t*)lua_touserdata(L, lua_upvalueindex(4));
        size_t n = lua_rawlen(L, lua_upvalueindex(4)) / sizeof(intptr_t);
        lua_settop(L, 0);
        lua_pushvalue(L, lua_upvalueindex(1));
        for (size_t i = 0; i < n; ++i) {
            intptr_t f = list[i];
            if (f != LuaFunction) {
                ((lua_CFunction)f)(L);
            }
            else {
                lua_rawgeti(L, lua_upvalueindex(3), i+1);
                lua_pushvalue(L, lua_upvalueindex(2));
                lua_call(L, 1, 0);
            }
        }
        return 0;
    }

    static int system_solve(lua_State* L) {
        luaL_checktype(L, 3, LUA_TTABLE);
        lua_settop(L, 3);

        lua_Integer n = luaL_len(L, 3);
        intptr_t* list = (intptr_t*)lua_newuserdatauv(L, sizeof(intptr_t) * n, 3);
        for (lua_Integer i = 1; i <= n; ++i) {
            lua_rawgeti(L, 3, i);
            luaL_checktype(L, -1, LUA_TFUNCTION);
            if (lua_iscfunction(L, -1)) {
                intptr_t f = (intptr_t)lua_tocfunction(L, -1);
                assert(f != LuaFunction);
                list[i-1] = f;
            }
            else {
                list[i-1] = LuaFunction;
            }
            lua_pop(L, 1);
        }
        lua_pushcclosure(L, system_call, 4);
        return 1;
    }

    static uint64_t time_monotonic() {
        uint64_t t;
#if defined(_WIN32)
        t = GetTickCount64();
#else
        struct timespec ti;
        clock_gettime(CLOCK_MONOTONIC, &ti);
        t = (uint64_t)ti.tv_sec * 1000 + ti.tv_nsec / 1000000;
#endif
        return t;
    }

    static int system_perf_call(lua_State* L) {
        intptr_t* list = (intptr_t*)lua_touserdata(L, lua_upvalueindex(4));
        size_t n = lua_rawlen(L, lua_upvalueindex(4)) / sizeof(intptr_t);
        lua_settop(L, 0);
        lua_pushvalue(L, lua_upvalueindex(1));
        for (size_t i = 0; i < n; ++i) {
            uint64_t time = time_monotonic();
            intptr_t f = list[i];
            if (f != LuaFunction) {
                ((lua_CFunction)f)(L);
            }
            else {
                lua_rawgeti(L, lua_upvalueindex(3), i+1);
                lua_pushvalue(L, lua_upvalueindex(2));
                lua_call(L, 1, 0);
            }
            time = time_monotonic() - time;
            lua_rawgeti(L, lua_upvalueindex(5), i+1);
            lua_pushinteger(L, time + lua_tointeger(L, -1));
            lua_rawseti(L, lua_upvalueindex(5), i+1);
            lua_pop(L, 1);
        }
        return 0;
    }

    static int system_perf_solve(lua_State* L) {
        luaL_checktype(L, 3, LUA_TTABLE);
        lua_settop(L, 3);

        lua_Integer n = luaL_len(L, 3);
        intptr_t* list = (intptr_t*)lua_newuserdatauv(L, sizeof(intptr_t) * n, 3);
        lua_createtable(L, (int)n, 0);
        for (lua_Integer i = 1; i <= n; ++i) {
            lua_rawgeti(L, 3, i);
            luaL_checktype(L, -1, LUA_TFUNCTION);
            if (lua_iscfunction(L, -1)) {
                intptr_t f = (intptr_t)lua_tocfunction(L, -1);
                assert(f != LuaFunction);
                list[i-1] = f;
            }
            else {
                list[i-1] = LuaFunction;
            }
            lua_pop(L, 1);
            lua_pushinteger(L, 0);
            lua_rawseti(L, -2, i);
        }
        lua_pushcclosure(L, system_perf_call, 5);
        lua_getupvalue(L, -1, 5);
        return 2;
    }

    static int
    create(lua_State* L) {
        struct world* w = (struct world*)lua_newuserdatauv(L, sizeof(struct world), 1);
        new (w) world;
        w->L = L;
        w->ecs = (struct ecs_context *)lua_touserdata(L, 1);
        w->P = prototype::create_cache(L);
        lua_setiuservalue(L, -2, 1);

        if (luaL_newmetatable(L, "gameplay::world")) {
            lua_pushvalue(L, -1);
            lua_setfield(L, -2, "__index");
            luaL_Reg l[] = {
                // techtree
                {"is_researched", is_researched},
                {"research_queue", research_queue},
                {"research_progress", research_progress},
                // saveload
                { "backup_world", backup_world },
                { "restore_world", restore_world },
                // misc
                {"set_dirty", set_dirty},
                {"is_dirty", is_dirty},
                {"reset_dirty", reset_dirty},
                {"prototype_bind", prototype_bind},
                {"system_solve", system_solve},
                {"system_perf_solve", system_perf_solve},
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

struct world& getworld(lua_State* L) {
    auto& w = *(struct world*)lua_touserdata(L, 1);
    w.L = L;
    return w;
}
