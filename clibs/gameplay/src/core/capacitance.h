#pragma once

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"

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
consumer_context get_consumer(world& w, Entity& v) {
    ecs::building& building = v.template get<ecs::building>();
    ecs::capacitance& c = v.template get<ecs::capacitance>();
    unsigned int power = prototype::get<"power">(w, building.prototype);
    unsigned int drain = prototype::get<"drain">(w, building.prototype);
    unsigned int capacitance = prototype::get<"capacitance">(w, building.prototype);
    return {
        c, power, drain, capacitance
    };
}
