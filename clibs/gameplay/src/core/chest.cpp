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

chest::chest(type type_, chest::slot* data, size_t size)
    : slots()
    , type_(type_)
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

bool chest::pickup(world& w, uint16_t endpoint, const recipe_items* r) {
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        auto& t = r->items[i];
        assert(s.type == slot::type::limit);
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        auto& t = r->items[i];
        s.amount -= t.amount;
        if (type_ == type::blue && endpoint != 0xffff) {
            trading_buy(w, {endpoint}, s);
        }
    }
    return true;
}

bool chest::place(world& w, uint16_t endpoint, const recipe_items* r) {
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        auto& t = r->items[i];
        assert(s.type == slot::type::limit);
        assert(s.item == t.item);
        if (s.amount + t.amount > s.limit) {
            return false;
        }
    }
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        auto& t = r->items[i];
        s.amount += t.amount;
        if (type_ == type::red && endpoint != 0xffff) {
            trading_sell(w, {endpoint}, s);
        }
    }
    return true;
}

bool chest::recover(world& w, const recipe_items* r) {
    assert(type_ == type::blue);
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        auto& t = r->items[i];
        assert(s.type == slot::type::limit);
        assert(s.item == t.item);
        s.amount += t.amount;
    }
    return true;
}

void chest::limit(world& w, uint16_t endpoint, const uint16_t* r) {
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        assert(s.type == slot::type::limit);
        s.limit = r[i];
        if (type_ == type::blue && endpoint != 0xffff) {
            trading_buy(w, {endpoint}, s);
        }
    }
}

size_t chest::size() const {
    return slots.size();
}

static uint16_t pickup_slot(chest::slot& s, uint16_t max) {
    if (s.amount > max) {
        s.amount -= max;
        return max;
    }
    uint16_t n = s.amount;
    s.amount = 0;
    if (s.type == chest::slot::type::empty) {
        s.item = 0;
    }
    return n;
}

uint16_t chest::pickup(world& w, uint16_t item, uint16_t max) {
    assert(type_ == type::red || type_ == type::none);
    uint16_t n = 0;
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == item) {
            n += pickup_slot(s, max - n);
            if (n >= max) {
                break;
            }
        }
    }
    return n;
}

void chest::flush(world& w, uint16_t endpoint) {
    if (endpoint != 0xffff) {
        if (type_ == type::red) {
            for (size_t i = 0; i < slots.size(); ++i) {
                auto& s = slots[i];
                trading_sell(w, {endpoint}, s);
            }
        }
        else if (type_ == type::blue) {
            for (size_t i = 0; i < slots.size(); ++i) {
                auto& s = slots[i];
                trading_buy(w, {endpoint}, s);
            }
        }
    }
}

static uint16_t place_slot(chest::slot& s, uint16_t amount) {
    if (s.amount + amount <= s.limit) {
        s.amount += amount;
        return amount;
    }
    if (s.amount <= s.limit) {
        uint16_t n = s.limit - s.amount;
        s.amount = s.limit;
        return n;
    }
    return 0;
}

uint16_t chest::place(world& w, uint16_t item, uint16_t amount, uint16_t limit) {
    assert(type_ == type::blue || type_ == type::none);
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == item) {
            amount -= place_slot(s, amount);
            if (amount == 0) {
                return 0;
            }
        }
    }
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == 0) {
            assert(s.type == chest::slot::type::empty);
            assert(s.amount == 0);
            s.item = item;
            s.limit = limit;
            amount -= place_slot(s, amount);
            if (amount == 0) {
                return 0;
            }
        }
    }
    return amount;
}

void chest::pickup_force(world& w, uint16_t item, uint16_t amount) {
    assert(type_ == type::red);
    uint16_t n = 0;
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == item) {
            assert(amount <= s.lock);
            assert(amount <= s.amount);
            s.amount -= amount;
            s.lock -= amount;
            return;
        }
    }
    assert(amount == 0);
}

void chest::place_force(world& w, uint16_t item, uint16_t amount) {
    assert(type_ == type::blue);
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == item) {
            assert(amount <= s.lock);
            assert(s.amount + amount <= s.limit);
            s.amount += amount;
            s.lock -= amount;
            return;
        }
    }
    assert(amount == 0);
}

const chest::slot* chest::getslot(uint16_t index) const {
    if (index >= slots.size()) {
        return nullptr;
    }
    return &slots[index];
}

bool chest::pickup(world& w, flatmap<uint16_t, uint16_t>& items) {
    assert(type_ == type::none);
    flatmap<uint16_t, uint16_t> index;
    for (auto [item, amount] : items) {
        for (size_t i = 0; i < slots.size(); ++i) {
            auto& s = slots[i];
            if (s.item == item) {
                if (s.amount < amount) {
                    return false;
                }
                index.insert_or_assign((uint16_t)i, amount);
            }
        }
    }
    for (auto [i, amount] : index) {
        slots[i].amount -= amount;
    }
    return true;
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    static const char *const opts[] = {"none", "red", "blue", NULL};
    static const chest::type optsnum[] = {chest::type::none, chest::type::red, chest::type::blue};
    size_t sz = 0;
    chest::slot* p = (chest::slot*)luaL_checklstring(L, 3, &sz);
    size_t n = sz / sizeof(chest::slot);
    if (n < 0 || n > (uint16_t) -1) {
        return luaL_error(L, "size out of range.");
    }
    uint16_t id = (uint16_t)w.chests.size();
    w.chests.emplace_back(optsnum[luaL_checkoption(L, 2, NULL, opts)], p, n);
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
lpickup(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t max = (uint16_t)luaL_checkinteger(L, 4);
    chest& c = w.query_chest(id);
    uint16_t n = c.pickup(w, item, max);
    lua_pushinteger(L, n);
    return 1;
}

static uint16_t getstack(world&w, lua_State* L, uint16_t item) {
    struct prototype_context p = w.prototype(L, item);
    return (uint16_t)pt_stack(&p);
}

static int
lplace(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t amount = (uint16_t)luaL_checkinteger(L, 4);
    chest& c = w.query_chest(id);
    uint16_t n = c.place(w, item, amount, getstack(w, L, item));
    lua_pushinteger(L, n);
    return 1;
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
		{ "pickup", lpickup },
		{ "place", lplace },
        { "flush", lflush },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
