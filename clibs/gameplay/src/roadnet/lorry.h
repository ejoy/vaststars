#pragma once

#include "roadnet/type.h"
#include "util/component.h"

struct world;
struct lorry_entity;

namespace roadnet {
    class network;
    void lorryInit(ecs::lorry& l);
    void lorryInit(ecs::lorry& l, world& w, uint16_t classid);
    void lorryDestroy(ecs::lorry& l, world& w);
    bool lorryInvalid(ecs::lorry& l);
    void lorryBlink(ecs::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z);
    void lorryMove(ecs::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z);
    void lorryItemReset(ecs::lorry& l);
    void lorryItemSet(ecs::lorry& l, uint16_t item, uint16_t amount);
    void lorryGo(ecs::lorry& l, ecs::endpoint& ending);
    void lorryUpdate(ecs_api::entity<ecs::lorry>& e, ecs::lorry& l);
    bool lorryNextDirection(ecs::lorry& l, network& w, straightid C, direction& dir);
    bool lorryReady(ecs::lorry const& l) noexcept;
}
