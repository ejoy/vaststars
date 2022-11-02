#pragma once

#include <stdint.h>
#include <util/queue.h>
#include <core/chest.h>
#include <util/kdtree.h>
#include <map>

struct world;

struct trading_who {
    uint16_t endpoint;
    uint16_t index;
};

struct trading_order {
    uint16_t item;
    trading_who sell;
    trading_who buy;
};

constexpr size_t SELL_PRIORITY = 2;
constexpr size_t BUY_PRIORITY = 2;

struct trading_queue {
    queue<trading_who> sell[SELL_PRIORITY];
    queue<trading_who> buy[BUY_PRIORITY];
};

struct trading_kdtree {
    struct point {
        uint8_t x;
        uint8_t y;
        uint16_t id;
        point(uint8_t x, uint8_t y, uint16_t id)
            : x(x)
            , y(y)
            , id(id)
        {}
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

void trading_sell(world& w, trading_who who, uint8_t priority, chest::slot& s);
void trading_buy(world& w, trading_who who, uint8_t priority, chest::slot& s);
void trading_update(world& w);
