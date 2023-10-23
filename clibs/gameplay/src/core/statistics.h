#pragma once

#include "flatmap.h"
#include <array>

struct world;

template <typename Key, typename Mapped>
void stat_add(flatmap<Key, Mapped>& m, Key const& key, Mapped mapped) {
    auto [found, slot] = m.find_or_insert(key);
    if (found) {
        *slot += mapped;
    }
    else {
        *slot = mapped;
    }
}

struct statistics {
    struct frame {
        flatmap<uint16_t, uint32_t> production;
        flatmap<uint16_t, uint32_t> consumption;
        flatmap<uint16_t, uint64_t> generate_power;
        flatmap<uint16_t, uint64_t> consume_power;
        void reset();
        void add(frame const& f);
    };
    static constexpr uint16_t PRECISION = 150;
    struct dataset {
        std::array<frame, PRECISION> data;
        uint16_t pos = 0;
        uint64_t tick;
        void step();
        void sum(dataset const& d);
        bool update(uint64_t time);
        bool update(uint64_t time, dataset const& d);
        frame const& back() const;
    };

    statistics();
    void finish_recipe(world& w, uint16_t id);
    void update(uint64_t time);
    frame& current();

    std::array<dataset, 8> _dataset;
    frame _total;
};
