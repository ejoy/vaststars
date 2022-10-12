#pragma once

#include "core/chest.h"
#include "util/component.h"
#include "ecs/select.h"
#include "core/techtree.h"
#include "core/statistics.h"
#include "system/trading.h"
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
    std::vector<chest> chests;
    std::map<uint16_t, fluidflow> fluidflows;
    trading_network tradings;
    techtree_mgr techtree;
    statistics stat;
    manual_crafting manual;
    uint64_t time = 0;

    chest& query_chest(uint16_t id);

    prototype_context prototype(lua_State* L, int id) {
        return {L, P, id};
    }
};
