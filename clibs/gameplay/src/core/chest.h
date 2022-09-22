#pragma once

#include <stdint.h>
#include <vector>

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
    enum class type: uint8_t {
        none,
        red,
        blue,
    };
    struct slot {
        enum class type: uint16_t {
            limit,
            empty,
        };
        type     type;
        uint16_t item;
        uint16_t amount;
        uint16_t limit;
    };

    chest(type type_, chest::slot* data, size_t size);
    std::vector<slot> slots;
    type type_;

    bool     get(uint16_t index, uint16_t& value);
    bool     set(uint16_t index, uint16_t value);
    slot*    getslot(uint16_t index);
    bool     pickup(const recipe_items* r);
    bool     place(const recipe_items* r);
    bool     recover(const recipe_items* r);
    void     limit(const uint16_t* r);
    size_t   find(uint16_t item);
    uint16_t pickup(uint16_t item, uint16_t max);
    uint16_t place(uint16_t item, uint16_t amount, uint16_t limit);
};
