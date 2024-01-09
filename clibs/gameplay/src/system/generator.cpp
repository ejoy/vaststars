#include <lua.hpp>
#include <assert.h>
#include <string.h>

#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
#include "util/prototype.h"

static constexpr uint16_t UPS        = 30;
static constexpr uint16_t DuskTick   = 100 * UPS;
static constexpr uint16_t NightTick  =  50 * UPS + DuskTick;
static constexpr uint16_t DawnTick   = 100 * UPS + NightTick;
static constexpr uint16_t DayTick    = 250 * UPS + DawnTick;
static constexpr uint16_t FixedPoint = 100 * UPS;

static_assert(FixedPoint == DuskTick);
static_assert(FixedPoint == (DawnTick - NightTick));
static_assert(FixedPoint / UPS == 100);

static uint16_t solar_efficiency(uint16_t time) {
    if (time < DuskTick) {
        return DuskTick - time;
    }
    if (time < NightTick) {
        return 0;
    }
    if (time < DawnTick) {
        return time - NightTick;
    }
    return FixedPoint;
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    w.time++;
    uint8_t efficiency = solar_efficiency(w.time % DayTick) / UPS;
    for (auto& v : ecs::select<component::solar_panel, component::capacitance, component::building>(w.ecs)) {
        auto& solar_panel = v.get<component::solar_panel>();
        solar_panel.efficiency = efficiency;
        if (efficiency != 0) {
            auto generator = get_generator(w, v);
            generator.force_produce(efficiency, 100);
        }
    }
    
    for (auto& v : ecs::select<component::wind_turbine, component::capacitance, component::building>(w.ecs)) {
        auto generator = get_generator(w, v);
        generator.force_produce();
    }
    return 0;
}

extern "C" int
luaopen_vaststars_generator_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
