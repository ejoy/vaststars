#include <core/market.h>
#include <core/world.h>
#include <roadnet/route.h>
#include "flatmap.h"
#include <map>
#include <vector>
#include <optional>

struct market_path {
    uint16_t from;
    uint16_t to;
    uint16_t distance;
    market_path(uint16_t from, uint16_t to, uint16_t distance)
        : from(from)
        , to(to)
        , distance(distance)
    { }
    static bool sort(const market_path& a, const market_path& b) {
        return a.distance < b.distance;
    }
};

struct market_item {
    uint16_t item;
    flatmap<uint16_t, uint8_t> supply;
    flatmap<uint16_t, uint8_t> demand;
};

struct market_endpoint {
    uint16_t id;
    uint16_t distance;
    market_endpoint(uint16_t id, uint16_t distance)
        : id(id)
        , distance(distance)
    { }
    static bool sort(const market_endpoint& a, const market_endpoint& b) {
        return a.distance < b.distance;
    }
};

struct market_station {
    std::vector<uint16_t> parks;
};

struct market_impl {
    std::vector<market_item> items;
    flatset<uint16_t> parks;
    flatmap<roadnet::straightid, uint16_t> nearest_parks;
    std::vector<market_match> matchs;
};

template <typename Key, typename Mapped>
void flatmap_add(flatmap<Key, Mapped>& m, Key const& key, Mapped mapped) {
    auto [found, slot] = m.find_or_insert(key);
    if (found) {
        *slot += mapped;
    }
    else {
        *slot = mapped;
    }
}

market::market()
    : impl(new market_impl)
{}

market::~market() {
    delete impl;
}

void market::reset_park() {
    impl->parks.clear();
    impl->nearest_parks.clear();
}

void market::reset_station() {
    impl->items.clear();
}

void market::set_park(uint16_t endpointid) {
    impl->parks.insert(endpointid);
}

void market::add_supply(uint16_t endpointid, uint16_t item) {
    for (auto& m : impl->items) {
        if (m.item == item) {
            flatmap_add(m.supply, endpointid, uint8_t(1));
            return;
        }
    }
    market_item m { .item = item };
    flatmap_add(m.supply, endpointid, uint8_t(1));
    impl->items.emplace_back(std::move(m));
}

void market::add_demand(uint16_t endpointid, uint16_t item) {
    for (auto& m : impl->items) {
        if (m.item == item) {
            flatmap_add(m.demand, endpointid, uint8_t(1));
            return;
        }
    }
    market_item m { .item = item };
    flatmap_add(m.demand, endpointid, uint8_t(1));
    impl->items.emplace_back(std::move(m));
}

void market::match_begin(world& w) {
    impl->matchs.clear();
    auto endpoints = ecs::array<component::endpoint>(w.ecs);
    for (auto it = impl->items.begin(); it != impl->items.end();) {
        auto& m = *it;
        std::vector<market_path> paths;
        for (auto const& [from, _] : m.supply) {
            auto starting = endpoints[from].neighbor;
            for (auto const& [to, _] : m.demand) {
                auto ending = endpoints[to].rev_neighbor;
                if (auto distance = route_distance(w.rw, starting, ending)) {
                    paths.emplace_back(from, to, *distance);
                }
            }
        }
        std::sort(std::begin(paths), std::end(paths), market_path::sort);
        for (auto const& path : paths) {
            auto supply_n = m.supply.find(path.from);
            auto demand_n = m.demand.find(path.to);
            if (supply_n && demand_n) {
                auto min = std::min(*supply_n, *demand_n);
                for (auto i = 0; i < min; ++i) {
                    *supply_n -= 1;
                    *demand_n -= 1;
                    impl->matchs.emplace_back(m.item, path.from, path.to, path.distance);
                }
                if (*supply_n == 0) {
                    m.supply.erase(path.from);
                }
                if (*demand_n == 0) {
                    m.demand.erase(path.to);
                }
            }
        }
        if (m.supply.empty() && m.demand.empty()) {
            it = impl->items.erase(it);
        }
        else {
            ++it;
        }
    }
}

void market::match_end(world& w) {
    std::sort(std::begin(impl->matchs), std::end(impl->matchs), market_match::sort1);
    for (auto const& m : impl->matchs) {
        add_supply(m.from, m.item);
        add_demand(m.to, m.item);
    }
    impl->matchs.clear();
}

std::optional<market_match> market::match(world& w, roadnet::straightid pos) {
    if (impl->matchs.empty()) {
        return std::nullopt;
    }
    auto endpoints = ecs::array<component::endpoint>(w.ecs);
    for (auto& m : impl->matchs) {
        if (auto distance = route_distance(w.rw, pos, endpoints[m.from].rev_neighbor)) {
            m.dist2 = m.dist1 + *distance;
        }
        else {
            m.dist2 = 0xffff;
        }
    }
    std::sort(std::begin(impl->matchs), std::end(impl->matchs), market_match::sort2);
    auto m = impl->matchs.back();
    if (m.dist2 == 0xffff) {
        return std::nullopt;
    }
    impl->matchs.pop_back();
    return m;
}

uint16_t market::nearest_park(world& w, roadnet::straightid pos) {
    auto [found, slot] = impl->nearest_parks.find_or_insert(pos);
    if (found) {
        return *slot;
    }
    auto endpoints = ecs::array<component::endpoint>(w.ecs);
    std::vector<market_endpoint> park_sorts;
    park_sorts.reserve(impl->parks.size());
    for (auto id: impl->parks) {
        auto ending = endpoints[id].rev_neighbor;
        if (auto distance = route_distance(w.rw, pos, ending)) {
            park_sorts.emplace_back(id, *distance);
        }
    }
    if (park_sorts.empty()) {
        *slot = 0xffff;
    }
    else {
        std::sort(std::begin(park_sorts), std::end(park_sorts), market_endpoint::sort);
        *slot = park_sorts.front().id;
    }
    return *slot;
}

bool market::relocate(world& w, uint16_t item, roadnet::straightid pos, uint16_t& to) {
    for (auto& m : impl->items) {
        if (m.item == item) {
            auto endpoints = ecs::array<component::endpoint>(w.ecs);
            uint16_t min_to;
            uint16_t min_distance = 0xFFFF;
            for (auto const& [to, _] : m.demand) {
                auto ending = endpoints[to].rev_neighbor;
                if (auto distance = route_distance(w.rw, pos, ending)) {
                    if (min_distance < *distance) {
                        min_to = to;
                        min_distance = *distance;
                    }
                }
            }
            if (min_distance == 0xFFFF) {
                return false;
            }
            auto demand_n = m.demand.find(min_to);
            *demand_n -= 1;
            if (*demand_n == 0) {
                m.demand.erase(min_to);
            }
            to = min_to;
            return true;
        }
    }
    return false;
}