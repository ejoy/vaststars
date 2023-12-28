#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"

struct task {
    enum class type: uint16_t {
        stat_production = 0,
        stat_consumption,
        select_entity,
        reserve,
        power_generator,
        unknown,
    };
    type     type;
    uint16_t e;
    uint16_t p1;
    uint16_t p2;

    uint64_t stat_production(world& w) const;
    uint64_t stat_consumption(world& w) const;
    uint64_t select_entity(world& w) const;
    uint64_t power_generator(world& w) const;
    uint64_t eval(world& w) const;
    uint16_t progress(world& w) const;
};


uint64_t task::stat_production(world& w) const {
    auto iter = w.stat._total.production.find(p1);
    if (iter) {
        return *iter;
    }
    return 0;
}

uint64_t task::stat_consumption(world& w) const {
    auto iter = w.stat._total.consumption.find(p1);
    if (iter) {
        return *iter;
    }
    return 0;
}

uint64_t task::select_entity(world& w) const {
    uint64_t n = 0;
    for (auto& building : ecs_api::array<component::building>(w.ecs)) {
        if (building.prototype == p1) {
            ++n;
        }
    }
    return n;
}

uint64_t task::power_generator(world& w) const {
    constexpr uint16_t UPS = 30;
    // 10m / 150 = 10 * 60 * 30 / 150 = 120(frame)
    uint64_t sum = 0;
    for (auto const& [_, v] : w.stat._dataset[2].back().generate_power) {
        sum += v;
    }
    return sum / (120 / UPS);
}

uint64_t task::eval(world& w) const {
    switch (type) {
    case task::type::stat_production:         return stat_production(w);
    case task::type::stat_consumption:        return stat_consumption(w);
    case task::type::select_entity:           return select_entity(w);
    case task::type::power_generator:         return power_generator(w);
    default: return 0;
    }
}

uint16_t task::progress(world& w) const {
    uint64_t v = eval(w);
    for (uint16_t i = 0; i < e; ++i) {
        v /= 10;
    }
    uint16_t max = std::numeric_limits<uint16_t>::max();
    if (v >= max) {
        return max;
    }
    return (uint16_t)v;
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (;;) {
        uint16_t taskid = w.techtree.queue_top();
        if (taskid == 0) {
            break;
        }
        auto time = prototype::get<"time">(w, taskid);
        if (0 != time) {
            break;
        }
        auto const& task = prototype::get<"task", struct task>(w, taskid);
        if (task.type == task::type::unknown) {
            break;
        }
        uint16_t value = task.progress(w);
        if (!w.techtree.research_set(w, taskid, value)) {
            break;
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_task_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
