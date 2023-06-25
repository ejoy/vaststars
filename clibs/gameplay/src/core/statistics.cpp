#include <lua.hpp>
#include "core/world.h"
#include "util/prototype.h"

template <typename Key, typename Mapped>
void flatmap_increase(flatmap<Key, Mapped>& m, Key const& key, Mapped mapped) {
    auto [found, slot] = m.find_or_insert(key);
    if (found) {
        *slot = mapped;
    }
    else {
        *slot += mapped;
    }
}

template <typename Key, typename Mapped>
void flatmap_stat(flatmap<Key, Mapped>& m, recipe_items const& r) {
    for (size_t i = 0; i < r.n; ++i) {
        flatmap_increase<Key, Mapped>(m, r.items[i].item, r.items[i].amount);
    }
}

void statistics::finish_recipe(world& w, uint16_t id) {
    auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, id);
    auto const& results = prototype::get<"results", recipe_items>(w, id);
    flatmap_stat(consumption, ingredients);
    flatmap_stat(production, results);
}
