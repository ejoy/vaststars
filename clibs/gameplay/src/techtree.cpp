#include "techtree.h"
extern "C" {
#include "prototype.h"
}
#include "world.h"
#include <assert.h>

uint16_t techtree_mgr::get_progress(uint16_t techid) const {
    auto iter = progress.find(techid);
    if (iter == progress.end()) {
        return 0;
    }
    return iter->second;
}

bool techtree_mgr::is_researched(uint16_t techid) const {
    return researched.contains(techid);
}

bool techtree_mgr::research(uint16_t techid, uint16_t max, uint16_t inc) {
    assert(inc != 0);
    bool finish = false;
    auto iter = progress.find(techid);
    if (iter == progress.end()) {
        if (inc >= max) {
            inc = max;
            finish = true;
        }
        progress.emplace(techid, inc);
    }
    else {
        uint32_t value = (uint32_t)iter->second + inc;
        if (value >= max) {
            value = max;
            finish = true;
        }
        iter->second = value;
    }
    if (finish) {
        cache.erase(techid);
    }
    return finish;
}

struct lab_inputs {
    uint16_t n;
    uint16_t items[1];
};

static uint16_t recipeFind(recipe_items& r, uint16_t item) {
    for (uint16_t i = 0; i < r.n; ++i) {
        if (r.items[i].item == item) {
            return r.items[i].amount;
        }
    }
    return 0;
}

recipe_items& techtree_mgr::get_ingredients(world& w, uint16_t labid, uint16_t techid) {
    auto& techcache = cache[techid];
    auto iter = techcache.find(labid);
    if (iter != techcache.end()) {
        return iter->second;
    }
    recipe_items r;
    auto lab = w.prototype(labid);
    auto tech = w.prototype(techid);
    auto& inputs = *(lab_inputs*)pt_inputs(&lab);
    auto& ingredients = *(recipe_items*)pt_ingredients(&tech);

    r.n = inputs.n;
    for (uint16_t i = 0; i < r.n; ++i) {
        r.items[i].item = inputs.items[i];
        r.items[i].amount = recipeFind(ingredients, inputs.items[i]);
    }

    auto res = techcache.emplace(labid, r);
    return res.first->second;
}

uint16_t techtree_mgr::queue_top() const {
    if (queue.empty()) {
        return 0;
    }
    return queue.back();
}

void techtree_mgr::queue_pop() {
    if (!queue.empty()) {
        queue.pop_back();
    }
}

void techtree_mgr::queue_set(const std::vector<uint16_t>& q) {
    queue = q;
}

const std::vector<uint16_t>& techtree_mgr::queue_get() const {
    return queue;
}
