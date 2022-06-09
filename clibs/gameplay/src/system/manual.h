#pragma once

#include "util/flatmap.h"
#include <vector>

struct manual_container : public flatmap<uint16_t, uint16_t> {
    using mybase = flatmap<uint16_t, uint16_t>;
    bool pickup(recipe_items& r);
    bool place(recipe_items& r);

    uint16_t pickup(uint16_t item, uint16_t amount);
    void     place(uint16_t item, uint16_t amount);
};

struct manual_crafting {
    enum class type : uint8_t {
        craft,
        finish,
    };
    struct todo {
        type type;
        uint8_t count;
        uint16_t id;
    };
    std::vector<todo> todos;
    manual_container  container;

    void next(ecs::manual& m);
    bool rebuild(lua_State* L, world& w, int id);
};
