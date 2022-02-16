#include <lua.hpp>
#include <list>

#include "luaecs.h"
#include "world.h"
#include "entity.h"
extern "C" {
#include "prototype.h"
}

#define STATUS_IN  0
#define STATUS_OUT 1

#define STATUS_DONE 0

std::list<int> waiting;

static void
wait(int index) {
    waiting.push_back(index);
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
            auto r = input.inserter_pickup(w, output, 1);
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
            if (!output.inserter_place(w, i.hold_item, i.hold_amount)) {
                return false;
            }
            i.hold_item = 0;
            i.hold_amount = 0;
        }
        i.status = STATUS_IN;
    }
    i.process = pt_speed(&p);
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
        if (i.process == STATUS_DONE
            && i.input_container != uint16_t(-1)
            && i.output_container != uint16_t(-1)
            ) {
            wait(e.index);
        }
    }
    return 0;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    updateWaiting(w);

    for (auto& e : w.select<inserter, entity, capacitance>()) {
        inserter& i = e.get<inserter>();
        if (i.process != STATUS_DONE) {
            capacitance& c = e.get<capacitance>();
            prototype_context p = w.prototype(e.get<entity>().prototype);
            
            unsigned int power = pt_power(&p);
            unsigned int capacitance = power * 2;
            if (c.shortage + power <= capacitance) {
                c.shortage += power;
                i.process--;
                if (i.process == STATUS_DONE) {
                    wait(e.index);
                }
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
