#pragma once

struct ecs_context;
struct prototype_cache;

#if defined(__cplusplus)
struct cworld {
#else
struct world {
#endif
    struct lua_State*       L;
    struct ecs_context*     ecs;
    struct prototype_cache* P;
};

#if defined(__cplusplus)

#include "container.h"
#include "select.h"
#include "system/fluid.h"
#include "techtree.h"
#include "system/statistics.h"
#include <map>
extern "C" {
#include "prototype.h"
}

struct world {
    struct cworld c;
    struct container_mgr containers;
    std::map<uint16_t, fluidflow> fluidflows;
    techtree_mgr techtree;
    statistics stat;

    template <typename C>
    C& query_container(uint16_t id);
    template <typename C>
    uint16_t container_id();

    template <typename ...Args>
    bool visit_entity(ecs::select::entity<Args...>& e, int i) {
        return ecs::select::visit_entity(c.L, c.ecs, i, e);
    }

    template <typename Component, typename MainKey, typename ...SubKey>
    Component* sibling(ecs::select::entity<MainKey, SubKey...>& e) {
        return ecs::select::sibling<Component, MainKey>(c.ecs, e.index);
    }

    template <typename ...Args>
    ecs::select::each_range<Args...> select() {
        return ecs::select::each<Args...>(c.L, c.ecs);
    }

    prototype_context prototype(int id) {
        return {c.L, c.P, id};
    }
};

#endif
