#pragma once

#include <optional>
#include <vector>
#include <map>
#include "chest.h"
#include "flatmap.h"

struct world;
struct lua_State;

class techtree_mgr {
public:
    struct ingredient_t {
        uint16_t item;
        uint16_t amount;
    };
    using ingredients_t = std::vector<ingredient_t>;
    using ingredients_opt = std::optional<ingredients_t>;
    using queue_t = std::vector<uint16_t>;

    uint16_t         get_progress(uint16_t techid) const;
    bool             is_researched(uint16_t techid) const;
    bool             research_set(uint16_t techid, uint16_t max, uint16_t val);
    bool             research_set(world& w, uint16_t techid, uint16_t val);
    bool             research_add(uint16_t techid, uint16_t max, uint16_t inc);
    ingredients_opt& get_ingredients(world& w, uint16_t labid, uint16_t techid);
    uint16_t         queue_top() const;
    void             queue_pop();
    void             queue_set(const queue_t& q);
    const queue_t&   queue_get() const;

    flatmap<uint16_t, uint16_t> progress;
    flatset<uint16_t> researched;
    queue_t queue;
    std::map<uint16_t, std::map<uint16_t, ingredients_opt>> cache;
};

inline recipe_items* to_recipe(techtree_mgr::ingredients_opt& opt) {
    return (recipe_items*)opt->data();
}
