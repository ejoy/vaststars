#pragma once

#include <stdint.h>
#include <vector>
#include <util/flatmap.h>
extern "C" {
#include "util/prototype.h"
}

struct world;
struct lua_State;

struct recipe_items {
    uint16_t n;
    uint16_t unused = 0;
    struct {
        uint16_t item;
        uint16_t amount;
    } items[1];
};

struct chest {
    struct slot {
        enum class type: uint8_t {
            red = 0,
            blue,
            green,
        };
        enum class unit: uint8_t {
            limit = 0,
            empty,
        };
        type     type;
        unit     unit;
        uint16_t item;
        uint16_t amount;
        uint16_t limit;
        uint16_t lock_item;
        uint16_t lock_space;
    };

    chest(chest::slot* data, size_t size);
    uint16_t get_fluid(uint16_t index);
    void     set_fluid(uint16_t index, uint16_t value);
    bool     pickup(world& w, uint16_t endpoint, prototype_context& recipe);
    bool     place(world& w, uint16_t endpoint, prototype_context& recipe);
    bool     pickup(world& w, uint16_t endpoint, const recipe_items* r, uint16_t offset = 0);
    bool     place(world& w, uint16_t endpoint, const recipe_items* r, uint16_t offset = 0);
    bool     recover(world& w, const recipe_items* r, uint16_t offset = 0);
    void     limit(world& w, uint16_t endpoint, const uint16_t* r);
    size_t   size() const;
    const slot* getslot(uint16_t index) const;
    void     flush(world& w, uint16_t endpoint);

    void pickup_force(world& w, uint16_t item, uint16_t max);
    void place_force(world& w, uint16_t item, uint16_t amount);

public:
    std::vector<slot> slots;
};
