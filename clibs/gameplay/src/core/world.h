#pragma once

#include "core/container.h"
#include "core/select.h"
#include "core/techtree.h"
#include "core/statistics.h"
#include "system/fluid.h"
#include <map>
extern "C" {
#include "util/prototype.h"
}

struct lua_State;
struct ecs_context;
struct prototype_cache;

struct world {
    struct lua_State*       L;
    struct ecs_context*     ecs;
    struct prototype_cache* P;
    struct container_mgr containers;
    std::map<uint16_t, fluidflow> fluidflows;
    techtree_mgr techtree;
    statistics stat;
    uint64_t time = 0;

    template <typename C>
    C& query_container(uint16_t id);
    template <typename C>
    uint16_t container_id();

    template <typename ...Args>
    bool visit_entity(ecs::select::entity<Args...>& e, int i) {
        return ecs::select::visit_entity(L, ecs, i, e);
    }

    template <typename Component, typename MainKey, typename ...SubKey>
    Component* sibling(ecs::select::entity<MainKey, SubKey...>& e) {
        return ecs::select::sibling<Component, MainKey>(ecs, e.index);
    }

    template <typename ...Args>
    ecs::select::each_range<Args...> select() {
        return ecs::select::each<Args...>(L, ecs);
    }

    prototype_context prototype(int id) {
        return {L, P, id};
    }
};
