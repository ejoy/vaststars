#include <lua.hpp>
#include "core/world.h"
#include "util/prototype.h"

template <typename Key, typename Mapped>
void flatmap_increase(flatmap<Key, Mapped>& m, Key const& key, Mapped mapped) {
    if (auto iter = m.find(key); iter) {
        *iter += mapped;
        return;
    }
    m.insert_or_assign(key, std::move(mapped));
}

template <typename Key, typename Mapped>
void flatmap_stat(flatmap<Key, Mapped>& m, recipe_items& r) {
    for (size_t i = 0; i < r.n; ++i) {
        flatmap_increase<Key, Mapped>(m, r.items[i].item, r.items[i].amount);
    }
}

void statistics::finish_recipe(world& w, uint16_t id) {
    auto& ingredients = *(recipe_items*)prototype::get<"ingredients">(w, id).data();
    auto& results = *(recipe_items*)prototype::get<"results">(w, id).data();
    flatmap_stat(consumption, ingredients);
    flatmap_stat(production, results);
}
