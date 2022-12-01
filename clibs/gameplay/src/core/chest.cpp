#include <lua.hpp>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>
#include "core/chest.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

constexpr uint8_t BLUE_PRIORITY = 0;
constexpr uint8_t RED_PRIORITY = 0;
constexpr uint8_t GREEN_PRIORITY = 1;

static bool isFluidId(uint16_t id) {
    return (id & 0x0C00) == 0x0C00;
}

chest::chest_data chest::create(world& w, container_slot* data, container::size_type asize, container::size_type lsize) {
    if (asize == 0 && lsize == 0) {
        return {0,0};
    }
    auto start = w.container.create_chest(asize, lsize);
    for (auto& slot: w.container.slice(start, asize)) {
        (container_slot&)slot = *data++;
    }
    auto index = start;
    if (asize > 0) {
        index.slot += (asize-1);
    }
    for (container::size_type i = 0; i < lsize; ++i) {
        auto& slot = w.container.at(index);
        (container_slot&)slot = *data++;
        index = slot.next;
    }
    return { start, asize };
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
        assert(s.unit == container_slot::unit::limit);
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
        assert(s.unit == container_slot::unit::limit);
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
        assert(s.unit == container_slot::unit::limit);
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, chest_data& c, uint16_t endpoint, const uint16_t* r) {
    for (auto& s: w.container.slice(c.index, c.asize)) {
        assert(s.unit == container_slot::unit::limit);
        s.limit = *r++;
    }
    chest::flush(w, c, endpoint);
}

size_t chest::size(chest_data& c) {
    return c.asize;
}

void chest::flush(world& w, chest_data& c, uint16_t endpoint) {
    chest::flush(w, c, endpoint, 0, c.asize);
}

void chest::flush(world& w, chest_data& c, uint16_t endpoint, uint8_t offset, container::size_type size) {
    if (endpoint == 0xffff) {
        return;
    }
    assert(offset + size <= c.asize);
    uint8_t i = offset;
    for (auto& s: w.container.slice(c.index + offset, size)) {
        if (s.item != 0) {
            switch (s.type) {
            case container_slot::type::red:
                trading_sell(w, {endpoint, i}, RED_PRIORITY, s);
                break;
            case container_slot::type::blue:
                trading_buy(w, {endpoint, i}, BLUE_PRIORITY, s);
                break;
            case container_slot::type::green:
                trading_sell(w, {endpoint, i}, GREEN_PRIORITY, s);
                trading_buy(w, {endpoint, i}, GREEN_PRIORITY, s);
                break;
            }
        }
        i++;
    }
}

void chest::pickup_force(world& w, chest_data& c, uint8_t offset, uint16_t item, uint16_t amount) {
    assert(offset < c.asize);
    auto& s = w.container.at(c.index + offset);
    assert(item == s.item);
    assert(amount <= s.lock_item);
    assert(amount <= s.amount);
    s.amount -= amount;
    s.lock_item -= amount;
    if (s.unit == container_slot::unit::empty) {
        if (s.amount == 0 && s.lock_item == 0 && s.lock_space == 0) {
            s.item = 0;
        }
    }
}

void chest::place_force(world& w, chest_data& c, uint8_t offset, uint16_t item, uint16_t amount) {
    assert(offset < c.asize);
    auto& s = w.container.at(c.index + offset);
    assert(item == s.item);
    assert(amount <= s.lock_space);
    assert(s.amount + amount <= s.limit);
    s.amount += amount;
    s.lock_space -= amount;
}

const container_slot* chest::getslot(world& w, chest_data& c, uint8_t offset) {
    if (offset >= c.asize) {
        auto idx = c.index;
        if (c.asize != 0) {
            idx.slot += (c.asize-1);
            offset -= (c.asize-1);
        }
        for (uint8_t i = 0; i < offset; ++i) {
            idx = w.container.at(idx).next;
            if (idx == container::kInvalidIndex) {
                return nullptr;
            }
        }
        auto& s = w.container.at(idx);
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
    if (!r || !r->amount) {
        return 0;
    }
    lua_pushinteger(L, r->item);
    lua_pushinteger(L, r->amount);
    lua_pushinteger(L, r->limit);
    return 3;
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

extern "C" int
luaopen_vaststars_chest_core(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "create", lcreate },
        { "get", lget },
        { "flush", lflush },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
