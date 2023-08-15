#pragma once

#include <type_traits>
#include <variant>
#include <string_view>
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>
#include "core/world.h"
#include "util/enum.h"

namespace prototype {
    constexpr size_t CACHE_SLOTS = 1021;

    template <size_t N>
    struct string_literal {
        constexpr string_literal(const char (&str)[N]) {
            std::copy_n(str, N, value);
        }
        char value[N];
    };

    constexpr size_t inthash(uint32_t cid) noexcept {
        size_t h = (2654435761 * cid) % CACHE_SLOTS;
        return h;
    }

    template <string_literal str>
    struct key {};

    inline void error(world& w, const char *fmt, ...) {
        va_list argp;
        va_start(argp, fmt);
        luaL_where(w.L, 1);
        lua_pushvfstring(w.L, fmt, argp);
        va_end(argp);
        lua_concat(w.L, 2);
        lua_error(w.L);
    }

    struct lua_value {
        std::variant<
            std::monostate,   // LUA_TNIL
            bool,             // LUA_TBOOLEAN
            void*,            // LUA_TLIGHTUSERDATA
            lua_Integer,      // LUA_TNUMBER
            lua_Number,       // LUA_TNUMBER
            std::string_view, // LUA_TSTRING
            lua_CFunction     // LUA_TFUNCTION
        > storage;

        template <typename T, typename I>
        static constexpr bool checklimit(I i) {
            static_assert(std::is_integral_v<I>);
            static_assert(std::is_integral_v<T>);
            static_assert(sizeof(I) >= sizeof(T));
            if constexpr (sizeof(I) == sizeof(T)) {
                return true;
            }
            else if constexpr (std::numeric_limits<I>::is_signed == std::numeric_limits<T>::is_signed) {
                return i >= std::numeric_limits<T>::lowest() && i <= (std::numeric_limits<T>::max)();
            }
            else if constexpr (std::numeric_limits<I>::is_signed) {
                return static_cast<std::make_unsigned_t<I>>(i) >= std::numeric_limits<T>::lowest() && static_cast<std::make_unsigned_t<I>>(i) <= (std::numeric_limits<T>::max)();
            }
            else {
                return static_cast<std::make_signed_t<I>>(i) >= std::numeric_limits<T>::lowest() && static_cast<std::make_signed_t<I>>(i) <= (std::numeric_limits<T>::max)();
            }
        }
        void set(lua_State* L, int idx, world& w, uint16_t id, const char* name) {
            switch (lua_type(L, idx)) {
            case LUA_TNIL:
                storage.emplace<std::monostate>();
                break;
            case LUA_TBOOLEAN:
                storage.emplace<bool>(!!lua_toboolean(L, idx));
                break;
            case LUA_TLIGHTUSERDATA:
                storage.emplace<void*>(lua_touserdata(L, idx));
                break;
            case LUA_TNUMBER:
                if (lua_isinteger(L, idx)) {
                    storage.emplace<lua_Integer>(lua_tointeger(L, idx));
                }
                else {
                    storage.emplace<lua_Number>(lua_tonumber(L, idx));
                }
                break;
            case LUA_TSTRING: {
                size_t sz = 0;
                const char* str = lua_tolstring(L, idx, &sz);
                storage.emplace<std::string_view>(str, sz);
                break;
            }
            case LUA_TFUNCTION: {
                lua_CFunction func = lua_tocfunction(L, idx);
                if (func == NULL || lua_getupvalue(L, idx, 1) != NULL) {
                    error(w, "[%d].%s only light C function can be serialized.", id, name);
                    return;
                }
                storage.emplace<lua_CFunction>(func);
                break;
            }
            default:
                error(w, "[%d].%s unsupport type %s to serialize", id, name, lua_typename(L, idx));
                return;
            }
        }

        template <typename T>
        constexpr static inline auto get_value_v = std::is_enum_v<T> || std::is_integral_v<T> || std::is_same_v<T, std::string_view>;

        template <typename R>
        R get(world& w, uint16_t id, const char* name) {
            return std::visit([&](auto&& arg)->R {
                using T = std::decay_t<decltype(arg)>;
                if constexpr (std::is_same_v<T, R>) {
                    return arg;
                }
                else if constexpr (std::is_same_v<T, lua_Integer>) {
                    if constexpr (std::is_integral_v<R>) {
                        static_assert(sizeof(R) <= sizeof(lua_Integer));
                        if (checklimit<R>(arg)) {
                            return static_cast<R>(arg);
                        }
                        error(w, "[%d].%s limit exceeded.", id, name);
                        std::unreachable();
                    }
                    else if constexpr (std::is_enum_v<R>) {
                        using UR = std::underlying_type_t<R>;
                        static_assert(std::is_unsigned_v<UR>);
                        static_assert(sizeof(UR) <= sizeof(size_t));
                        static_assert(sizeof(UR) <= sizeof(lua_Integer));
                        if (static_cast<size_t>(arg) < enum_count_v<R>) {
                            return static_cast<R>(static_cast<UR>(arg));
                        }
                        error(w, "[%d].%s limit exceeded.", id, name);
                        std::unreachable();
                    }
                    else {
                        error(w, "[%d].%s is not integer.", id, name);
                        std::unreachable();
                    }
                }
                else {
                    error(w, "[%d].%s invalid type.", id, name);
                    std::unreachable();
                }
            }, storage);
        }

        template <typename R>
        R const* get_ptr(world& w, uint16_t id, const char* name) {
            return std::visit([&](auto&& arg)->R const* {
                using T = std::decay_t<decltype(arg)>;
                if constexpr (std::is_same_v<T, std::string_view>) {
                    return reinterpret_cast<R const*>(arg.data());
                }
                else {
                    error(w, "[%d].%s invalid type.", id, name);
                    std::unreachable();
                }
            }, storage);
        }

        template <typename R>
        std::span<const R> get_span(world& w, uint16_t id, const char* name) {
            return std::visit([&](auto&& arg)->std::span<const R> {
                using T = std::decay_t<decltype(arg)>;
                if constexpr (std::is_same_v<T, std::string_view>) {
                    if (arg.size() % sizeof(R) != 0) {
                        error(w, "[%d].%s invalid type.", id, name);
                        std::unreachable();
                    }
                    auto first = reinterpret_cast<R const*>(arg.data());
                    auto last  = reinterpret_cast<R const*>(arg.data()+arg.size());
                    return std::span<const R>(first, last);
                }
                else {
                    error(w, "[%d].%s invalid type.", id, name);
                    std::unreachable();
                }
            }, storage);
        }
    };

    struct cache {
        struct cache_slot {
            uint32_t k = 0;
            lua_value v;
        };
        struct cache_slot s[CACHE_SLOTS+1];
        lua_State* L;
        int last = 0;
    };

    inline cache* create_cache(lua_State* L) {
        cache* c = (cache*)lua_newuserdatauv(L, sizeof(*c), 1);
        new (c) cache;
        c->L = lua_newthread(L);
        lua_setiuservalue(L, -2, 1);
        return c;
    }

    inline void bind(world& w, lua_State* L, int idx) {
        cache* c = w.P;
        lua_settop(c->L, 0);
        lua_pushvalue(L, idx);
        lua_xmove(L, c->L, 1);
    }

    inline void fetch_value(world& w, cache* c, uint16_t id, const char* name, lua_value& v) {
        if (id == 0) {
            error(w, "Invalid id 0");
            return;
        }
        if (c->last != id) {
            c->last = 0;
            lua_settop(c->L, 1);
            if (lua_geti(c->L, 1, id) != LUA_TTABLE) {
                lua_pop(c->L, 1);
                error(w, "Absent id %d", id);
                return;
            }
            c->last = id;
        }
        lua_settop(c->L, 2);
        lua_getfield(c->L, 2, name);
        v.set(c->L, 3, w, id, name);
    }

    template <string_literal str, typename T = typename key<str>::type>
    std::conditional_t<lua_value::get_value_v<T>, T, const T&>
    get(world& w, uint16_t id) {
        cache* c = w.P;
        uint32_t cid = (key<str>::id<<16) | id;
        auto& s = c->s[inthash(cid)];
        if (s.k != cid) {
            fetch_value(w, c, id, str.value, s.v);
            s.k = cid;
        }
        if constexpr (lua_value::get_value_v<T>) {
            return s.v.get<T>(w, id, str.value);
        }
        else {
            return *s.v.get_ptr<T>(w, id, str.value);
        }
    }

    template <string_literal str, typename T>
    std::span<const T> get_span(world& w, uint16_t id) {
        cache* c = w.P;
        uint32_t cid = (key<str>::id<<16) | id;
        auto& s = c->s[inthash(cid)];
        if (s.k != cid) {
            fetch_value(w, c, id, str.value, s.v);
            s.k = cid;
        }
        return s.v.get_span<T>(w, id, str.value);
    }

#define PROTOTYPE(NAME, TYPE) \
    template <> struct key<#NAME> { \
        using type = TYPE; \
        static constexpr uint16_t id = __LINE__; \
    };
    PROTOTYPE(priority, uint8_t)
    PROTOTYPE(power, uint32_t)
    PROTOTYPE(drain, uint32_t)
    PROTOTYPE(charge_power, uint32_t)
    PROTOTYPE(capacitance, uint32_t)
    PROTOTYPE(cost, uint32_t)
    PROTOTYPE(time, uint32_t)
    PROTOTYPE(speed, uint32_t)
    PROTOTYPE(count, uint16_t)
    PROTOTYPE(area, uint16_t)
    PROTOTYPE(supply_area, uint16_t)
    PROTOTYPE(starting, uint16_t)
    PROTOTYPE(endpoint, uint16_t)
    PROTOTYPE(road, std::string_view)
    PROTOTYPE(ingredients, std::string_view)
    PROTOTYPE(results, std::string_view)
    PROTOTYPE(inputs, std::string_view)
    PROTOTYPE(task, std::string_view)
#undef PROTOTYPE
}
