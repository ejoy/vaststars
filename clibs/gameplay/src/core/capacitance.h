#pragma once

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"

struct consumer_context {
    ecs::capacitance& c;
    uint32_t power;
    uint32_t drain;
    uint32_t capacitance;
    inline uint32_t costall(uint32_t v) {
        if (c.shortage + v > capacitance) {
            v = capacitance - c.shortage;
            c.shortage = capacitance;
            return v;
        }
        c.shortage += v;
        return v;
    }
    inline bool cost(uint32_t v) {
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
    uint32_t power = prototype::get<"power">(w, building.prototype);
    uint32_t drain = prototype::get<"drain">(w, building.prototype);
    uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
    return {
        c, power, drain, capacitance
    };
}

struct generator_context {
    ecs::capacitance& c;
    uint32_t power;
    uint32_t capacitance;
    inline bool produce() {
        if (power < c.shortage) {
            c.shortage -= power;
            return true;
        }
        return false;
    }
    inline void force_produce() {
        if (power < c.shortage) {
            c.shortage -= power;
        }
        else {
            c.shortage = 0;
        }
    }
    inline void force_produce(float efficiency) {
        uint32_t real_power = (uint32_t)(power * efficiency);
        if (real_power < c.shortage) {
            c.shortage -= real_power;
        }
        else {
            c.shortage = 0;
        }
    }
};

template <class Entity>
generator_context get_generator(world& w, Entity& v) {
    ecs::building& building = v.template get<ecs::building>();
    ecs::capacitance& c = v.template get<ecs::capacitance>();
    uint32_t power = prototype::get<"power">(w, building.prototype);
    uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
    return {
        c, power, capacitance
    };
}
