#pragma once

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"

struct consumer_context {
    ecs::capacitance& c;
    uint32_t power;
    uint32_t drain;
    uint32_t capacitance;
    uint32_t costall(uint32_t v) {
        if (c.shortage + v > capacitance) {
            v = capacitance - c.shortage;
            c.shortage = capacitance;
            return v;
        }
        c.shortage += v;
        return v;
    }
    bool has(uint32_t v) const {
        if (c.shortage + v > capacitance) {
            return false;
        }
        return true;
    }
    bool cost(uint32_t v) {
        if (c.shortage + v > capacitance) {
            return false;
        }
        c.shortage += v;
        return true;
    }
    bool cost_drain() {
        return cost(drain);
    }
    bool cost_power() {
        return cost(power);
    }
    bool has_power() const {
        return has(power);
    }
};


inline consumer_context get_consumer(world& w, uint16_t prototype, ecs::capacitance& c) {
    uint32_t power = prototype::get<"power">(w, prototype);
    uint32_t drain = prototype::get<"drain">(w, prototype);
    uint32_t capacitance = prototype::get<"capacitance">(w, prototype);
    return {
        c, power, drain, capacitance
    };
}

template <class Entity>
consumer_context get_consumer(world& w, Entity& v, ecs::capacitance& c) {
    ecs::building& building = v.template get<ecs::building>();
    return get_consumer(w, building.prototype, c);
}

template <class Entity>
consumer_context get_consumer(world& w, Entity& v) {
    ecs::capacitance& c = v.template get<ecs::capacitance>();
    return get_consumer(w, v, c);
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
    inline void force_produce(uint32_t efficiency, uint32_t fixed) {
        uint32_t real_power = (power / fixed) * efficiency + (power % fixed) * efficiency / fixed;
        if (real_power < c.shortage) {
            c.shortage -= real_power;
        }
        else {
            c.shortage = 0;
        }
    }
};

template <class Entity>
generator_context get_generator(world& w, Entity& v, ecs::capacitance& c) {
    ecs::building& building = v.template get<ecs::building>();
    uint32_t power = prototype::get<"power">(w, building.prototype);
    uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
    return {
        c, power, capacitance
    };
}

template <class Entity>
generator_context get_generator(world& w, Entity& v) {
    ecs::capacitance& c = v.template get<ecs::capacitance>();
    return get_generator(w, v, c);
}
