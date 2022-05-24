#pragma once

#include "entity.h"
#include "luaecs.h"

namespace ecs::tag {
    struct pump {};
    struct consumer {};
    struct generator {};
    struct accumulator {};
}

namespace ecs::select {
    template <typename T> struct component {};
    #define COMPONENT_ID(TYPE, ID) \
        template <> \
        struct component<TYPE> { \
            static inline const int id = ID; \
            static inline const char name[] = #TYPE; \
        };

    COMPONENT_ID(entity, COMPONENT_ENTITY)
    COMPONENT_ID(chest, COMPONENT_CHEST)
    COMPONENT_ID(capacitance, COMPONENT_CAPACITANCE)
    COMPONENT_ID(burner, COMPONENT_BURNER)
    COMPONENT_ID(assembling, COMPONENT_ASSEMBLING)
    COMPONENT_ID(laboratory, COMPONENT_LABORATORY)
    COMPONENT_ID(inserter, COMPONENT_INSERTER)
    COMPONENT_ID(fluidboxes, COMPONENT_FLUIDBOXES)
    COMPONENT_ID(fluidbox, COMPONENT_FLUIDBOX)
    COMPONENT_ID(tag::pump, TAG_PUMP)
    COMPONENT_ID(tag::consumer, TAG_CONSUMER)
    COMPONENT_ID(tag::generator, TAG_GENERATOR)
    COMPONENT_ID(tag::accumulator, TAG_ACCUMULATOR)

    #undef COMPONENT_ID

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

    template <typename Component, typename MainKey>
    Component* sibling(ecs_context* ctx, int i) {
        return (Component*)entity_sibling(ctx, component<MainKey>::id, i, component<Component>::id);
    }

    template <typename ...Components>
    struct visit_entity_sibling;

    template <>
    struct visit_entity_sibling <> {
        void operator()(lua_State* L, ecs_context* ctx, int mainkey, int i, entity_<>& e) {}
    };

    template <typename Component, typename ...Components>
    struct visit_entity_sibling<Component, Components...> {
        void operator()(lua_State* L, ecs_context* ctx, int mainkey, int i, entity_<Component, Components...>& e) {
            e.c = (Component*)entity_sibling(ctx, mainkey, i, component<Component>::id);
            if (e.c == NULL) {
                luaL_error(L, "No %s", component<Component>::name);
            }
            visit_entity_sibling<Components...>()(L, ctx, mainkey, i, e);
        }
    };

    template <typename MainKey, typename ...SubKey>
    bool visit_entity(lua_State* L, ecs_context* ctx, int i, entity_<MainKey, SubKey...>& e) {
        int mainkey = component<MainKey>::id;
        e.c = (MainKey*)entity_iter(ctx, mainkey, i);
        if (!e.c) {
            return false;
        }
        visit_entity_sibling<MainKey, SubKey...>()(L, ctx, mainkey, i, e);
        return true;
    }

    template <typename ...Args>
    struct each_range {
        struct iterator {
            lua_State* L;
            ecs_context* ctx;
            int index;
            entity<Args...>& e;
            iterator(entity<Args...>& e)
                : L(NULL)
                , ctx(NULL)
                , index(0)
                , e(e)
            { }
            iterator(lua_State* L, ecs_context* ctx, entity<Args...>& e)
                : L(L)
                , ctx(ctx)
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
                if (visit_entity(L, ctx, index, e)) {
                    e.index = index;
                }
                else {
                    L = NULL;
                    ctx = NULL;
                }
                return *this;
            }
            entity<Args...>& operator*() {
                return e;
            }
        };
        lua_State* L;
        ecs_context* ctx;
        entity<Args...> e;

        each_range(lua_State* L, ecs_context* ctx)
            : L(L)
            , ctx(ctx)
            , e()
        {}

        iterator begin() {
            if (visit_entity(L, ctx, 0, e)) {
                return {L, ctx, e};
            }
            return {e};
        }
        iterator end() {
            return {e};
        }
    };

    template <typename ...Args>
    each_range<Args...> each(lua_State* L, ecs_context* ctx) {
        return each_range<Args...>(L, ctx);
    }
}
