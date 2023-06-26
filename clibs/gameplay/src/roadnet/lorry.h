#pragma once

#include "roadnet/type.h"
#include "util/component.h"

struct world;

namespace roadnet {
    class network;
    void lorryInit(ecs::lorry& l);
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid);
    void lorryDestroy(ecs::lorry& l, world& w);
    bool lorryInvalid(ecs::lorry& l);
    void lorryEntry(ecs::lorry& l, uint8_t x, uint8_t y, uint8_t z);
    void lorryItemReset(ecs::lorry& l);
    void lorryItemSet(ecs::lorry& l, uint16_t item_classid, uint16_t item_amount);
    void lorryGo(ecs::lorry& l, ecs::endpoint& ending);
    void lorryUpdate(ecs::lorry& l, network& w, uint64_t ti);
    bool lorryNextDirection(ecs::lorry& l, network& w, straightid C, direction& dir);
    bool lorryReady(ecs::lorry const& l) noexcept;
}
