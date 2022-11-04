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

chest::chest(world& w, container_slot* data, container::size_type size) {
    asize = (container::size_type)size;
    index = w.container.create_chest(asize, 0);
    for (auto& slot: w.container.slice(index, asize)) {
        (container_slot&)slot = *data++;
    }
}

chest::chest(container::index index, container::size_type size)
    : index(index)
    , asize(size)
{}

std::tuple<container::index, container::size_type> chest::save() const {
    return {index, asize};
}

uint16_t chest::get_fluid(world& w, uint8_t offset) {
    assert(offset < asize);
    auto& s = w.container.at(index + offset);
    assert(isFluidId(s.item));
    return s.amount;
}

void chest::set_fluid(world& w, uint8_t offset, uint16_t value) {
    assert(offset < asize);
    auto& s = w.container.at(index + offset);
    assert(isFluidId(s.item));
    s.amount = value;
}

bool chest::pickup(world& w, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    return pickup(w, endpoint, ingredients, 0);
}

bool chest::place(world& w, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    recipe_items* results = (recipe_items*)pt_results(&recipe);
    //TODO ingredients->n -> uint8_t
    return place(w, endpoint, results, (uint8_t)ingredients->n);
}

bool chest::pickup(world& w, uint16_t endpoint, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= asize);
    size_t i = 0;
    for (auto& s: w.container.slice(index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.unit == container_slot::unit::limit);
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    i = 0;
    for (auto& s: w.container.slice(index + offset, r->n)) {
        auto& t = r->items[i++];
        s.amount -= t.amount;
    }
    flush(w, endpoint);
    return true;
}

bool chest::place(world& w, uint16_t endpoint, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= asize);
    size_t i = 0;
    for (auto& s: w.container.slice(index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.unit == container_slot::unit::limit);
        assert(s.item == t.item);
        if (s.amount + t.amount > s.limit) {
            return false;
        }
    }
    i = 0;
    for (auto& s: w.container.slice(index + offset, r->n)) {
        auto& t = r->items[i++];
        s.amount += t.amount;
    }
    flush(w, endpoint);
    return true;
}

bool chest::recover(world& w, const recipe_items* r, uint8_t offset) {
    assert(offset + r->n <= asize);
    size_t i = 0;
    for (auto& s: w.container.slice(index + offset, r->n)) {
        auto& t = r->items[i++];
        assert(s.unit == container_slot::unit::limit);
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, uint16_t endpoint, const uint16_t* r) {
    for (auto& s: w.container.slice(index, asize)) {
        assert(s.unit == container_slot::unit::limit);
        s.limit = *r++;
    }
    flush(w, endpoint);
}

size_t chest::size() const {
    return asize;
}

void chest::flush(world& w, uint16_t endpoint) {
    flush(w, endpoint, 0, asize);
}

void chest::flush(world& w, uint16_t endpoint, uint8_t offset, container::size_type size) {
    if (endpoint == 0xffff) {
        return;
    }
    assert(offset + size <= asize);
    uint8_t i = offset;
    for (auto& s: w.container.slice(index + offset, size)) {
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

void chest::pickup_force(world& w, uint8_t offset, uint16_t item, uint16_t amount) {
    assert(offset < asize);
    auto& s = w.container.at(index + offset);
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

void chest::place_force(world& w, uint8_t offset, uint16_t item, uint16_t amount) {
    assert(offset < asize);
    auto& s = w.container.at(index + offset);
    assert(item == s.item);
    assert(amount <= s.lock_space);
    assert(s.amount + amount <= s.limit);
    s.amount += amount;
    s.lock_space -= amount;
}

const container_slot* chest::getslot(world& w, uint8_t offset) const {
    if (offset >= asize) {
        return nullptr;
    }
    auto& s = w.container.at(index + offset);
    return &s;
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    size_t sz = 0;
    container_slot* p = (container_slot*)luaL_checklstring(L, 2, &sz);
    size_t n = sz / sizeof(container_slot);
    if (n < 0 || n > (uint16_t) -1) {
        return luaL_error(L, "size out of range.");
    }
    uint16_t id = (uint16_t)w.chests.size();
    w.chests.emplace_back(w, p, (uint16_t)n);
    lua_pushinteger(L, id);
    return 1;
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint8_t offset = (uint8_t)(luaL_checkinteger(L, 3)-1);
    chest& c = w.query_chest(id);
    auto r = c.getslot(w, offset);
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
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t endpoint = (uint16_t)luaL_checkinteger(L, 3);
    chest& c = w.query_chest(id);
    c.flush(w, endpoint);
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
