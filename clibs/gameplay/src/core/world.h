#pragma once

#include "core/container.h"
#include "ecs/component.h"
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

struct world: public ecs_api::context {
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

    prototype_context prototype(lua_State* L, int id) {
        return {L, P, id};
    }
};
