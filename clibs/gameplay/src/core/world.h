#pragma once

#include "core/chest.h"
#include "util/component.h"
#include "ecs/select.h"
#include "core/techtree.h"
#include "core/statistics.h"
#include "system/fluid.h"
#include "system/hub.h"
#include "system/station.h"
#include "roadnet/network.h"
#include <map>

struct lua_State;
struct ecs_context;

namespace prototype {
    struct cache;
}

struct world {
    ecs_context* ecs;
    lua_State* L;
    prototype::cache* P;
    container container;
    std::map<uint16_t, fluidflow> fluidflows;
    techtree_mgr techtree;
    statistics stat;
    roadnet::network rw;
    hub_mgr hubs;
    station_mgr stations;
    uint64_t time = 0;
};

struct world& getworld(lua_State* L);
