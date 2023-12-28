#pragma once

#include "roadnet/type.h"
#include "util/component.h"

struct world;
struct lorry_entity;

namespace roadnet {
    class network;
    void lorryInit(component::lorry& l);
    void lorryInit(component::lorry& l, world& w, uint16_t classid);
    void lorryDestroy(component::lorry& l, world& w);
    bool lorryInvalid(component::lorry& l);
    void lorryBlink(component::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z);
    void lorryMove(component::lorry& l, world& w, uint8_t x, uint8_t y, uint8_t z);
    void lorryGoMov1(component::lorry& l, uint16_t item, component::endpoint& mov1, component::endpoint& mov2);
    void lorryGoMov2(component::lorry& l, roadnet::straightid mov2, uint16_t amount);
    void lorryGoHome(component::lorry& l, component::endpoint& home);
    void lorryTargetNone(component::lorry& l);
    void lorryUpdate(ecs::entity<component::lorry>& e, component::lorry& l);
    bool lorryNextDirection(component::lorry& l, world& w, straightid C, direction& dir);
    bool lorryReady(component::lorry const& l) noexcept;
}
