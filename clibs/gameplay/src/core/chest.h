#pragma once

#include <stdint.h>
#include <vector>
#include <util/flatmap.h>

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
        uint16_t lock;
    };

    chest(uint16_t endpoint, type type_, chest::slot* data, size_t size);
    uint16_t get_fluid(uint16_t index);
    void     set_fluid(uint16_t index, uint16_t value);
    bool     pickup(world& w, const recipe_items* r);
    bool     place(world& w, const recipe_items* r);
    bool     recover(world& w, const recipe_items* r);
    void     limit(world& w, const uint16_t* r);
    size_t   size() const;
    const slot* getslot(uint16_t index) const;
    uint16_t pickup(world& w, uint16_t item, uint16_t max);
    uint16_t place(world& w, uint16_t item, uint16_t amount, uint16_t limit);
    bool     pickup(world& w, flatmap<uint16_t, uint16_t>& items);
    void     set_endpoint(uint16_t endpoint);

    void pickup_force(world& w, uint16_t item, uint16_t max);
    void place_force(world& w, uint16_t item, uint16_t amount);

public:
    std::vector<slot> slots;
    uint16_t endpoint;
    type type_;
};
