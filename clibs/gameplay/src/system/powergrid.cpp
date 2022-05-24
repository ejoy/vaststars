#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "system/powergrid.h"
#include "core/world.h"
#include "core/entity.h"
extern "C" {
#include "util/prototype.h"
}

static void
stat_consumer(lua_State *L, world& w) {
	int i;
	struct powergrid *pg = &w.powergrid;
	struct ecs_context *ctx = w.c.ecs;
	struct prototype_context p = w.prototype(0);
	for (i=0;entity_iter(ctx, TAG_CONSUMER, i);i++) {
		struct entity *e = (struct entity *)entity_sibling(ctx, TAG_CONSUMER, i, COMPONENT_ENTITY);
		if (e == NULL)
			luaL_error(L, "No entity");
		p.id = e->prototype;
		struct capacitance *c = (struct capacitance *)entity_sibling(ctx, TAG_CONSUMER, i, COMPONENT_CAPACITANCE);
		if (c == NULL)
			luaL_error(L, "No capacitance");

		unsigned int power = pt_power(&p);
		unsigned int charge = c->shortage < power ? c->shortage : power;
		int priority = pt_priority(&p);
		pg->consumer_power[priority] += charge;
//		printf("Charge priority %d %f\n", priority, charge);
	}
}

static void
stat_generator(lua_State *L, world& w) {
	struct powergrid *pg = &w.powergrid;
	struct ecs_context *ctx = w.c.ecs;
	struct prototype_context p = w.prototype(0);
	int i;
	for (i=0;entity_iter(ctx, TAG_GENERATOR, i);i++) {
		struct entity *e = (struct entity *)entity_sibling(ctx, TAG_GENERATOR, i, COMPONENT_ENTITY);
		if (e == NULL)
			luaL_error(L, "No entity");
		p.id = e->prototype;
		struct capacitance *c = (struct capacitance *)entity_sibling(ctx, TAG_GENERATOR, i, COMPONENT_CAPACITANCE);
		if (c == NULL)
			luaL_error(L, "No capacitance");
		uint64_t capacitance = pt_capacitance(&p);
		int priority = pt_priority(&p);
		pg->generator_power[priority] += capacitance - c->shortage;
	}
}

static void
stat_accumulator(lua_State *L, world& w) {
	struct powergrid *pg = &w.powergrid;
	struct ecs_context *ctx = w.c.ecs;
	struct prototype_context p = w.prototype(0);
	int i;
	for (i=0;entity_iter(ctx, TAG_ACCUMULATOR, i);i++) {
		struct entity *e = (struct entity *)entity_sibling(ctx, TAG_ACCUMULATOR, i, COMPONENT_ENTITY);
		if (e == NULL)
			luaL_error(L, "No entity");
		p.id = e->prototype;
		struct capacitance *c = (struct capacitance *)entity_sibling(ctx, TAG_ACCUMULATOR, i, COMPONENT_CAPACITANCE);
		if (c == NULL)
			luaL_error(L, "No capacitance");
		unsigned int power = pt_power(&p);
		if (c->shortage == 0) {
			// battery is full
			pg->accumulator_output += power;
		} else {
			unsigned int charge_power = pt_charge_power(&p);
			pg->accumulator_input += (c->shortage <= charge_power) ? c->shortage : charge_power;
			unsigned int capacitance_remain = pt_capacitance(&p) - c->shortage;
			pg->accumulator_output += (capacitance_remain <= power) ? capacitance_remain : power;
		}
	}
}

static void
calc_efficiency(lua_State *L, world& w) {
	// todo : solar
	struct powergrid *pg = &w.powergrid;
	int i;
	float need_power = 0;
	for (i=0;i<CONSUMER_PRIORITY;i++) {
		need_power += pg->consumer_power[i];
	}
	float offer_power = 0;
	for (i=0;i<GENERATOR_PRIORITY;i++) {
		offer_power += pg->generator_power[i];
	}
	if (need_power > offer_power) {
		// power is not enough, all generator efficiency are 100%
		for (i=0;i<GENERATOR_PRIORITY;i++) {
			pg->generator_efficiency[i] = 1.0f;
		}

		need_power -= offer_power;
		// accumulator output
		if (need_power >= pg->accumulator_output) {
			if (pg->accumulator_output == 0) {
				pg->accumulator_efficiency = 0;
			} else {
				pg->accumulator_efficiency = 1.0f;
				offer_power += pg->accumulator_output;
			}
			for (i=0;i<CONSUMER_PRIORITY;i++) {
				if (offer_power == 0) {
					// no power
					pg->consumer_efficiency[i] = 0;
				} else if (offer_power >= pg->consumer_power[i]) {
					// P[i] is satisfied
					pg->consumer_efficiency[i] = 1.0f;
					offer_power -= pg->consumer_power[i];
				} else {
					pg->consumer_efficiency[i] = offer_power / pg->consumer_power[i];
					offer_power = 0;
				}
			}
		} else {
			pg->accumulator_efficiency = need_power / pg->accumulator_output;
			// power is enough now.
			for (i=0;i<CONSUMER_PRIORITY;i++) {
				pg->consumer_efficiency[i] = 1.0f;
			}
		}
	} else {
		// power is enough, all consumer efficiency are 100%
		for (i=0;i<CONSUMER_PRIORITY;i++) {
			pg->consumer_efficiency[i] = 1.0f;
		}
		offer_power -= need_power;
		// charge accumulators
		if (offer_power >= pg->accumulator_input) {
			if (pg->accumulator_input == 0) {
				pg->accumulator_efficiency = 0;
			} else {
				pg->accumulator_efficiency = -1.0f;
				need_power += pg->accumulator_input;
			}
			for (i=0;i<GENERATOR_PRIORITY;i++) {
				if (need_power == 0) {
					// Don't need power yet
					pg->generator_efficiency[i] = 0;
				} else if (need_power >= pg->generator_power[i]) {
					// P[i] should full output
					pg->generator_efficiency[i] = 1.0f;
					need_power -= pg->generator_power[i];
				} else {
					pg->generator_efficiency[i] = need_power / pg->generator_power[i];
					need_power = 0;
				}
			}
		} else {
			pg->accumulator_efficiency = -offer_power / pg->accumulator_input;
			// part charge, generators full output
			for (i=0;i<GENERATOR_PRIORITY;i++) {
				pg->generator_efficiency[i] = 1.0f;
			}
		}
	}
}

static void
powergrid_run(lua_State *L, world& w) {
	struct powergrid *pg = &w.powergrid;
	struct ecs_context *ctx = w.c.ecs;
	struct prototype_context p = w.prototype(0);
	int i;
	struct capacitance * c;
	for (i=0;(c = (struct capacitance *)entity_iter(ctx, COMPONENT_CAPACITANCE, i));i++) {
		struct entity *e = (struct entity *)entity_sibling(ctx, COMPONENT_CAPACITANCE, i, COMPONENT_ENTITY);
		if (e == NULL)
			luaL_error(L, "No entity");
		p.id = e->prototype;
		if (entity_sibling(ctx, COMPONENT_CAPACITANCE, i, TAG_CONSUMER)) {
			// It's a consumer, charge capacitance
			if (c->shortage > 0) {
				float eff = pg->consumer_efficiency[pt_priority(&p)];
				if (eff > 0) {
					// charge
					unsigned int power = pt_power(&p);
					if (c->shortage <= power) {
						if (eff >= 1.0f) {
							c->shortage = 0;	// full charge
						} else {
							c->shortage -= (uint32_t)(c->shortage * eff);
						}
					} else {
						c->shortage -= (uint32_t)(power * eff);
					}
				}
			}
		} else if (entity_sibling(ctx, COMPONENT_CAPACITANCE, i, TAG_GENERATOR)) {
			// It's a generator, and must be not a consumer
			float eff = pg->generator_efficiency[pt_priority(&p)];
			if (eff > 0) {
				uint32_t consume_energy = (uint32_t)((pt_capacitance(&p) - c->shortage) * eff);
				c->shortage += consume_energy;
			}
		} else if (pg->accumulator_efficiency != 0 &&
			entity_sibling(ctx, COMPONENT_CAPACITANCE, i, TAG_ACCUMULATOR)) {
			float eff = pg->accumulator_efficiency;
			if (eff > 0) {
				// discharge
				unsigned int capacitance = pt_capacitance(&p); 
				unsigned int remain = capacitance - c->shortage;
				uint32_t power = (uint32_t)(pt_power(&p) * eff);
				if (remain >= power) {
					c->shortage += power;
				} else {
					c->shortage = capacitance;
				}
			} else {
				// charge
				eff = -eff;
				uint32_t charge_power = (uint32_t)(pt_charge_power(&p) * eff);
				if (charge_power >= c->shortage) {
					c->shortage = 0;
				} else {
					c->shortage -= charge_power;
				}
			}
		}
	}
}

static int
lupdate(lua_State *L) {
	// step 1: init powergrid runtime struct
	struct world& w = *(struct world *)lua_touserdata(L, 1);
	memset(&w.powergrid, 0, sizeof(w.powergrid));

	// step 2: stat consumers in powergrid
	stat_consumer(L, w);
	// step 3: stat generators
	stat_generator(L, w);
	// step 4: stat accumulators
	stat_accumulator(L, w);
	// step 5: calc efficiency
	calc_efficiency(L, w);
	// step 6: powergrid charge consumers' capacitance, and consume generators' capacitance
	powergrid_run(L, w);

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
