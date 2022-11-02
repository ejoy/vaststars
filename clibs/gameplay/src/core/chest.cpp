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

chest::chest(chest::slot* data, size_t size)
    : slots()
{
    for (size_t i = 0; i < size; ++i) {
        slots.push_back(data[i]);
    }
}

uint16_t chest::get_fluid(uint16_t index) {
    assert(index < slots.size());
    assert(isFluidId(slots[index].item));
    return slots[index].amount;
}

void chest::set_fluid(uint16_t index, uint16_t value) {
    assert(index < slots.size());
    assert(isFluidId(slots[index].item));
    slots[index].amount = value;
}

bool chest::pickup(world& w, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    return pickup(w, endpoint, ingredients, 0);
}

bool chest::place(world& w, uint16_t endpoint, prototype_context& recipe) {
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&recipe);
    recipe_items* results = (recipe_items*)pt_results(&recipe);
    return place(w, endpoint, results, ingredients->n);
}

bool chest::pickup(world& w, uint16_t endpoint, const recipe_items* r, uint16_t offset) {
    assert(offset + r->n < slots.size());
    for (size_t i = 0; i < r->n; ++i) {
        auto& s = slots[offset+i];
        auto& t = r->items[i];
        assert(s.unit == slot::unit::limit);
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    for (size_t i = 0; i < r->n; ++i) {
        auto& s = slots[offset+i];
        auto& t = r->items[i];
        s.amount -= t.amount;
    }
    flush(w, endpoint);
    return true;
}

bool chest::place(world& w, uint16_t endpoint, const recipe_items* r, uint16_t offset) {
    assert(offset + r->n <= slots.size());
    for (size_t i = 0; i < r->n; ++i) {
        auto& s = slots[offset+i];
        auto& t = r->items[i];
        assert(s.unit == slot::unit::limit);
        assert(s.item == t.item);
        if (s.amount + t.amount > s.limit) {
            return false;
        }
    }
    for (size_t i = 0; i < r->n; ++i) {
        auto& s = slots[offset+i];
        auto& t = r->items[i];
        s.amount += t.amount;
    }
    flush(w, endpoint);
    return true;
}

bool chest::recover(world& w, const recipe_items* r, uint16_t offset) {
    assert(offset + r->n < slots.size());
    for (size_t i = 0; i < r->n; ++i) {
        auto& s = slots[offset+i];
        auto& t = r->items[i];
        assert(s.unit == slot::unit::limit);
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, uint16_t endpoint, const uint16_t* r) {
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        assert(s.unit == slot::unit::limit);
        s.limit = r[i];
    }
    flush(w, endpoint);
}

size_t chest::size() const {
    return slots.size();
}

void chest::flush(world& w, uint16_t endpoint) {
    if (endpoint == 0xffff) {
        return;
    }
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        switch (s.type) {
        case slot::type::red:
            trading_sell(w, {endpoint, (uint16_t)i}, RED_PRIORITY, s);
            break;
        case slot::type::blue:
            trading_buy(w, {endpoint, (uint16_t)i}, BLUE_PRIORITY, s);
            break;
        case slot::type::green:
            trading_sell(w, {endpoint, (uint16_t)i}, GREEN_PRIORITY, s);
            trading_buy(w, {endpoint, (uint16_t)i}, GREEN_PRIORITY, s);
            break;
        }
    }
}

void chest::pickup_force(world& w, uint16_t item, uint16_t index, uint16_t amount) {
    assert(index < slots.size());
    auto& s = slots[index];
    assert(item == s.item);
    assert(amount <= s.lock_item);
    assert(amount <= s.amount);
    s.amount -= amount;
    s.lock_item -= amount;
}

void chest::place_force(world& w, uint16_t item, uint16_t index, uint16_t amount) {
    assert(index < slots.size());
    auto& s = slots[index];
    assert(item == s.item);
    assert(amount <= s.lock_space);
    assert(s.amount + amount <= s.limit);
    s.amount += amount;
    s.lock_space -= amount;
}

const chest::slot* chest::getslot(uint16_t index) const {
    if (index >= slots.size()) {
        return nullptr;
    }
    return &slots[index];
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    size_t sz = 0;
    chest::slot* p = (chest::slot*)luaL_checklstring(L, 2, &sz);
    size_t n = sz / sizeof(chest::slot);
    if (n < 0 || n > (uint16_t) -1) {
        return luaL_error(L, "size out of range.");
    }
    uint16_t id = (uint16_t)w.chests.size();
    w.chests.emplace_back(p, n);
    lua_pushinteger(L, id);
    return 1;
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 3);
    chest& c = w.query_chest(id);
    auto r = c.getslot(index-1);
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
