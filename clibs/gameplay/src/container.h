#pragma once

#include <stdint.h>
#include <vector>

struct world;

struct container {
    struct item {
        uint16_t item;
        uint16_t amount;
    };
    using item_array = std::vector<item>;

    virtual item     at(uint16_t index) = 0;
    virtual uint32_t inserter_need() = 0;
    virtual item     inserter_pickup_any(world& w, uint16_t max) = 0;
    virtual uint16_t inserter_pickup(world& w, uint16_t item, uint16_t max) = 0;
    virtual bool     inserter_place(world& w, uint16_t item, uint16_t amount) = 0;
    item             inserter_pickup(world& w, container& need, uint16_t max);
};

struct chest_container: public container {
    using slot = item;
    chest_container(uint16_t size);
    std::vector<slot> slots;
    uint16_t          used;
    uint16_t          size;

    size_t   find(uint16_t item);
    void     sort(size_t index, uint16_t newvalue);
    bool     resize(world& w, uint16_t item, uint16_t value, uint16_t newvalue);
    item     at(uint16_t index) override;
    uint32_t inserter_need() override;
    item     inserter_pickup_any(world& w, uint16_t max) override;
    uint16_t inserter_pickup(world& w, uint16_t item, uint16_t max) override;
    bool     inserter_place(world& w, uint16_t item, uint16_t amount) override;
};

struct recipe_container: public container {
    struct slot: public item {
        uint16_t limit;
    };
    enum class slot_type {
        in,
        out
    };
    std::vector<slot> inslots;
    std::vector<slot> outslots;
    recipe_container(item_array in, item_array out);
    bool     recipe_pickup(world& w, item const* items);
    bool     recipe_place(world& w, item const* items);
    bool     recipe_get(slot_type type, uint16_t index, uint16_t& value);
    bool     recipe_set(slot_type type, uint16_t index, uint16_t value);
    item     at(uint16_t index) override;
    uint32_t inserter_need() override;
    item     inserter_pickup_any(world& w, uint16_t max) override;
    uint16_t inserter_pickup(world& w, uint16_t item, uint16_t max) override;
    bool     inserter_place(world& w, uint16_t item, uint16_t amount) override;
};

struct container_mgr {
    std::vector<chest_container>  chest;
    std::vector<recipe_container> recipe;
};
