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
static_assert(std::extent_v<decltype(component::powergrid::consumer_power)> == POWER_PRIORITY);
static_assert(std::extent_v<decltype(component::powergrid::generator_power)> == POWER_PRIORITY);
static_assert(std::extent_v<decltype(component::powergrid::consumer_efficiency)> == POWER_PRIORITY);
static_assert(std::extent_v<decltype(component::powergrid::generator_efficiency)> == POWER_PRIORITY);

static void
stat_consumer(world& w, std::span<component::powergrid> pg) {
	for (auto& v : ecs::select<component::consumer, component::capacitance, component::building>(w.ecs)) {
		component::capacitance& c = v.get<component::capacitance>();
		if (c.network == 0) {
			continue;
		}
		component::building& building = v.get<component::building>();
		auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
		uint32_t power = prototype::get<"power">(w, building.prototype);
		uint32_t charge = c.shortage < power ? c.shortage : power;
		pg[c.network].consumer_power[std::to_underlying(priority)] += charge;
		pg[c.network].active = true;
	}
}

static void
stat_generator(world& w, std::span<component::powergrid> pg) {
	for (auto& v : ecs::select<component::generator, component::capacitance, component::building>(w.ecs)) {
		component::capacitance& c = v.get<component::capacitance>();
		if (c.network == 0) {
			continue;
		}
		component::building& building = v.get<component::building>();
		auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
		uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
		pg[c.network].generator_power[std::to_underlying(priority)] += capacitance - c.shortage;
		pg[c.network].active = true;
	}
}

static void
stat_accumulator(world& w, std::span<component::powergrid> pg) {
	for (auto& v : ecs::select<component::accumulator, component::capacitance, component::building>(w.ecs)) {
		component::capacitance& c = v.get<component::capacitance>();
		if (c.network == 0) {
			continue;
		}
		component::building& building = v.get<component::building>();
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
calc_efficiency(world& w, std::span<component::powergrid> pgs) {
	auto& frame = w.stat.current();
	for (int ii = 1; ii < 256; ++ii) {
		component::powergrid& pg = pgs[ii];
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
				frame.power += offer_power + pg.accumulator_output;
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
				frame.power += offer_power + need_power;
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
				frame.power += need_power + pg.accumulator_input;
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
				frame.power += need_power + offer_power;
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
powergrid_run(world& w, std::span<component::powergrid> pg) {
	auto& frame = w.stat.current();
	for (auto& v : ecs::select<component::capacitance, component::building>(w.ecs)) {
		component::capacitance& c = v.get<component::capacitance>();
		if (c.network == 0 || !pg[c.network].active) {
			c.delta = 0;
			continue;
		}
		component::building& building = v.get<component::building>();
		if (v.component<component::consumer>()) {
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
					stat_add(frame.consume_power, building.prototype, (uint64_t)power);
					continue;
				}
			}
		}
		else if (v.component<component::generator>()) {
			// It's a generator, and must be not a consumer
			auto priority = prototype::get<"priority", power_priority>(w, building.prototype);
			float eff = pg[c.network].generator_efficiency[std::to_underlying(priority)];
			if (eff > 0) {
				uint32_t capacitance = prototype::get<"capacitance">(w, building.prototype);
				uint32_t power = (uint32_t)((capacitance - c.shortage) * eff);
				c.delta = power;
				c.shortage += power;
				stat_add(frame.generate_power, building.prototype, (uint64_t)power);
				continue;
			}
		}
		else if (pg[c.network].accumulator_efficiency != 0 && v.component<component::accumulator>()) {
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
				stat_add(frame.generate_power, building.prototype, (uint64_t)power);
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
				stat_add(frame.consume_power, building.prototype, (uint64_t)charge_power);
				continue;
			}
		}
		c.delta = 0;
	}
}

static int
linit(lua_State *L) {
	auto& w = getworld(L);
	struct component::powergrid init;
	for (size_t i = 0; i < POWER_PRIORITY; ++i) {
		init.consumer_power[i] = 0;
		init.generator_power[i] = 0;
		init.consumer_efficiency[i] = 0.f;
		init.generator_efficiency[i] = 0.f;
	}
	init.accumulator_output = 0;
	init.accumulator_input = 0;
	init.accumulator_efficiency = 0.f;
	init.active = false;
	for (size_t i = 0; i < 256; ++i) {
		ecs::create_entity<component::powergrid>(w.ecs, init);
	}
	return 0;
}

static int
lupdate(lua_State *L) {
	auto& w = getworld(L);
	// step 1: init component::powergrid runtime struct
	auto pgs = ecs::array<component::powergrid>(w.ecs);
	for (int ii = 1; ii < 256; ++ii) {
		component::powergrid& pg = pgs[ii];
		for (size_t i = 0; i < POWER_PRIORITY; ++i) {
			pg.consumer_power[i] = 0;
			pg.generator_power[i] = 0;
		}
		pg.accumulator_output = 0;
		pg.accumulator_input = 0;
		pg.active = false;
	}
	// step 2: stat consumers in component::powergrid
	stat_consumer(w, pgs);
	// step 3: stat generators
	stat_generator(w, pgs);
	// step 4: stat accumulators
	stat_accumulator(w, pgs);
	// step 5: calc efficiency
	calc_efficiency(w, pgs);
	// step 6: component::powergrid charge consumers' capacitance, and consume generators' capacitance
	powergrid_run(w, pgs);
	return 0;
}

extern "C" int
luaopen_vaststars_powergrid_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "init", linit },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
