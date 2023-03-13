#pragma once

#include <util/kdtree.h>
#include <map>

using ecs_cid = int;

struct station_consumer_kdtree {
    struct point {
        uint8_t x;
        uint8_t y;
        ecs_cid cid;
        point(uint8_t x, uint8_t y, ecs_cid cid)
            : x(x)
            , y(y)
            , cid(cid)
        {}
    };
    using pointcolud = std::vector<point>;
    pointcolud dataset;
    kdtree<uint8_t, 2, pointcolud> tree;
    station_consumer_kdtree()
        : dataset()
        , tree(dataset)
    {}
};

struct station_mgr {
    std::map<uint16_t, station_consumer_kdtree> consumers;
};
