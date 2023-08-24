#pragma once

#include <cstdint>
#include <functional>
#include <optional>
#include <roadnet/type.h>

struct world;
struct market_impl;

enum class market_start_type: uint8_t {
    starting,
    endpoint,
};

struct market_match {
    uint16_t item;
    uint16_t from;
    uint16_t to;
    uint16_t dist1;
    uint16_t dist2;
    static bool sort1(const market_match& a, const market_match& b) {
        return a.dist1 < b.dist1;
    }
    static bool sort2(const market_match& a, const market_match& b) {
        return a.dist2 > b.dist2;
    }
};

using market_match_func = std::function<void(uint16_t item, market_start_type type, uint16_t start, uint16_t from, uint16_t to)>;
struct market {
    market();
    ~market();
    void reset_park();
    void reset_station();
    void set_park(uint16_t endpointid);
    void add_supply(uint16_t endpointid, uint16_t item);
    void add_demand(uint16_t endpointid, uint16_t item);
    void match_begin(world& w);
    std::optional<market_match> match(world& w, roadnet::straightid pos);
    void match_end(world& w);
    uint16_t nearest_park(world& w, roadnet::straightid pos);
    bool relocate(world& w, uint16_t item, roadnet::straightid pos, uint16_t& to);
    market_impl* impl;
};
