#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}

static constexpr size_t kStationMaxLorry = std::extent_v<decltype(ecs::station::lorry)>;
static constexpr size_t kParkMaxLorry = std::extent_v<decltype(ecs::park::lorry)>;
static_assert(kParkMaxLorry <= kStationMaxLorry);

static void charge(lua_State* L, world& w, ecs_api::entity<ecs::station, ecs::park, ecs::entity, ecs::capacitance>& v) {
	auto consumer = get_consumer(L, w, v);
	if (!consumer.cost_drain()) {
		return;
	}
	auto& station = v.get<ecs::station>();
	if (station.count == 0) {
		return;
	}
	roadnet::lorryid lorryId {station.lorry[0]};
	if (!consumer.cost_power()) {
		return;
	}
	auto& l = w.rw.Lorry(lorryId);
	l.capacitance += consumer.power;

	auto pt = w.prototype(L, l.classid);
	auto max = pt_capacitance(&pt);
	if (l.capacitance >= max) {
		auto& park = v.get<ecs::park>();
		park.lorry[park.count++] = l.classid;
		w.rw.destroyLorry(w, lorryId);
		station.count--;
		for (size_t i = 0; i < station.count; ++i) {
			station.lorry[i] = station.lorry[i+1];
		}
	}
}

static void entry(lua_State* L, world& w, ecs::station& station, ecs::park& park) {
	if (station.endpoint == roadnet::endpointid::invalid()) {
		return;
	}
	auto& ep = w.rw.Endpoint(station.endpoint);
	auto lorryId = ep.getWaitLorry();
	if (!lorryId) {
		return;
	}
	if (station.count + park.count >= kParkMaxLorry) {
		return;
	}
	station.lorry[station.count++] = lorryId.id;
	ep.delWaitLorry();
}

#define STATUS_IDLE 0
#define STATUS_DONE 1

static int lupdate(lua_State *L) {
	world& w = *(world*)lua_touserdata(L, 1);
	for (auto& v : ecs_api::select<ecs::station, ecs::park, ecs::entity, ecs::capacitance>(w.ecs)) {
		charge(L, w, v);
		entry(L, w, v.get<ecs::station>(), v.get<ecs::park>());
	}
	for (auto& v : ecs_api::select<ecs::lorry_factory, ecs::park, ecs::assembling>(w.ecs)) {
		auto& assembling = v.get<ecs::assembling>();
		auto& park = v.get<ecs::park>();
		if (park.count >= 1) {
			continue;
		}
		if (assembling.progress < 0) {
			if (assembling.status == STATUS_DONE) {
				prototype_context recipe = w.prototype(L, assembling.recipe);
				recipe_items* results = (recipe_items*)pt_results(&recipe);
				if (results->n > 0) {
					w.stat.finish_recipe(L, w, assembling.recipe, false);
					assembling.status = STATUS_IDLE;
					for (size_t i = 0; i < results->n; ++i) {
						uint16_t classid = results->items[i].item;
						for (size_t j = 0; j < results->items[i].amount; ++j) {
							if (park.count < kParkMaxLorry) {
								park.lorry[park.count++] = classid;
							}
						}
					}
				}
			}
		}
	}
	return 0;
}

extern "C" int
luaopen_vaststars_endpoint_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
