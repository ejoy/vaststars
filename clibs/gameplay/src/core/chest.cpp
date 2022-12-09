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

static void list_remove(world& w, chest::chest_data& c, container::index index) {
    if (c.asize == 0 && c.index == index) {
        c.index = w.container.at(index).next;
        return;
    }
    auto head = c.index;
    if (c.asize > 0) {
        head.slot += (c.asize-1);
    }
    while (head != container::kInvalidIndex) {
        auto& slot = w.container.at(index);
        if (slot.next == index) {
            slot.next = w.container.at(index).next;
            w.container.free_slot(index);
            break;
        }
        head = slot.next;
    }
}

static void list_append(world& w, container::index index, container::index v) {
    for (auto i = index;;) {
        auto& s = w.container.at(i);
        if (s.next == container::kInvalidIndex) {
            s.next = v;
            break;
        }
        i = s.next;
    }
}

container::index chest::create(world& w, uint16_t endpoint, container_slot* data, container::size_type asize, container::size_type lsize) {
    if (asize == 0 && lsize == 0) {
        return {0, 0};
    }
    auto start = w.container.create_chest(asize, lsize);
    for (auto i = start; i != container::kInvalidIndex;) {
        auto& s = w.container.at(i);
        (container_slot&)s = *data++;
        if (endpoint != 0xffff) {
            trading_flush(w, {endpoint}, s);
        }
        i = s.next;
    }
    return start;
}

void chest::add(world& w, container::index index, uint16_t endpoint, container_slot* data, container::size_type lsize) {
    if (lsize == 0) {
        return;
    }
    auto start = w.container.alloc_slot(lsize);
    list_append(w, index, start);
    for (auto i = start; i != container::kInvalidIndex;) {
        auto& s = w.container.at(i);
        (container_slot&)s = *data++;
        if (endpoint != 0xffff) {
            trading_flush(w, {endpoint}, s);
        }
        i = s.next;
    }
}

chest::chest_data& chest::query(ecs::chest& c) {
    static_assert(sizeof(chest::chest_data::index) == sizeof(ecs::chest::index));
    static_assert(sizeof(chest::chest_data::asize) == sizeof(ecs::chest::asize));
    return (chest_data&)c;
}

uint16_t chest::get_fluid(world& w, chest_data& c, uint8_t offset) {
    assert(offset < c.asize);
    auto& s = w.container.at(c.index + offset);
    assert(isFluidId(s.item));
    return s.amount;
}

void chest::set_fluid(world& w, chest_data& c, uint8_t offset, uint16_t value) {
    assert(offset < c.asize);
    auto& s = w.container.at(c.index + offset);
    assert(isFluidId(s.item));
    s.amount = value;
}

bool chest::pickup(world& w, chest_data& c, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    return chest::pickup(w, c, endpoint, ingredients, 0);
}

bool chest::place(world& w, chest_data& c, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    recipe_items* results = (recipe_items*)pt_results(&recipe);
    //TODO ingredients->n -> uint8_t
    return chest::place(w, c, endpoint, results, (uint8_t)ingredients->n);
}

bool chest::pickup(world& w, chest_data& c, uint16_t endpoint, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= c.asize);
    size_t i = 0;
    for (auto& s: w.container.slice(c.index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    i = 0;
    for (auto& s: w.container.slice(c.index + offset, r->n)) {
        auto& t = r->items[i++];
        s.amount -= t.amount;
    }
    chest::flush(w, c.index, endpoint);
    return true;
}

bool chest::place(world& w, chest_data& c, uint16_t endpoint, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= c.asize);
    size_t i = 0;
    for (auto& s: w.container.slice(c.index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        if (s.amount + t.amount > s.limit) {
            return false;
        }
    }
    i = 0;
    for (auto& s: w.container.slice(c.index + offset, r->n)) {
        auto& t = r->items[i++];
        s.amount += t.amount;
    }
    chest::flush(w, c.index, endpoint);
    return true;
}

bool chest::recover(world& w, chest_data& c, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= c.asize);
    size_t i = 0;
    for (auto& s: w.container.slice(c.index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, chest_data& c, uint16_t endpoint, const uint16_t* r) {
    for (auto& s: w.container.slice(c.index, c.asize)) {
        s.limit = *r++;
    }
    chest::flush(w, c.index, endpoint);
}

size_t chest::size(chest_data& c) {
    return c.asize;
}

void chest::flush(world& w, container::index index, uint16_t endpoint) {
    if (endpoint == 0xffff) {
        return;
    }
    while (index != container::kInvalidIndex) {
        auto& s = w.container.at(index);
        trading_flush(w, {endpoint}, s);
        index = s.next;
    }
}

void chest::rollback(world& w, container::index index, uint16_t endpoint) {
    if (endpoint == 0xffff) {
        return;
    }
    while (index != container::kInvalidIndex) {
        auto& s = w.container.at(index);
        trading_rollback(w, {endpoint}, s);
        index = s.next;
    }
}

bool chest::pickup_force(world& w, chest_data& c, uint16_t item, uint16_t amount) {
    for (auto index = c.index; index != container::kInvalidIndex;) {
        auto& s = w.container.at(index);
        if (s.item == item) {
            if (amount > s.amount) {
                return false;
            }
            s.amount -= amount;
            if (amount <= s.lock_item) {
                s.lock_item -= amount;
            }
            else {
                s.lock_item = 0;
            }
            if (s.amount == 0 && s.lock_item == 0 && s.lock_space == 0) {
                if (index.page != c.index.page || (index.slot < c.index.slot) || (index.slot >= c.index.slot + c.asize)) {
                    list_remove(w, c, index);
                }
            }
            return true;
        }
        index = s.next;
    }
    return false;
}

void chest::place_force(world& w, chest_data& c, uint16_t item, uint16_t amount) {
    for (auto index = c.index; index != container::kInvalidIndex;) {
        auto& s = w.container.at(index);
        if (s.item == item) {
            s.amount += amount;
            if (amount <= s.lock_space) {
                s.lock_space -= amount;
            }
            else {
                s.lock_space = 0;
            }
            return;
        }
        index = s.next;
    }

    auto idx = w.container.alloc_slot(1);
    auto& newslot = w.container.at(idx);
    newslot.type = container_slot::slot_type::red;
    newslot.unused = 0;
    newslot.item = item;
    newslot.amount = amount;
    newslot.limit = 0;
    newslot.lock_item = 0;
    newslot.lock_space = 0;
    newslot.next = container::kInvalidIndex;
    list_append(w, c.index, idx);
}

const container_slot* chest::getslot(world& w, container::index index, uint8_t offset) {
    for (uint8_t i = 0; i < offset; ++i) {
        index = w.container.at(index).next;
        if (index == container::kInvalidIndex) {
            return nullptr;
        }
    }
    auto& s = w.container.at(index);
    return &s;
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 2);
    size_t sz = 0;
    container_slot* s = (container_slot*)luaL_checklstring(L, 3, &sz);
    size_t n = sz / sizeof(container_slot);
    if (n < 0 || n > (uint16_t) -1 || sz % sizeof(container_slot) != 0) {
        return luaL_error(L, "size out of range.");
    }
    uint16_t asize = (uint16_t)luaL_checkinteger(L, 4);
    if (asize > n) {
        return luaL_error(L, "asize out of range.");
    }
    auto index = chest::create(w, endpoint, s, asize, (uint16_t)n-asize);
    lua_pushinteger(L, index);
    return 1;
}

static int
ladd(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 3);
    size_t sz = 0;
    container_slot* s = (container_slot*)luaL_checklstring(L, 4, &sz);
    size_t n = sz / sizeof(container_slot);
    if (n < 0 || n > (uint16_t) -1 || sz % sizeof(container_slot) != 0) {
        return luaL_error(L, "size out of range.");
    }
    chest::add(w, container::index::from(index), endpoint, s, (uint16_t)n);
    return 0;
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    auto r = chest::getslot(w, container::index::from(index), offset);
    if (!r) {
        return 0;
    }
    lua_createtable(L, 0, 7);
    switch (r->type) {
    case container_slot::slot_type::red:
        lua_pushstring(L, "red");
        break;
    case container_slot::slot_type::blue:
        lua_pushstring(L, "blue");
        break;
    case container_slot::slot_type::green:
        lua_pushstring(L, "green");
        break;
    default:
        lua_pushstring(L, "unknown");
        break;
    }
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, r->item);
    lua_setfield(L, -2, "item");
    lua_pushinteger(L, r->amount);
    lua_setfield(L, -2, "amount");
    lua_pushinteger(L, r->limit);
    lua_setfield(L, -2, "limit");
    lua_pushinteger(L, r->lock_item);
    lua_setfield(L, -2, "lock_item");
    lua_pushinteger(L, r->lock_space);
    lua_setfield(L, -2, "lock_space");
    return 1;
}

static int
lrollback(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 3);
    chest::rollback(w, container::index::from(index), endpoint);
    return 0;
}

extern "C" int
luaopen_vaststars_chest_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "create", lcreate },
        { "add", ladd },
        { "get", lget },
        { "rollback", lrollback },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
