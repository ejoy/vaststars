#include <lua.hpp>
#include "core/world.h"
#include "util/prototype.h"

template <typename Key, typename Mapped>
void flatmap_add(flatmap<Key, Mapped>& a, flatmap<Key, Mapped> const& b) {
    for (auto const& [k, v] : b) {
        stat_add(a, k, v);
    }
}

template <typename Key, typename Mapped>
void flatmap_stat(flatmap<Key, Mapped>& m, recipe_items const& r) {
    for (size_t i = 0; i < r.n; ++i) {
        stat_add<Key, Mapped>(m, r.items[i].item, r.items[i].amount);
    }
}

void statistics::finish_recipe(world& w, uint16_t id) {
    auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, id);
    auto const& results = prototype::get<"results", recipe_items>(w, id);
    auto& frame = current();
    flatmap_stat(frame.consumption, ingredients);
    flatmap_stat(frame.production, results);
}

void statistics::frame::reset() {
    production.clear();
    consumption.clear();
    generate_power.clear();
    consume_power.clear();
}

void statistics::frame::add(frame const& f) {
    flatmap_add(production, f.production);
    flatmap_add(consumption, f.consumption);
    flatmap_add(generate_power, f.generate_power);
    flatmap_add(consume_power, f.consume_power);
}

void statistics::dataset::step() {
    pos = (pos + 1) % PRECISION;
    data[pos].reset();
}

void statistics::dataset::sum(dataset const& d) {
    step();
    size_t n = tick / d.tick;
    for (size_t i = 0; i < n; ++i) {
        data[pos].add(d.data[(d.pos + PRECISION - i) % PRECISION]);
    }
}

bool statistics::dataset::update(uint64_t time) {
    if (time % tick != 0) {
        return false;
    }
    return true;
}

bool statistics::dataset::update(uint64_t time, dataset const& d) {
    if (time % tick != 0) {
        return false;
    }
    sum(d);
    return true;
}

statistics::statistics() {
    constexpr uint16_t UPS = 30;
    constexpr uint64_t time_5s = 5;
    constexpr uint64_t time_1m = 1 * 60;
    constexpr uint64_t time_10m = 10 * 60;
    constexpr uint64_t time_1h = 1 * 60 * 60;
    constexpr uint64_t time_10h = 10 * 60 * 60;
    constexpr uint64_t time_50h = 50 * 60 * 60;
    constexpr uint64_t time_250h = 250 * 60 * 60;
    constexpr uint64_t time_1000h = 1000 * 60 * 60;
    static_assert((time_5s * UPS) % PRECISION == 0);
    static_assert(PRECISION > (time_1m / time_5s));
    _dataset[0].tick = time_5s    * UPS / PRECISION;
    _dataset[1].tick = time_1m    * UPS / PRECISION;
    _dataset[2].tick = time_10m   * UPS / PRECISION;
    _dataset[3].tick = time_1h    * UPS / PRECISION;
    _dataset[4].tick = time_10h   * UPS / PRECISION;
    _dataset[5].tick = time_50h   * UPS / PRECISION;
    _dataset[6].tick = time_250h  * UPS / PRECISION;
    _dataset[7].tick = time_1000h * UPS / PRECISION;
}

statistics::frame& statistics::current() {
    auto& _5s = _dataset[0];
    return _5s.data[_5s.pos];
}

void statistics::update(uint64_t time) {
    if (!_dataset[0].update(time)) {
        return;
    }
    _total.add(current());
    _dataset[0].step();
    for (size_t i = 1; i < _dataset.size(); ++i) {
        if (!_dataset[i].update(time, _dataset[i-1])) {
            return;
        }
    }
}
