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
    inline unsigned int costall(unsigned int v) {
        if (c.shortage + v > capacitance) {
            v = capacitance - c.shortage;
            c.shortage = capacitance;
            return v;
        }
        c.shortage += v;
        return v;
    }
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
    ecs::entity& e = v.template get<ecs::entity>();
    ecs::capacitance& c = v.template get<ecs::capacitance>();
    prototype_context p = w.prototype(L, e.prototype);
    unsigned int power = pt_power(&p);
    unsigned int drain = pt_drain(&p);
    unsigned int capacitance = pt_capacitance(&p);
    return {
        c, power, drain, capacitance
    };
}
