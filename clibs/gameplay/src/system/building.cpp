#include <lua.hpp>

#include "luaecs.h"
#include "core/world.h"
#include "system/building.h"
#include "util/prototype.h"

static uint16_t getxy(uint8_t x, uint8_t y) {
    return ((uint16_t)x << 8) | (uint16_t)y;
}

building createBuildingCache(world& w, component::building& b, uint16_t chest) {
    uint16_t area = prototype::get<"area">(w, b.prototype);
    uint8_t width = area >> 8;
    uint8_t height = area & 0xFF;
    switch (b.direction) {
    case 0: // N
    case 2: // S
        break;
    case 1: // E
    case 3: // W
        std::swap(width, height);
        break;
    default:
        std::unreachable();
    }
    return {
        0, 0,
        chest,
        width,
        height,
    };
}

static void rebuild(world& w) {
    w.buildings.clear();
    for (auto& v : ecs_api::select<component::chest, component::building>(w.ecs)) {
        auto& chest = v.get<component::chest>();
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        auto& b = v.get<component::building>();
        w.buildings.insert_or_assign(getxy(b.x, b.y), createBuildingCache(w, b, chest.chest));
    }
}

static int lbuild(lua_State* L) {
    auto& w = getworld(L);
    if (!(w.dirty & kDirtyChest)) {
        return 0;
    }
    rebuild(w);
    return 0;
}

extern "C" int
luaopen_vaststars_building_system(lua_State *L) {
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
