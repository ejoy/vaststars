#pragma once

#include "core/chest.h"
#include "util/component.h"
#include "ecs/select.h"
#include "core/techtree.h"
#include "core/statistics.h"
#include "core/market.h"
#include "system/fluid.h"
#include "system/drone.h"
#include "system/building.h"
#include "roadnet/network.h"
#include <map>

struct lua_State;
struct ecs_context;

namespace prototype {
    struct cache;
}

constexpr uint64_t kDirtyRoadnet   = 1 << 1;
constexpr uint64_t kDirtyFluidflow = 1 << 2;
constexpr uint64_t kDirtyChest     = 1 << 3;
constexpr uint64_t kDirtyPark      = 1 << 4;
constexpr uint64_t kDirtyStation   = 1 << 5;
constexpr uint64_t kDirtyAirport   = 1 << 6;
constexpr uint64_t kDirtyEndpoint  = 1 << 7;


struct world {
    ecs_context* ecs;
    lua_State* L;
    prototype::cache* P;
    container container;
    std::map<uint16_t, fluidflow> fluidflows;
    techtree_mgr techtree;
    statistics stat;
    roadnet::network rw;
    std::map<uint16_t, airport> airports;
    flatmap<uint16_t, building> buildings;
    market market;
    uint64_t time = 0;
    uint64_t dirty = 0;
    uint32_t drone_time = 0;
    component::global_state* state;
};

struct world& getworld(lua_State* L);
