#include <lua.hpp>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>
#include "container.h"
#include "world.h"
extern "C" {
#include "prototype.h"
}

static bool isFluidId(uint16_t id) {
    return (id & 0x0C00) == 0x0C00;
}

chest_container::chest_container()
    : slots()
    , used(0)
    , size(0)
{}

chest_container::chest_container(uint16_t size)
    : slots()
    , used(0)
    , size(size)
{}

container::item chest_container::get(uint16_t index) {
    if (index >= slots.size()) {
        return {0,0};
    }
    return slots[index];
}

uint16_t chest_container::pickup(world& w, uint16_t item, uint16_t max) {
    size_t pos = find(item);
    if (pos == (size_t)-1) {
        return 0;
    }
    auto& s = slots[pos];
    uint16_t r = std::min(s.amount, max);
    uint16_t newvalue = s.amount - r;
    resize(w, s.item, s.amount, newvalue);
    sort(pos, newvalue);
    return r;
}

bool chest_container::place(world& w, uint16_t item, uint16_t amount) {
    size_t pos = find(item);
    if (pos == (size_t)-1) {
        if (used >= size) {
            return false;
        }
        if (!resize(w, item, 0, amount)) {
            return false;
        }
        slots.push_back(chest_container::slot {item, 0});
        sort(slots.size()-1, amount);
        return true;
    }
    uint16_t newvalue = slots[pos].amount + amount;
    if (!resize(w, slots[pos].item, slots[pos].amount, newvalue)) {
        return false;
    }
    sort(pos, newvalue);
    return true;
}

void chest_container::sort(size_t index, uint16_t newvalue) {
    uint16_t value = slots[index].amount;
    if (newvalue == 0) {
        for (size_t i = index; i < slots.size() - 1; ++i) {
            slots[i] = slots[i+1];
        }
        slots.pop_back();
    }
    else if (value > newvalue) {
        chest_container::slot insert = {slots[index].item, newvalue};
        for (size_t i = index; i < slots.size()-1; ++i) {
            if (slots[i+1].amount <= newvalue) {
                slots[i] = insert;
                return;
            }
            slots[i] = slots[i+1];
        }
        slots[slots.size()-1] = insert;
    }
    else {
        chest_container::slot insert = {slots[index].item, newvalue};
        for (size_t i = index; i > 0; --i) {
            if (slots[i-1].amount >= newvalue) {
                slots[i] = insert;
                return;
            }
            slots[i] = slots[i-1];
        }
        slots[0] = insert;
    }
}

bool chest_container::resize(world& w, uint16_t item, uint16_t value, uint16_t newvalue) {
    struct prototype_context p = { w.c.L, w.c.P, item };
    uint16_t stack = pt_stack(&p);
    assert (value != newvalue);

    uint16_t capacity = value / stack + 1;
    uint16_t newcapacity = newvalue / stack + 1;
    if (used - capacity > size - newcapacity) {
        return false;
    }
    used = used - capacity + newcapacity;
    return true;
}

size_t chest_container::find(uint16_t item) {
    for (size_t i = 0; i < slots.size(); ++i) {
        auto& s = slots[i];
        if (s.item == item) {
            return i;
        }
    }
    return -1;
}

recipe_container::recipe_container()
{}

recipe_container::recipe_container(item_array in, item_array out)
    : inslots(in.size())
    , outslots(out.size())
{
    for (size_t i = 0; i < in.size(); ++i) {
        inslots[i].item  = in[i].item;
        inslots[i].limit = in[i].amount;
        inslots[i].amount = 0;
    }
    for (size_t i = 0; i < out.size(); ++i) {
        outslots[i].item  = out[i].item;
        outslots[i].limit = out[i].amount;
        outslots[i].amount = 0;
    }
}

container::item recipe_container::get(uint16_t index) {
    if (index < inslots.size()) {
        return inslots[index];
    }
    if (index < inslots.size() + outslots.size()) {
        return outslots[index-inslots.size()];
    }
    return {0,0};
}

uint16_t recipe_container::pickup(world& w, uint16_t item, uint16_t max) {
    for (auto& s : outslots) {
        if (s.item == item) {
            uint16_t r = std::min(s.amount, max);
            s.amount -= r;
            return r;
        }
    }
    return 0;
}

bool recipe_container::place(world& w, uint16_t item, uint16_t amount) {
    for (auto& s : inslots) {
        if (s.item == item) {
            if (amount + s.amount > s.limit) {
                return false;
            }
            s.amount += amount;
            return true;
        }
    }
    return false;
}

bool recipe_container::recipe_pickup(world& w, item const* items) {
    for (size_t i = 0; i < inslots.size(); ++i) {
        auto& s = inslots[i];
        auto& t = items[i];
        assert(s.item == t.item);
        if (s.amount < t.amount) {
            return false;
        }
    }
    for (size_t i = 0; i < inslots.size(); ++i) {
        auto& s = inslots[i];
        auto& t = items[i];
        s.amount -= t.amount;
    }
    return true;
}

bool recipe_container::recipe_place(world& w, item const* items) {
    for (size_t i = 0; i < outslots.size(); ++i) {
        auto& s = outslots[i];
        auto& t = items[i];
        if (isFluidId(s.item) && (s.amount + t.amount) > s.limit) {
            return false;
        }
        s.amount += t.amount;
    }
    return true;
}

bool recipe_container::recipe_get(slot_type type, uint16_t index, uint16_t& value) {
    if (type == slot_type::in) {
        if (index < inslots.size()) {
            value = inslots[index].amount;
            return true;
        }
    }
    else {
        if (index < outslots.size()) {
            value = outslots[index].amount;
            return true;
        }
    }
    return false;
}

bool recipe_container::recipe_set(slot_type type, uint16_t index, uint16_t value) {
    if (type == slot_type::in) {
        if (index < inslots.size()) {
            inslots[index].amount = value;
            return true;
        }
    }
    else {
        if (index < outslots.size()) {
            outslots[index].amount = value;
            return true;
        }
    }
    return false;
}

static container::item_array read_table(lua_State* L, int idx) {
    size_t sz = 0;
    container::item* p = (container::item*)luaL_checklstring(L, idx, &sz);
    size_t n = sz / sizeof(container::item);
    container::item_array r(n);
    for (size_t i = 0; i < n; ++i) {
        r[i] = p[i];
    }
    return r;
}

static int
lcreate(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    const char* type = luaL_checkstring(L, 2);
    if (type[0] == 'c') {
        lua_Integer size = luaL_checkinteger(L, 3);
        if (size < 0 || size > (uint16_t) -1) {
            return luaL_error(L, "size out of range.");
        }
        w.containers.chest.emplace_back((uint16_t)size);
        lua_pushinteger(L, w.container_id<chest_container>());
        return 1;
    }
    else {
        w.containers.recipe.emplace_back(read_table(L, 3), read_table(L, 4));
        lua_pushinteger(L, w.container_id<recipe_container>());
        return 1;
    }
}

static int
lget(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t index = (uint16_t)luaL_checkinteger(L, 3);
    container& c = w.query_container<container>(id);
    auto r = c.get(index-1);
    if (r.amount == 0) {
        return 0;
    }
    lua_pushinteger(L, r.item);
    lua_pushinteger(L, r.amount);
    return 2;
}


static int
lpickup(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t max = (uint16_t)luaL_checkinteger(L, 4);
    container& c = w.query_container<container>(id);
    auto ok = c.pickup(w, item, max);
    lua_pushboolean(L, ok);
    return 1;
}

static int
lplace(lua_State* L) {
    world& w = *(world *)lua_touserdata(L, 1);
    uint16_t id = (uint16_t)luaL_checkinteger(L, 2);
    uint16_t item = (uint16_t)luaL_checkinteger(L, 3);
    uint16_t amount = (uint16_t)luaL_checkinteger(L, 4);
    container& c = w.query_container<container>(id);
    auto ok = c.place(w, item, amount);
    lua_pushboolean(L, ok);
    return 1;
}

extern "C" int
luaopen_vaststars_container_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "create", lcreate },
		{ "get", lget },
		{ "pickup", lpickup },
		{ "place", lplace },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
