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

struct container {
    struct item {
        uint16_t item;
        uint16_t amount;
    };
    struct slot: public item {
        uint16_t limit;
    };
    using item_array = std::vector<item>;

    virtual int      type() const = 0;
    virtual slot     get(uint16_t index) = 0;
    virtual uint16_t pickup(lua_State* L, world& w, uint16_t item, uint16_t max) = 0;
    virtual bool     place(lua_State* L, world& w, uint16_t item, uint16_t amount) = 0;
};

struct chest_container: public container {
    chest_container();
    chest_container(uint16_t size);
    std::vector<item> slots;
    uint16_t          used;
    uint16_t          size;

    size_t   find(uint16_t item);
    void     sort(size_t index, uint16_t newvalue);
    bool     resize(lua_State* L, world& w);
    bool     resize(lua_State* L, world& w, uint16_t item, uint16_t value, uint16_t newvalue);
    slot     get(uint16_t index) override;
    uint16_t pickup(lua_State* L, world& w, uint16_t item, uint16_t max) override;
    bool     place(lua_State* L, world& w, uint16_t item, uint16_t amount) override;
    int      type() const override { return 0; }
};

struct recipe_container: public container {
    enum class slot_type {
        in,
        out
    };
    std::vector<slot> inslots;
    std::vector<slot> outslots;
    recipe_container();
    recipe_container(item_array in, item_array out);
    bool     recipe_pickup(world& w, const recipe_items* r);
    bool     recipe_recover(world& w, const recipe_items* r);
    void     recipe_limit(world& w, const uint16_t* r);
    bool     recipe_place(world& w, const recipe_items* r);
    bool     recipe_get(slot_type type, uint16_t index, uint16_t& value);
    bool     recipe_set(slot_type type, uint16_t index, uint16_t value);
    slot     get(uint16_t index) override;
    uint16_t pickup(lua_State* L, world& w, uint16_t item, uint16_t max) override;
    bool     place(lua_State* L, world& w, uint16_t item, uint16_t amount) override;
    int      type() const override { return 1; }
};

struct container_mgr {
    std::vector<chest_container>  chest;
    std::vector<recipe_container> recipe;
};
