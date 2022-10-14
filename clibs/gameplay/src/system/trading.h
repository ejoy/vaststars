#pragma once

#include <stdint.h>
#include <util/queue.h>
#include <core/chest.h>
#include <util/kdtree.h>
#include <map>

struct world;

struct trading_who {
    uint16_t id;
};

struct trading_order {
    uint16_t item;
    trading_who sell;
    trading_who buy;
};

struct trading_queue {
    queue<trading_who> sell;
    queue<trading_who> buy;
};

struct trading_kdtree {
    struct point {
        uint8_t x;
        uint8_t y;
        uint16_t id;
    };
    using pointcolud = std::vector<point>;
    pointcolud dataset;
    kdtree<uint8_t, 2, pointcolud> tree;
    trading_kdtree()
        : dataset()
        , tree(dataset)
    {}
};

struct trading_network {
    std::map<uint16_t, trading_queue> queues;
    queue<trading_order> orders;
    trading_kdtree station_kdtree;
};

void trading_sell(world& w, trading_who who, chest::slot& s);
void trading_buy(world& w, trading_who who, chest::slot& s);
void trading_update(world& w);
