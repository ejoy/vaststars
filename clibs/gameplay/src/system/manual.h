#pragma once

#include "util/component.h"
#include "util/flatmap.h"
#include <vector>

struct manual_container : public flatmap<uint16_t, uint16_t> {
    using mybase = flatmap<uint16_t, uint16_t>;
    bool pickup(recipe_items& r);
    void place(recipe_items& r);

    uint16_t pickup(uint16_t item, uint16_t amount);
    void     place(uint16_t item, uint16_t amount);
};

struct manual_crafting {
    enum class type : uint16_t {
        crafting,
        finish,
        separator,
    };
    struct todo {
        type type;
        uint16_t id;
    };
    std::vector<todo> todos;
    manual_container  container;

    void next();
    void sync(ecs::manual& m);
    bool rebuild(lua_State* L, world& w, ecs::chest& c);
};
