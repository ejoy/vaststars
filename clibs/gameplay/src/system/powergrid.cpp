#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "core/world.h"
#include "core/select.h"
#include "core/entity.h"
extern "C" {
#include "util/prototype.h"
}

#define CONSUMER_PRIORITY 2
#define GENERATOR_PRIORITY 2

struct powergrid {
    uint64_t consumer_power[CONSUMER_PRIORITY] = {0};
    uint64_t generator_power[GENERATOR_PRIORITY] = {0};
    uint64_t accumulator_output = 0;
    uint64_t accumulator_input = 0;
    float consumer_efficiency[CONSUMER_PRIORITY] = {0};
    float generator_efficiency[GENERATOR_PRIORITY] = {0};
    float accumulator_efficiency = 0.f;
	bool active = false;
};

static void
stat_consumer(lua_State *L, world& w, powergrid pg[]) {
	struct prototype_context p = w.prototype(0);
	for (auto& v : w.select<consumer, capacitance, entity>()) {
		capacitance& c = v.get<capacitance>();
		if (c.network == 0) {
			continue;
		}
		entity& e = v.get<entity>();
		p.id = e.prototype;
		unsigned int priority = pt_priority(&p);
		unsigned int power = pt_power(&p);
		unsigned int charge = c.shortage < power ? c.shortage : power;
		pg[c.network].consumer_power[priority] += charge;
		pg[c.network].active = true;
	}
}

static void
stat_generator(lua_State *L, world& w, powergrid pg[]) {
	struct prototype_context p = w.prototype(0);
	for (auto& v : w.select<ecs::tag::generator, capacitance, entity>()) {
		capacitance& c = v.get<capacitance>();
		if (c.network == 0) {
			continue;
		}
		entity& e = v.get<entity>();
		p.id = e.prototype;
		unsigned int priority = pt_priority(&p);
		unsigned int capacitance = pt_capacitance(&p);
		pg[c.network].generator_power[priority] += capacitance - c.shortage;
		pg[c.network].active = true;
	}
}

static void
stat_accumulator(lua_State *L, world& w, powergrid pg[]) {
	struct prototype_context p = w.prototype(0);
	for (auto& v : w.select<ecs::tag::accumulator, capacitance, entity>()) {
		capacitance& c = v.get<capacitance>();
		if (c.network == 0) {
			continue;
		}
		entity& e = v.get<entity>();
		p.id = e.prototype;
		unsigned int power = pt_power(&p);
		if (c.shortage == 0) {
			// battery is full
			pg[c.network].accumulator_output += power;
		} else {
			unsigned int charge_power = pt_charge_power(&p);
			pg[c.network].accumulator_input += (c.shortage <= charge_power) ? c.shortage : charge_power;
			unsigned int capacitance_remain = pt_capacitance(&p) - c.shortage;
			pg[c.network].accumulator_output += (capacitance_remain <= power) ? capacitance_remain : power;
		}
		pg[c.network].active = true;
	}
}

static void
calc_efficiency(lua_State *L, world& w, powergrid pgs[]) {
	for (int i = 1; i < 256; ++i) {
		powergrid& pg = pgs[i];
		if (!pg.active) {
			break;
		}
		uint64_t need_power = 0;
		for (int i=0;i<CONSUMER_PRIORITY;i++) {
			need_power += pg.consumer_power[i];
		}
		uint64_t offer_power = 0;
		for (int i=0;i<GENERATOR_PRIORITY;i++) {
			offer_power += pg.generator_power[i];
		}

		if (need_power > offer_power) {
			// power is not enough, all generator efficiency are 100%
			for (i=0;i<GENERATOR_PRIORITY;i++) {
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
				for (i=0;i<CONSUMER_PRIORITY;i++) {
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
				for (i=0;i<CONSUMER_PRIORITY;i++) {
					pg.consumer_efficiency[i] = 1.0f;
				}
			}
		} else {
			// power is enough, all consumer efficiency are 100%
			for (i=0;i<CONSUMER_PRIORITY;i++) {
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
				for (i=0;i<GENERATOR_PRIORITY;i++) {
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
				for (i=0;i<GENERATOR_PRIORITY;i++) {
					pg.generator_efficiency[i] = 1.0f;
				}
			}
		}
	}
}

static void
powergrid_run(lua_State *L, world& w, powergrid pg[]) {
	struct prototype_context p = w.prototype(0);
	uint64_t generate_power = 0;
	uint64_t consume_power = 0;
	for (auto& v : w.select<capacitance, entity>()) {
		capacitance& c = v.get<capacitance>();
		if (c.network == 0 || !pg[c.network].active) {
			continue;
		}
		entity& e = v.get<entity>();
		p.id = e.prototype;
		if (w.sibling<consumer>(v)) {
			// It's a consumer, charge capacitance
			if (c.shortage > 0) {
				float eff = pg[c.network].consumer_efficiency[pt_priority(&p)];
				if (eff > 0) {
					// charge
					uint32_t power = pt_power(&p);
					if (c.shortage <= power) {
						if (eff >= 1.0f) {
							power = c.shortage;	// full charge
						} else {
							power = (uint32_t)(c.shortage * eff);
						}
					} else {
						power = (uint32_t)(power * eff);
					}
					c.shortage -= power;
					consume_power += power;
				}
			}
		}
		else if (w.sibling<ecs::tag::generator>(v)) {
			// It's a generator, and must be not a consumer
			float eff = pg[c.network].generator_efficiency[pt_priority(&p)];
			if (eff > 0) {
				uint32_t power = (uint32_t)((pt_capacitance(&p) - c.shortage) * eff);
				c.shortage += power;
				generate_power += power;
			}
		}
		else if (pg[c.network].accumulator_efficiency != 0 && w.sibling<ecs::tag::accumulator>(v)) {
			float eff = pg[c.network].accumulator_efficiency;
			if (eff > 0) {
				// discharge
				unsigned int capacitance = pt_capacitance(&p); 
				unsigned int remain = capacitance - c.shortage;
				uint32_t power = (uint32_t)(pt_power(&p) * eff);
				if (remain < power) {
					power = remain;
				}
				c.shortage += power;
				generate_power += power;
			} else {
				// charge
				eff = -eff;
				uint32_t charge_power = (uint32_t)(pt_charge_power(&p) * eff);
				if (charge_power >= c.shortage) {
					charge_power = c.shortage;
				}
				c.shortage -= charge_power;
				consume_power += charge_power;
			}
		}

	}

	w.stat.generate_power = generate_power;
	w.stat.consume_power = consume_power;
}

static int
lupdate(lua_State *L) {
	// step 1: init powergrid runtime struct
	struct world& w = *(struct world *)lua_touserdata(L, 1);
	struct powergrid pg[256];

	// step 2: stat consumers in powergrid
	stat_consumer(L, w, pg);
	// step 3: stat generators
	stat_generator(L, w, pg);
	// step 4: stat accumulators
	stat_accumulator(L, w, pg);
	// step 5: calc efficiency
	calc_efficiency(L, w, pg);
	// step 6: powergrid charge consumers' capacitance, and consume generators' capacitance
	powergrid_run(L, w, pg);

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
