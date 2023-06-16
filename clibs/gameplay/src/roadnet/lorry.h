#pragma once

#include "roadnet/type.h"
#include "util/component.h"
#include <utility>

struct world;

namespace roadnet::road {
    struct cross;
    struct straight;
}

namespace roadnet {
    class network;
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid);
    void lorryEntry(ecs::lorry& l, uint8_t x, uint8_t y, uint8_t z);
    void lorryGo(ecs::lorry& l, straightid ending, uint16_t item_classid, uint16_t item_amount);
    void lorryReset(ecs::lorry& l, world& w);
    void lorryUpdate(ecs::lorry& l, network& w, uint64_t ti);
    bool lorryNextDirection(ecs::lorry& l, network& w, straightid C, direction& dir);
    bool lorryReady(ecs::lorry const& l) noexcept;
}
