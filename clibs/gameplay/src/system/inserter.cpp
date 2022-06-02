#include <lua.hpp>
#include <list>

#include "luaecs.h"
#include "core/world.h"
#include "core/entity.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IN  0
#define STATUS_OUT 1

#define STATUS_DONE 0

#define NO_ITEM   0x00000
#define ANY_ITEM  0x10001
#define CONTAINER_TYPE_CHEST  0
#define CONTAINER_TYPE_RECIPE 1

std::list<int> waiting;

static bool isFluidId(uint16_t id) {
    return (id & 0x0C00) == 0x0C00;
}

static container::item
pickup(world& w, chest_container& input, uint16_t max) {
    if (input.slots.size() == 0) {
        return {0,0};
    }
    auto& s = input.slots[0];
    uint16_t r = std::min(s.amount, max);
    uint16_t newvalue = s.amount - r;
    input.resize(w, s.item, s.amount, newvalue);
    input.sort(0, newvalue);
    assert(!isFluidId(s.item));
    return {s.item, r};
}

static container::item
pickup(world& w, recipe_container& input, uint16_t max) {
    for (auto& s : input.outslots) {
        if (!isFluidId(s.item) && s.amount != 0) {
            uint16_t r = std::min(s.amount, max);
            s.amount -= r;
            return {s.item, r};
        }
    }
    return {0,0};
}

static container::item
pickup(world& w, container& input, uint16_t max) {
    if (input.type() == CONTAINER_TYPE_CHEST) {
        return pickup(w, (chest_container&)input, max);
    }
    return pickup(w, (recipe_container&)input, max);
}

static container::item
pickup(world& w, container& input, chest_container& output, uint16_t max) {
    if (output.used >= output.size) {
        return {0, 0};
    }
    return pickup(w, input, max);
}

static container::item
pickup(world& w, container& input, recipe_container& output, uint16_t max) {
    for (auto& s : output.outslots) {
        if (!isFluidId(s.item) && s.amount >= s.limit) {
            return {0, 0};
        }
    }
    for (auto& s : output.inslots) {
        if (!isFluidId(s.item) && s.amount < s.limit) {
            uint16_t amount = input.pickup(w, s.item, max);
            if (amount != 0) {
                return {s.item, amount};
            }
        }
    }
    return {0, 0};
}

static container::item
pickup(world& w, container& input, container& output, uint16_t max) {
    if (output.type() == CONTAINER_TYPE_CHEST) {
        return pickup(w, input, (chest_container&)output, max);
    }
    return pickup(w, input, (recipe_container&)output, max);
}

static void
wait(inserter& inserter, int index) {
    if (inserter.input_container != uint16_t(-1) && inserter.output_container != uint16_t(-1)) {
        waiting.push_back(index);
    }
}

static bool
tryActive(world& w, inserter& i, entity& e, capacitance& c) {
    prototype_context p = w.prototype(e.prototype);

    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    if (c.shortage + drain > capacitance) {
        return false;
    }
    c.shortage += drain;

    if (i.status == STATUS_IN) {
        if (i.hold_amount == 0) {
            container& input = w.query_container<container>(i.input_container);
            container& output = w.query_container<container>(i.output_container);
            auto r = pickup(w, input, output, 1);
            if (r.amount == 0) {
                return false;
            }
            i.hold_item = r.item;
            i.hold_amount = r.amount;
        }
        i.status = STATUS_OUT;
    }
    else {
        if (i.hold_amount != 0) {
            container& output = w.query_container<container>(i.output_container);
            if (!output.place(w, i.hold_item, i.hold_amount)) {
                return false;
            }
            i.hold_item = 0;
            i.hold_amount = 0;
        }
        i.status = STATUS_IN;
    }
    i.progress = pt_speed(&p);
    return true;
}

static void
updateWaiting(world& w) {
    ecs::select::entity<inserter, entity, capacitance> e;
    for (auto iter = waiting.begin(); iter != waiting.end();) {
        if (!w.visit_entity(e, *iter) || tryActive(w, e.get<inserter>(), e.get<entity>(), e.get<capacitance>())) {
            iter = waiting.erase(iter);
        }
        else {
            ++iter;
        }
    }
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    waiting.clear();

    for (auto& e : w.select<inserter>()) {
        inserter& i = e.get<inserter>();
        if (i.progress == STATUS_DONE) {
            wait(i, e.index);
        }
    }
    return 0;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    updateWaiting(w);

    for (auto& e : w.select<inserter, entity, consumer, capacitance>()) {
        inserter& i = e.get<inserter>();
        if (i.progress != STATUS_DONE) {
            capacitance& c = e.get<capacitance>();
            consumer& co = e.get<consumer>();
            prototype_context p = w.prototype(e.get<entity>().prototype);
            
            unsigned int power = pt_power(&p);
            unsigned int capacitance = power * 2;
            if (c.shortage + power <= capacitance) {
                c.shortage += power;
                i.progress--;
                if (i.progress == STATUS_DONE) {
                    co.low_power = 0;
                    wait(i, e.index);
                }
                else {
                    if (co.low_power > 0) co.low_power--;
                }
            }
            else {
                co.low_power = 50;
            }
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_inserter_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
