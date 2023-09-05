#include <lua.hpp>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>
#include "core/chest.h"
#include "core/world.h"
#include "core/backpack.h"
#include "util/prototype.h"

container::slot& chest::array_at(world& w, container::index start, uint8_t offset) {
#if !defined(NDEBUG)
    assert(start != container::kInvalidIndex);
    auto& s = w.container.at(start);
    assert(s.eof - start.slot >= offset);
#endif
    return w.container.at(start + offset);
}

std::span<container::slot> chest::array_slice(world& w, container::index start, uint8_t offset, uint16_t size) {
#if !defined(NDEBUG)
    if (size > 0) {
        assert(start != container::kInvalidIndex);
        auto& s = chest::array_at(w, start, offset);
        assert(s.eof - start.slot + 1 >= size);
    }
#endif
    return w.container.slice(start + offset, size);
}

std::span<container::slot> chest::array_slice(world& w, container::index start) {
    if (start == container::kInvalidIndex) {
        return {};
    }
    auto& s = w.container.at(start);
    return w.container.slice(start, s.eof - start.slot + 1);
}

container::index chest::create(world& w, container::slot* data, container::size_type size) {
    auto start = w.container.create_chest(size);
    for (uint8_t i = 0; i < size; ++i) {
        auto& s = w.container.at(start + i);
        auto eof = s.eof;
        s = data[i];
        s.eof = eof;
    }
    return start;
}

void chest::destroy(world& w, container::index c, bool recycle) {
    if (recycle) {
        for (auto& s: chest::array_slice(w, c)) {
            if (s.item != 0 && s.amount != 0) {
                backpack_place(w, s.item, s.amount);
            }
        }
    }
    w.container.free_array(c, chest::size(w, c));
}

uint16_t chest::get_fluid(world& w, container::index c, uint8_t offset) {
    auto& s = chest::array_at(w, c, offset);
    assert(s.type == container::slot::slot_type::none);
    return s.amount;
}

void chest::set_fluid(world& w, container::index c, uint8_t offset, uint16_t value) {
    auto& s = chest::array_at(w, c, offset);
    assert(s.type == container::slot::slot_type::none);
    s.amount = value;
}

bool chest::pickup(world& w, container::index c, uint16_t recipe) {
    auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, recipe);
    return chest::pickup(w, c, &ingredients, 0);
}

bool chest::place(world& w, container::index c, uint16_t recipe) {
    auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, recipe);
    auto const& results = prototype::get<"results", recipe_items>(w, recipe);
    //TODO ingredients.n -> uint8_t
    return chest::place(w, c, &results, (uint8_t)ingredients.n);
}

bool chest::pickup(world& w, container::index c, const recipe_items* r, uint8_t offset) {
    size_t i = 0;
    for (auto& s: chest::array_slice(w, c, offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    i = 0;
    for (auto& s: chest::array_slice(w, c, offset, r->n)) {
        auto& t = r->items[i++];
        s.amount -= t.amount;
    }
    return true;
}

bool chest::place(world& w, container::index c, const recipe_items* r, uint8_t offset) {
    size_t i = 0;
    for (auto& s: chest::array_slice(w, c, offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        if (s.amount + t.amount > s.limit) {
            return false;
        }
    }
    i = 0;
    for (auto& s: chest::array_slice(w, c, offset, r->n)) {
        auto& t = r->items[i++];
        s.amount += t.amount;
    }
    return true;
}

uint16_t chest::size(world& w, container::index c) {
    assert(c != container::kInvalidIndex);
    auto& s = w.container.at(c);
    return s.eof - c.slot + 1;
}

container::slot* chest::find_item(world& w, container::index c, uint16_t item) {
    for (auto& s: chest::array_slice(w, c)) {
        if (s.item == item) {
            return &s;
        }
    }
    return nullptr;
}

static int
lcreate(lua_State* L) {
    auto& w = getworld(L);
    size_t sz = 0;
    container::slot* s = (container::slot*)luaL_checklstring(L, 2, &sz);
    size_t n = sz / sizeof(container::slot);
    if (n < 0 || n > (uint16_t) -1 || sz % sizeof(container::slot) != 0) {
        return luaL_error(L, "size out of range.");
    }
    auto index = chest::create(w, s, (container::size_type)n);
    lua_pushinteger(L, index);
    return 1;
}

static int
ldestroy(lua_State* L) {
    auto& w = getworld(L);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    bool recycle = lua_toboolean(L, 3);
    chest::destroy(w, container::index::from(index), recycle);
    return 0;
}

static int
lget(lua_State* L) {
    auto& w = getworld(L);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    auto c = container::index::from(index);
    if (c == container::kInvalidIndex) {
        return 0;
    }
    auto& start = w.container.at(c);
    if (start.eof - c.slot < offset) {
        return 0;
    }
    auto& s = chest::array_at(w, c, offset);
    lua_createtable(L, 0, 7);
    switch (s.type) {
    case container::slot::slot_type::none:    lua_pushstring(L, "none"); break;
    case container::slot::slot_type::supply:  lua_pushstring(L, "supply"); break;
    case container::slot::slot_type::demand:  lua_pushstring(L, "demand"); break;
    case container::slot::slot_type::transit: lua_pushstring(L, "transit"); break;
    default:                                  lua_pushstring(L, "unknown"); break;
    }
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, s.item);
    lua_setfield(L, -2, "item");
    lua_pushinteger(L, s.amount);
    lua_setfield(L, -2, "amount");
    lua_pushinteger(L, s.limit);
    lua_setfield(L, -2, "limit");
    lua_pushinteger(L, s.lock_item);
    lua_setfield(L, -2, "lock_item");
    lua_pushinteger(L, s.lock_space);
    lua_setfield(L, -2, "lock_space");
    lua_pushinteger(L, s.eof - c.slot);
    lua_setfield(L, -2, "eof");
    return 1;
}

static int
lset(lua_State* L) {
    auto& w = getworld(L);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    auto c = container::index::from(index);
    if (c == container::kInvalidIndex) {
        return 0;
    }
    auto& start = w.container.at(c);
    if (start.eof - c.slot < offset) {
        return 0;
    }
    auto& r = chest::array_at(w, c, offset);
    if (LUA_TNIL != lua_getfield(L, 4, "type")) {
        static const char *const opts[] = {"none", "supply", "demand", NULL};
        r.type = (container::slot::slot_type)luaL_checkoption(L, -1, NULL, opts);
    }
    lua_pop(L, 1);
    if (LUA_TNIL != lua_getfield(L, 4, "item")) {
        r.item = (uint16_t)luaL_checkinteger(L, -1);
    }
    lua_pop(L, 1);
    if (LUA_TNIL != lua_getfield(L, 4, "amount")) {
        r.amount = (uint16_t)luaL_checkinteger(L, -1);
    }
    lua_pop(L, 1);
    if (LUA_TNIL != lua_getfield(L, 4, "limit")) {
        r.limit = (uint16_t)luaL_checkinteger(L, -1);
    }
    lua_pop(L, 1);
    if (LUA_TNIL != lua_getfield(L, 4, "lock_item")) {
        r.lock_item = (uint16_t)luaL_checkinteger(L, -1);
    }
    lua_pop(L, 1);
    if (LUA_TNIL != lua_getfield(L, 4, "lock_space")) {
        r.lock_space = (uint16_t)luaL_checkinteger(L, -1);
    }
    lua_pop(L, 1);
    return 0;
}

static int
lpickup(lua_State* L) {
    auto& w = getworld(L);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    uint16_t n = (uint16_t)(luaL_checkinteger(L, 4));
    auto c = container::index::from(index);
    if (c == container::kInvalidIndex) {
        return 0;
    }
    auto& start = w.container.at(c);
    if (start.eof - c.slot < offset) {
        return 0;
    }
    auto& s = chest::array_at(w, c, offset);
    if (s.type == container::slot::slot_type::none || s.item == 0) {
        return 0;
    }
    if (n > s.amount)  {
        n = s.amount;
        s.amount = 0;
    }
    else {
        s.amount = s.amount - n;
    }
    if (s.amount < s.lock_item) {
        w.dirty |= kDirtyChest;
    }
    lua_pushinteger(L, n);
    return 1;
}

static int
lplace(lua_State* L) {
    auto& w = getworld(L);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    uint16_t n = (uint16_t)(luaL_checkinteger(L, 4));
    auto c = container::index::from(index);
    if (c == container::kInvalidIndex) {
        return 0;
    }
    auto& start = w.container.at(c);
    if (start.eof - c.slot < offset) {
        return 0;
    }
    auto& s = chest::array_at(w, c, offset);
    if (s.type == container::slot::slot_type::none || s.item == 0) {
        return 0;
    }
    if (s.amount + n > s.limit)  {
        n = s.limit - s.amount;
        s.amount = s.limit;
    }
    else {
        s.amount = s.amount + n;
    }
    if (s.lock_space + s.amount > s.limit) {
        w.dirty |= kDirtyChest;
    }
    lua_pushinteger(L, n);
    return 1;
}

extern "C" int
luaopen_vaststars_chest_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "create", lcreate },
        { "destroy", ldestroy },
        { "get", lget },
        { "set", lset },
        { "pickup", lpickup },
        { "place", lplace },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
