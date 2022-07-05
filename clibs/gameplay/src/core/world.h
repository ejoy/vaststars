#pragma once

#include "core/container.h"
#include "ecs/select.h"
#include "core/techtree.h"
#include "core/statistics.h"
#include "system/fluid.h"
#include "system/manual.h"
#include <map>
extern "C" {
#include "util/prototype.h"
}

struct lua_State;
struct ecs_context;
struct prototype_cache;

struct world {
    struct ecs_context*     ecs;
    struct prototype_cache* P;
    struct container_mgr containers;
    std::map<uint16_t, fluidflow> fluidflows;
    techtree_mgr techtree;
    statistics stat;
    manual_crafting manual;
    uint64_t time = 0;

    template <typename C>
    C& query_container(uint16_t id);
    template <typename C>
    uint16_t container_id();

    template <typename ...Args>
    bool visit_entity(lua_State* L, ecs_api::entity<Args...>& e, int i) {
        return ecs_api::visit_entity(ecs, L, i, e);
    }

    template <typename Component, typename MainKey, typename ...SubKey>
    Component* sibling(ecs_api::entity<MainKey, SubKey...>& e) {
        return ecs_api::sibling<Component, MainKey, SubKey...>(ecs, e);
    }

    template <typename ...Args>
    ecs_api::each_range<Args...> select(lua_State* L) {
        return ecs_api::select<Args...>(ecs, L);
    }

    prototype_context prototype(lua_State* L, int id) {
        return {L, P, id};
    }
};
