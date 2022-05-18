#pragma once

#include <vector>
#include <map>
#include <set>
#include "container.h"

struct world;

class techtree_mgr {
public:
    uint16_t      get_progress(uint16_t techid) const;
    bool          is_researched(uint16_t techid) const;
    bool          research(uint16_t techid, uint16_t max, uint16_t inc);
    recipe_items& get_ingredients(world& w, uint16_t labid, uint16_t techid);
    uint16_t      queue_top() const;
    void          queue_pop();
    void          queue_set(const std::vector<uint16_t>& q);
    const std::vector<uint16_t>& queue_get() const;

private:
    std::map<uint16_t, uint16_t> progress;
    std::set<uint16_t> researched;
    std::vector<uint16_t> queue;
    std::map<uint16_t, std::map<uint16_t, recipe_items>> cache;
};
