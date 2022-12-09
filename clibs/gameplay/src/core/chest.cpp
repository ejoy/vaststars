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

chest::chest_data chest::create(world& w, container_slot* data, container::size_type asize, container::size_type lsize) {
    if (asize == 0 && lsize == 0) {
        return {{0,0},0};
    }
    auto start = w.container.create_chest(asize, lsize);
    for (auto& slot: w.container.slice(start, asize)) {
        (container_slot&)slot = *data++;
    }
    chest::chest_data c { start, asize };
    auto index = chest::list_head(w, c);
    for (container::size_type i = 0; i < lsize; ++i) {
        auto& slot = w.container.at(index);
        (container_slot&)slot = *data++;
        index = slot.next;
    }
    return c;
}

chest::chest_data& chest::query(ecs::chest& c) {
    static_assert(sizeof(chest::chest_data::index) == sizeof(ecs::chest::index));
    static_assert(sizeof(chest::chest_data::asize) == sizeof(ecs::chest::asize));
    return (chest_data&)c;
}

container::index chest::list_head(world& w, chest_data& c) {
    if (c.asize == 0) {
        return c.index;
    }
    auto index = c.index;
    index.slot += (c.asize-1);
    return w.container.at(index).next;
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
    chest::flush(w, c, endpoint);
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
    chest::flush(w, c, endpoint);
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
    chest::flush(w, c, endpoint);
}

size_t chest::size(chest_data& c) {
    return c.asize;
}

void chest::flush(world& w, chest_data& c, uint16_t endpoint) {
    if (endpoint == 0xffff) {
        return;
    }
    auto index = c.index;
    while (index != container::kInvalidIndex) {
        auto& s = w.container.at(index);
        trading_flush(w, {endpoint}, s);
        index = s.next;
    }
}

void chest::rollback(world& w, chest_data& c, uint16_t endpoint) {
    if (endpoint == 0xffff) {
        return;
    }
    auto index = c.index;
    while (index != container::kInvalidIndex) {
        auto& s = w.container.at(index);
        trading_rollback(w, {endpoint}, s);
        index = s.next;
    }
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

bool chest::pickup_force(world& w, chest_data& c, uint16_t item, uint16_t amount) {
    auto index = c.index;
    while (index != container::kInvalidIndex) {
        auto& s = w.container.at(index);
        if (s.item == item) {
            if (s.type == container_slot::slot_type::blue) {
                return false;
            }
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

    auto idx = w.container.alloc_slot();
    auto& newslot = w.container.at(idx);
    newslot.type = container_slot::slot_type::red;
    newslot.xxxx = 0;
    newslot.item = item;
    newslot.amount = amount;
    newslot.limit = 0;
    newslot.lock_item = 0;
    newslot.lock_space = 0;
    newslot.next = container::kInvalidIndex;
    for (auto index = c.index;;) {
        auto& s = w.container.at(index);
        if (s.next == container::kInvalidIndex) {
            s.next = idx;
            break;
        }
        index = s.next;
    }
}

const container_slot* chest::getslot(world& w, chest_data& c, uint8_t offset) {
    if (offset >= c.asize) {
        auto index = chest::list_head(w, c);
        for (uint8_t i = 0; i < offset - c.asize; ++i) {
            if (index == container::kInvalidIndex) {
                return nullptr;
            }
            index = w.container.at(index).next;
        }
        if (index == container::kInvalidIndex) {
            return nullptr;
        }
        auto& s = w.container.at(index);
        return &s;
    }
    auto& s = w.container.at(c.index + offset);
    return &s;
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t asize = (uint16_t)luaL_checkinteger(L, 2);
    size_t sz = 0;
    container_slot* s = (container_slot*)luaL_checklstring(L, 3, &sz);
    size_t n = sz / sizeof(container_slot);
    if (n < 0 || n > (uint16_t) -1) {
        return luaL_error(L, "size out of range.");
    }
    if (asize > n) {
        return luaL_error(L, "asize out of range.");
    }
    auto c = chest::create(w, s, asize, (uint16_t)n-asize);
    lua_pushinteger(L, std::bit_cast<uint16_t>(c.index));
    return 1;
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t asize = (uint16_t)luaL_checkinteger(L, 3);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 4)-1);
    chest::chest_data c {
        std::bit_cast<container::index>(index),
        asize
    };
    auto r = chest::getslot(w, c, offset);
    if (!r) {
        return 0;
    }
    lua_createtable(L, 0, 10);
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
lflush(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t asize = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 4);
    chest::chest_data c {
        std::bit_cast<container::index>(index),
        asize
    };
    chest::flush(w, c, endpoint);
    return 0;
}

static int
lrollback(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t asize = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 4);
    chest::chest_data c {
        std::bit_cast<container::index>(index),
        asize
    };
    chest::rollback(w, c, endpoint);
    return 0;
}

extern "C" int
luaopen_vaststars_chest_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "create", lcreate },
        { "get", lget },
        { "flush", lflush },
        { "rollback", lrollback },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
