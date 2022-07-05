#pragma once

struct lua_State;

#include "ecs/component.h"
#include "luaecs.h"

namespace ecs_api {
    template <typename ...Components>
    struct entity_;

    template <>
    struct entity_<> {
    };

    template <typename Component, typename ...Components>
    struct entity_<Component, Components...> : public entity_<Components...> {
        Component* c;
        template <typename T>
        T& get() {
            if constexpr (std::is_same<T, Component>::value) {
                return *c;
            }
            else {
                return entity_<Components...>::template get<T>();
            }
        }
    };

    template <typename ...Components>
    struct entity : public entity_<Components...> {
        int index;
    };

    template <typename Component, typename MainKey, typename ...SubKey>
    Component* sibling(ecs_context* ctx, ecs_api::entity<MainKey, SubKey...>& e) {
        return (Component*)entity_sibling(ctx, component<MainKey>::id, e.index, component<Component>::id);
    }

    template <typename ...Components>
    struct visit_entity_sibling;

    template <>
    struct visit_entity_sibling <> {
        void operator()(ecs_context* ctx, lua_State* L, int mainkey, int i, entity_<>& e) {}
    };

    template <typename Component, typename ...Components>
    struct visit_entity_sibling<Component, Components...> {
        void operator()(ecs_context* ctx, lua_State* L, int mainkey, int i, entity_<Component, Components...>& e) {
            e.c = (Component*)entity_sibling(ctx, mainkey, i, component<Component>::id);
            if (e.c == NULL) {
                luaL_error(L, "No %s", component<Component>::name);
            }
            visit_entity_sibling<Components...>()(ctx, L, mainkey, i, e);
        }
    };

    template <typename MainKey, typename ...SubKey>
    bool visit_entity(ecs_context* ctx, lua_State* L, int i, entity_<MainKey, SubKey...>& e) {
        int mainkey = component<MainKey>::id;
        e.c = (MainKey*)entity_iter(ctx, mainkey, i);
        if (!e.c) {
            return false;
        }
        visit_entity_sibling<MainKey, SubKey...>()(ctx, L, mainkey, i, e);
        return true;
    }

    template <typename ...Args>
    struct each_range {
        struct iterator {
            ecs_context* ctx;
            lua_State* L;
            int index;
            entity<Args...>& e;
            iterator(entity<Args...>& e)
                : ctx(NULL)
                , L(NULL)
                , index(0)
                , e(e)
            { }
            iterator(ecs_context* ctx, lua_State* L, entity<Args...>& e)
                : ctx(ctx)
                , L(L)
                , index(0)
                , e(e)
            { }
    
            bool operator!=(iterator const& o) const {
                if (ctx != o.ctx) {
                    return true;
                }
                if (ctx == NULL) {
                    return false;
                }
                return index != o.index;
            }
            iterator& operator++() {
                index++;
                if (visit_entity(ctx, L, index, e)) {
                    e.index = index;
                }
                else {
                    ctx = NULL;
                    L = NULL;
                }
                return *this;
            }
            entity<Args...>& operator*() {
                return e;
            }
        };
        ecs_context* ctx;
        lua_State* L;
        entity<Args...> e;

        each_range(ecs_context* ctx, lua_State* L)
            : ctx(ctx)
            , L(L)
            , e()
        {}

        iterator begin() {
            if (visit_entity(ctx, L, 0, e)) {
                return {ctx, L, e};
            }
            return {e};
        }
        iterator end() {
            return {e};
        }
    };

    template <typename ...Args>
    each_range<Args...> select(ecs_context* ctx, lua_State* L) {
        return each_range<Args...>(ctx, L);
    }
}
