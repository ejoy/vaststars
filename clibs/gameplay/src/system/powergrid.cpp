#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "core/world.h"
#include "util/prototype.h"
#include <bee/nonstd/to_underlying.h>

enum class power_priority: uint8_t {
	primary,
	secondary,
};

static constexpr size_t POWER_PRIORITY = enum_count_v<power_priority>;

struct powergrid {
    uint64_t consumer_power[POWER_PRIORITY] = {0};
    uint64_t generator_power[POWER_PRIORITY] = {0};
    uint64_t accumulator_output = 0;
    uint64_t accumulator_input = 0;
    float consumer_efficiency[POWER_PRIORITY] = {0};
    float generator_efficiency[POWER_PRIORITY] = {0};
    float accumulator_efficiency = 0.f;
	bool active = false;
};

static void
stat_consumer(world& w, powergrid pg[]) {
	for (auto& v : ecs_api::select<ecs::consumer, ecs::capacitance, ecs::building>(w.ecs)) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.network == 0) {
			continue;
		}
		ecs::building& building = v.get<ecs::building>();
		auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
		uint32_t power = prototype::get<"power">(w, building.prototype);
		uint32_t charge = c.shortage < power ? c.shortage : power;
		pg[c.network].consumer_power[std::to_underlying(priority)] += charge;
		pg[c.network].active = true;
	}
}

static void
stat_generator(world& w, powergrid pg[]) {
	for (auto& v : ecs_api::select<ecs::generator, ecs::capacitance, ecs::building>(w.ecs)) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.network == 0) {
			continue;
		}
		ecs::building& building = v.get<ecs::building>();
		auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
		uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
		pg[c.network].generator_power[std::to_underlying(priority)] += capacitance - c.shortage;
		pg[c.network].active = true;
	}
}

static void
stat_accumulator(world& w, powergrid pg[]) {
	for (auto& v : ecs_api::select<ecs::accumulator, ecs::capacitance, ecs::building>(w.ecs)) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.network == 0) {
			continue;
		}
		ecs::building& building = v.get<ecs::building>();
		uint32_t power = prototype::get<"power">(w, building.prototype);
		if (c.shortage == 0) {
			// battery is full
			pg[c.network].accumulator_output += power;
		} else {
			uint32_t charge_power = prototype::get<"charge_power">(w, building.prototype);
			uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
			pg[c.network].accumulator_input += (c.shortage <= charge_power) ? c.shortage : charge_power;
			uint32_t capacitance_remain = capacitance - c.shortage;
			pg[c.network].accumulator_output += (capacitance_remain <= power) ? capacitance_remain : power;
		}
		pg[c.network].active = true;
	}
}

static void
calc_efficiency(world& w, powergrid pgs[]) {
	for (int ii = 1; ii < 256; ++ii) {
		powergrid& pg = pgs[ii];
		if (!pg.active) {
			break;
		}
		uint64_t need_power = 0;
		for (size_t i=0;i<POWER_PRIORITY;i++) {
			need_power += pg.consumer_power[i];
		}
		uint64_t offer_power = 0;
		for (size_t i=0;i<POWER_PRIORITY;i++) {
			offer_power += pg.generator_power[i];
		}

		if (need_power > offer_power) {
			// power is not enough, all generator efficiency are 100%
			for (size_t i=0;i<POWER_PRIORITY;i++) {
				pg.generator_efficiency[i] = 1.0f;
			}

			need_power -= offer_power;
			// accumulator output
			if (need_power >= pg.accumulator_output) {
				if (pg.accumulator_output == 0) {
					pg.accumulator_efficiency = 0;
				} else {
					pg.accumulator_efficiency = 1.0f;
					offer_power += pg.accumulator_output;
				}
				for (size_t i=0;i<POWER_PRIORITY;i++) {
					if (offer_power == 0) {
						// no power
						pg.consumer_efficiency[i] = 0;
					} else if (offer_power >= pg.consumer_power[i]) {
						// P[i] is satisfied
						pg.consumer_efficiency[i] = 1.0f;
						offer_power -= pg.consumer_power[i];
					} else {
						pg.consumer_efficiency[i] = (float)offer_power / pg.consumer_power[i];
						offer_power = 0;
					}
				}
			} else {
				pg.accumulator_efficiency = (float)need_power / pg.accumulator_output;
				// power is enough now.
				for (size_t i=0;i<POWER_PRIORITY;i++) {
					pg.consumer_efficiency[i] = 1.0f;
				}
			}
		} else {
			// power is enough, all consumer efficiency are 100%
			for (size_t i=0;i<POWER_PRIORITY;i++) {
				pg.consumer_efficiency[i] = 1.0f;
			}
			offer_power -= need_power;
			// charge accumulators
			if (offer_power >= pg.accumulator_input) {
				if (pg.accumulator_input == 0) {
					pg.accumulator_efficiency = 0;
				} else {
					pg.accumulator_efficiency = -1.0f;
					need_power += pg.accumulator_input;
				}
				for (size_t i=0;i<POWER_PRIORITY;i++) {
					if (need_power == 0) {
						// Don't need power yet
						pg.generator_efficiency[i] = 0;
					} else if (need_power >= pg.generator_power[i]) {
						// P[i] should full output
						pg.generator_efficiency[i] = 1.0f;
						need_power -= pg.generator_power[i];
					} else {
						pg.generator_efficiency[i] = (float)need_power / pg.generator_power[i];
						need_power = 0;
					}
				}
			} else {
				pg.accumulator_efficiency = -(float)offer_power / pg.accumulator_input;
				// part charge, generators full output
				for (size_t i=0;i<POWER_PRIORITY;i++) {
					pg.generator_efficiency[i] = 1.0f;
				}
			}
		}
	}
}

static void
powergrid_run(world& w, powergrid pg[]) {
	uint64_t generate_power = 0;
	uint64_t consume_power = 0;
	for (auto& v : ecs_api::select<ecs::capacitance, ecs::building>(w.ecs)) {
		ecs::capacitance& c = v.get<ecs::capacitance>();
		if (c.network == 0 || !pg[c.network].active) {
			c.delta = 0;
			continue;
		}
		ecs::building& building = v.get<ecs::building>();
		if (v.sibling<ecs::consumer>()) {
			// It's a consumer, charge capacitance
			if (c.shortage > 0) {
				auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
				float eff = pg[c.network].consumer_efficiency[std::to_underlying(priority)];
				if (eff > 0) {
					// charge
					uint32_t power = prototype::get<"power">(w, building.prototype);
					if (c.shortage <= power) {
						if (eff >= 1.0f) {
							power = c.shortage;	// full charge
						} else {
							power = (uint32_t)(c.shortage * eff);
						}
					} else {
						power = (uint32_t)(power * eff);
					}
					c.delta = -(int32_t)power;
					c.shortage -= power;
					consume_power += power;
					continue;
				}
			}
		}
		else if (v.sibling<ecs::generator>()) {
			// It's a generator, and must be not a consumer
			auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
			float eff = pg[c.network].generator_efficiency[std::to_underlying(priority)];
			if (eff > 0) {
				uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
				uint32_t power = (uint32_t)((capacitance - c.shortage) * eff);
				c.delta = power;
				c.shortage += power;
				generate_power += power;
				continue;
			}
		}
		else if (pg[c.network].accumulator_efficiency != 0 && v.sibling<ecs::accumulator>()) {
			float eff = pg[c.network].accumulator_efficiency;
			if (eff > 0) {
				// discharge
				uint32_t power = prototype::get<"power">(w, building.prototype);
				uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
				uint32_t remain = capacitance - c.shortage;
				power = (uint32_t)(power * eff);
				if (remain < power) {
					power = remain;
				}
				c.delta = power;
				c.shortage += power;
				generate_power += power;
				continue;
			} else {
				// charge
				eff = -eff;
				uint32_t charge_power = prototype::get<"charge_power">(w, building.prototype);
				charge_power = (uint32_t)(charge_power * eff);
				if (charge_power >= c.shortage) {
					charge_power = c.shortage;
				}
				c.delta = -(int32_t)charge_power;
				c.shortage -= charge_power;
				consume_power += charge_power;
				continue;
			}
		}
		c.delta = 0;
	}

	w.stat.generate_power = generate_power;
	w.stat.consume_power = consume_power;
}

static int
lupdate(lua_State *L) {
	// step 1: init powergrid runtime struct
    auto& w = getworld(L);
	struct powergrid pg[256];

	// step 2: stat consumers in powergrid
	stat_consumer(w, pg);
	// step 3: stat generators
	stat_generator(w, pg);
	// step 4: stat accumulators
	stat_accumulator(w, pg);
	// step 5: calc efficiency
	calc_efficiency(w, pg);
	// step 6: powergrid charge consumers' capacitance, and consume generators' capacitance
	powergrid_run(w, pg);

	return 0;
}

extern "C" int
luaopen_vaststars_powergrid_system(lua_State *L) {
	luaL_checkversion(L);

	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
