#include <lua.hpp>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>
#include "core/chest.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

static bool isFluidId(uint16_t id) {
    return (id & 0x0C00) == 0x0C00;
}

container::slot& chest::array_at(world& w, container::index start, uint8_t offset) {
    if (offset > 0) {
        for (uint8_t i = 0; i < offset-1; ++i) {
            auto& s = w.container.at(start + i);
            assert(!s.eof);
        }
    }
    return w.container.at(start + offset);
}

std::span<container::slot> chest::array_slice(world& w, container::index start, uint8_t offset, uint16_t size) {
    if (offset+size > 0) {
        for (uint8_t i = 0; i < offset+size-1; ++i) {
            auto& s = w.container.at(start + i);
            assert(!s.eof);
        }
    }
    return w.container.slice(start + offset, size);
}

container::index chest::create(world& w, container::slot* data, container::size_type size) {
    auto start = w.container.create_chest(size);
    for (uint8_t i = 0; i < size; ++i) {
        auto& s = w.container.at(start + i);
        s = data[i];
        assert(!s.eof);
    }
    return start;
}

void chest::destroy(world& w, container::index c) {
    w.container.free_array(c, chest::size(w, c));
}

uint16_t chest::get_fluid(world& w, container::index c, uint8_t offset) {
    auto& s = chest::array_at(w, c, offset);
    assert(isFluidId(s.item));
    return s.amount;
}

void chest::set_fluid(world& w, container::index c, uint8_t offset, uint16_t value) {
    auto& s = chest::array_at(w, c, offset);
    assert(isFluidId(s.item));
    s.amount = value;
}

bool chest::pickup(world& w, container::index c, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    return chest::pickup(w, c, ingredients, 0);
}

bool chest::place(world& w, container::index c, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    recipe_items* results = (recipe_items*)pt_results(&recipe);
    //TODO ingredients->n -> uint8_t
    return chest::place(w, c, results, (uint8_t)ingredients->n);
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

bool chest::recover(world& w, container::index c, const recipe_items* r) {
    size_t i = 0;
    for (auto& s: chest::array_slice(w, c, 0, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, container::index c, const uint16_t* r, uint16_t n) {
    for (auto& s: chest::array_slice(w, c, 0, n)) {
        s.limit = *r++;
    }
}

uint16_t chest::size(world& w, container::index c) {
    uint16_t n = 0;
    for (auto index = c;; ++index) {
        auto& s = w.container.at(index);
        n++;
        if (s.eof) {
            break;
        }
    }
    return n;
}

bool chest::pickup_force(world& w, container::index c, uint16_t item, uint16_t amount, bool unlock) {
    for (auto index = c;; ++index) {
        auto& s = w.container.at(index);
        if (s.item == item) {
            if (unlock) {
                if (amount > s.amount) {
                    return false;
                }
                if (amount <= s.lock_item) {
                    s.lock_item -= amount;
                }
                else {
                    s.lock_item = 0;
                }
            }
            else {
                if (amount + s.lock_item > s.amount) {
                    return false;
                }
            }
            s.amount -= amount;
            return true;
        }
        if (s.eof) {
            break;
        }
    }
    return false;
}

bool chest::place_force(world& w, container::index c, uint16_t item, uint16_t amount, bool unlock) {
    for (auto index = c;; ++index) {
        auto& s = w.container.at(index);
        if (s.item == item) {
            if (unlock) {
                if (amount <= s.lock_space) {
                    s.lock_space -= amount;
                }
                else {
                    s.lock_space = 0;
                }
            }
            s.amount += amount;
            return true;
        }
        if (s.eof) {
            break;
        }
    }
    return false;
}

container::slot& chest::getslot(world& w, container::index c, uint8_t offset) {
    return w.container.at(c + offset);
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    size_t sz = 0;
    container::slot* s = (container::slot*)luaL_checklstring(L, 2, &sz);
    size_t n = sz / sizeof(container::slot);
    if (n < 0 || n > (uint16_t) -1 || sz % sizeof(container::slot) != 0) {
        return luaL_error(L, "size out of range.");
    }
    auto index = chest::create(w, s, sz % sizeof(container::slot));
    lua_pushinteger(L, index);
    return 1;
}

static int
ldestroy(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    chest::destroy(w, container::index::from(index));
    return 0;
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    auto& r = chest::getslot(w, container::index::from(index), offset);
    lua_createtable(L, 0, 7);
    switch (r.type) {
    case container::slot::slot_type::red:   lua_pushstring(L, "red"); break;
    case container::slot::slot_type::blue:  lua_pushstring(L, "blue"); break;
    case container::slot::slot_type::green: lua_pushstring(L, "green"); break;
    default:                               lua_pushstring(L, "unknown"); break;
    }
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, r.item);
    lua_setfield(L, -2, "item");
    lua_pushinteger(L, r.amount);
    lua_setfield(L, -2, "amount");
    lua_pushinteger(L, r.limit);
    lua_setfield(L, -2, "limit");
    lua_pushinteger(L, r.lock_item);
    lua_setfield(L, -2, "lock_item");
    lua_pushinteger(L, r.lock_space);
    lua_setfield(L, -2, "lock_space");
    return 1;
}
static int
lset(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    auto& r = chest::getslot(w, container::index::from(index), offset);
    if (LUA_TNIL != lua_getfield(L, 4, "type")) {
        static const char *const opts[] = {"red", "blue", "green", NULL};
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
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t amount = (uint16_t)luaL_checkinteger(L, 4);
    bool ok = chest::pickup_force(w, container::index::from(index), item, amount, false);
    lua_pushboolean(L, ok);
    return 1;
}

static int
lplace(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t amount = (uint16_t)luaL_checkinteger(L, 4);
    chest::place_force(w, container::index::from(index), item, amount, false);
    return 0;
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
