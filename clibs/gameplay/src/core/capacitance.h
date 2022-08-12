#pragma once

#include "luaecs.h"
#include "core/world.h"
extern "C" {
#include "util/prototype.h"
}

struct consumer_context {
    ecs::capacitance& c;
    unsigned int power;
    unsigned int drain;
    unsigned int capacitance;
    inline bool cost(unsigned int v) {
        if (c.shortage + v > capacitance) {
            return false;
        }
        c.shortage += v;
        return true;
    }
    inline bool cost_drain() {
        return cost(drain);
    }
    inline bool cost_power() {
        return cost(power);
    }
};

template <class Entity>
consumer_context get_consumer(lua_State* L, world& w, Entity& v) {
    ecs::entity& e = v.get<ecs::entity>();
    ecs::capacitance& c = v.get<ecs::capacitance>();
    prototype_context p = w.prototype(L, e.prototype);
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = power * 2;
    return {
        c, power, drain, capacitance
    };
}
