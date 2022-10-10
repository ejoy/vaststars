#pragma once

#include <stdint.h>
#include <util/queue.h>
#include <core/chest.h>
#include <map>

struct world;

struct trading_order {
    uint16_t item;
    uint16_t sell;
    uint16_t buy;
};

struct trading_queue {
    queue<uint16_t> sell;
    queue<uint16_t> buy;
};

struct trading_network {
    std::map<uint16_t, trading_queue> queues;
    queue<trading_order> orders;
};

void trading_sell(world& w, uint16_t who, uint8_t network, chest::slot& s);
void trading_buy(world& w, uint16_t who, uint8_t network, chest::slot& s);
void trading_update(world& w);
