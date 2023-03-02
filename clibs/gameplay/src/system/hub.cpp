#include <lua.hpp>
#include "system/hub.h"
#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}
#include <bee/nonstd/unreachable.h>

template <typename Map>
static typename Map::mapped_type const* map_find(Map const& map, typename Map::key_type const& key) {
    auto it = map.find(key);
    if (it == map.end()) {
        return nullptr;
    }
    return &it->second;
}

struct building_rect {
    uint8_t x1, x2, y1, y2;
    building_rect(uint8_t x, uint8_t y, uint8_t direction, uint16_t area) {
        uint8_t w = area >> 8;
        uint8_t h = area & 0xFF;
        assert(w > 0 && h > 0);
        w--;
        h--;
        switch (direction) {
        case 0: // N
            x1 = x; x2 = x + w;
            y1 = y; y2 = y + h;
            break;
        case 1: // E
            x1 = x - h; x2 = x;
            y1 = y; y2 = y + w;
            break;
        case 2: // S
            x1 = x - w; x2 = x;
            y1 = y - h; y2 = y;
            break;
        case 3: // W
            x1 = x; x2 = x + h;
            y1 = y - w; y2 = y;
            break;
        default:
            std::unreachable();
        }
    }
    building_rect(ecs::building const& b, uint16_t area)
        : building_rect(b.x, b.y, b.direction, area)
    {}
    void each(std::function<void(uint8_t,uint8_t)> f) {
        for (uint8_t i = x1; i <= x2; ++i)
            for (uint8_t j = y1; j <= y2; ++j)
                f(i, j);
    }
    uint32_t hash() const;
};

static hub_mgr::berth create_berth(building_rect const& r, hub_mgr::berth_type type, uint8_t chest, uint8_t berth = 0) {
    return {
        0
        , (uint32_t)type
        , chest
        , berth
        , (uint32_t)r.y1+(uint32_t)r.y2
        , (uint32_t)r.x1+(uint32_t)r.x2
    };
}

uint32_t building_rect::hash() const {
    hub_mgr::berth berth = create_berth(*this, (hub_mgr::berth_type)0, 0);
    return *(uint32_t*)&berth;
}

static uint16_t getxy(uint8_t x, uint8_t y) {
    return ((uint16_t)x << 8) | (uint16_t)y;
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    auto& b = w.buildings;
    b.chests.clear();
    std::map<uint16_t, std::map<uint16_t, hub_mgr::berth>> globalmap;
    for (auto& v : ecs_api::select<ecs::building>(w.ecs)) {
        auto& building = v.get<ecs::building>();
        prototype_context pt = w.prototype(L, building.prototype);
        uint16_t area = (uint16_t)pt_area(&pt);
        building_rect r(building, area);
        if (auto phub = v.sibling<ecs::hub>()) {
            auto& hub = *phub;
            auto& chestslot = chest::getslot(w, container::index::from(hub.chest), 0);
            auto item = chestslot.item;
            auto berth = create_berth(r, hub_mgr::berth_type::hub, 0);
            auto& map = globalmap[item];
            r.each([&](uint8_t x, uint8_t y) {
                map[getxy(x, y)] = berth;
            });
            b.chests.insert_or_assign(r.hash(), hub.chest);
        }
        else if (auto pchest = v.sibling<ecs::chest>()) {
            auto& chest = *pchest;
            b.chests.insert_or_assign(r.hash(), chest.chest);
            for (uint8_t i = 0; ; ++i) {
                auto& chestslot = chest::getslot(w, container::index::from(chest.chest), i);
                auto item = chestslot.item;
                hub_mgr::berth_type type;
                if (chestslot.type == container::slot::slot_type::red) {
                    type = hub_mgr::berth_type::chest_red;
                }
                else if (chestslot.type == container::slot::slot_type::blue) {
                    type = hub_mgr::berth_type::chest_blue;
                }
                else {
                    continue;
                }
                auto berth = create_berth(r, type, i);
                auto& map = globalmap[item];
                r.each([&](uint8_t x, uint8_t y) {
                    map[getxy(x, y)] = berth;
                });
                if (chestslot.eof) {
                    break;
                }
            }
        }
    }
    b.hubs.clear();
    for (auto& v : ecs_api::select<ecs::hub, ecs::building, ecs::eid>(w.ecs)) {
        auto hub = v.get<ecs::hub>();
        auto& chestslot = chest::getslot(w, container::index::from(hub.chest), 0);
        auto& building = v.get<ecs::building>();
        prototype_context pt = w.prototype(L, building.prototype);
        uint16_t supply_area = (uint16_t)pt_supply_area(&pt);
        building_rect r(building, supply_area);
        auto& map = globalmap[chestslot.item];
        auto self = create_berth(r, hub_mgr::berth_type::hub, 0);
        flatset<hub_mgr::berth> set;
        r.each([&](uint8_t x, uint8_t y) {
            if (auto pm = map_find(map, getxy(x, y))) {
                auto m = *pm;
                set.insert(m);
            }
        });
        hub_mgr::hub_info hub_info;
        hub_info.item = chestslot.item;
        for (auto const& m: set) {
            auto const& h = m.first;
            switch ((hub_mgr::berth_type)h.type) {
            case hub_mgr::berth_type::hub:
                hub_info.hub.emplace_back(h);
                break;
            case hub_mgr::berth_type::chest_red:
                hub_info.chest_red.emplace_back(h);
                break;
            case hub_mgr::berth_type::chest_blue:
                hub_info.chest_blue.emplace_back(h);
                break;
            }
        }
        if (hub_info.hub.size() <= 1) {
            if (hub_info.chest_red.empty() || hub_info.chest_blue.empty()) {
                continue;
            }
        }
        b.hubs.emplace(std::move(self), std::move(hub_info));
    }
    return 0;
}

enum class drone_status : uint8_t {
    idle,
    mov1,
    mov2,
    home,
};

static void Move(lua_State* L, world& w, ecs::drone& drone, uint32_t target) {
    drone.next = target;
    uint8_t x1 = (drone.prev >> 9) & 0xF;
    uint8_t y1 = (drone.prev >> 0) & 0xF;
    uint8_t x2 = (drone.next >> 9) & 0xF;
    uint8_t y2 = (drone.next >> 0) & 0xF;
    uint8_t dx = (x1>x2)? (x1-x2): (x2-x1);
    uint8_t dy = (y1>y2)? (y1-y2): (y2-y1);
    float z = sqrt((float)dx*(float)dx+(float)dy*(float)dy) / 2.f;
    prototype_context p = w.prototype(L, drone.classid);
    int speed = pt_speed(&p);
    drone.maxprogress = drone.progress = uint16_t(z*1000/speed);
}

static void DoTask(lua_State* L, world& w, ecs::drone& drone, uint16_t item, hub_mgr::berth const& mov1, hub_mgr::berth const& mov2) {
    //do something
    drone.status = (uint8_t)drone_status::mov1;
    drone.item = item;
    drone.mov2 = mov2.toint();
    Move(L, w, drone, mov1.toint());
}

static size_t FindChestRed(world& w, const hub_mgr::hub_info& info) {
    size_t N = info.chest_red.size();
    for (size_t i = 0; i < N; ++i) {
        auto berth = info.chest_red[(i + w.time) % N];
        if (auto chest = w.buildings.chests.find(berth.hash())) {
            auto& chestslot = chest::getslot(w, container::index::from(*chest), berth.slot);
            if (chestslot.item > 0) {
                return i;
            }
        }
    }
    return (size_t)-1;
}

static size_t FindChestBlue(world& w, const hub_mgr::hub_info& info) {
    size_t N = info.chest_blue.size();
    for (size_t i = 0; i < N; ++i) {
        auto berth = info.chest_blue[(i + w.time) % N];
        if (auto chest = w.buildings.chests.find(berth.hash())) {
            auto& chestslot = chest::getslot(w, container::index::from(*chest), berth.slot);
            if (chestslot.limit > chestslot.item) {
                return i;
            }
        }
    }
    return (size_t)-1;
}

static std::tuple<size_t, size_t, bool> FindHub(world& w, const hub_mgr::hub_info& info) {
    struct hub_find {
        size_t index = -1;
        uint16_t amount = 0;
    };
    hub_find min;
    hub_find max;
    size_t N = info.hub.size();
    for (size_t i = 0; i < N; ++i) {
        auto berth = info.hub[(i + w.time) % N];
        if (auto chest = w.buildings.chests.find(berth.hash())) {
            auto& chestslot = chest::getslot(w, container::index::from(*chest), berth.slot);
            if (min.index == -1 || ((chestslot.amount < min.amount) && (chestslot.limit > chestslot.item))) {
                min.index = i;
                min.amount = chestslot.amount;
            }
            if (max.index == -1 || chestslot.amount > max.amount) {
                max.index = i;
                max.amount = chestslot.amount;
            }
        }
    }
    bool moveable = min.amount + 2 <= max.amount;
    return {min.index, max.index, moveable};
}

static bool FindTask(lua_State* L, world& w, ecs::drone& drone) {
    hub_mgr::berth home {drone.home};
    if (auto v = map_find(w.buildings.hubs, home)) {
        auto& info = *v;
        auto red = FindChestRed(w, info);
        auto blue = FindChestBlue(w, info);
        // red -> blue
        if (red != (size_t)-1 && blue != (size_t)-1) {
            DoTask(L, w, drone, info.item, info.chest_red[red], info.chest_blue[blue]);
            return true;
        }
        auto [min, max, moveable] = FindHub(w, info);
        // red -> hub
        if (red != (size_t)-1 && min != (size_t)-1) {
            DoTask(L, w, drone, info.item, info.chest_red[red], info.hub[min]);
            return true;
        }
        // hub -> blue
        if (blue != (size_t)-1 && max != (size_t)-1) {
            DoTask(L, w, drone, info.item, info.hub[max], info.chest_blue[blue]);
            return true;
        }
        // hub -> hub
        if (moveable) {
            DoTask(L, w, drone, info.item, info.hub[max], info.hub[min]);
            return true;
        }
    }
    return false;
}

static void Arrival(lua_State* L, world& w, ecs::drone& drone) {
    drone.prev = drone.next;
    switch ((drone_status)drone.status) {
    case drone_status::mov1:
        //do something
        drone.status = (uint8_t)drone_status::mov2;
        Move(L, w, drone, drone.mov2);
        drone.mov2 = 0;
        break;
    case drone_status::mov2:
        //do something
        drone.item = 0;
        if (!FindTask(L, w, drone)) {
            drone.status = (uint8_t)drone_status::home;
            Move(L, w, drone, drone.home);
        }
        break;
    case drone_status::home:
        if (!FindTask(L, w, drone)) {
            drone.status = (uint8_t)drone_status::idle;
            drone.next = 0;
            drone.maxprogress = 0;
        }
        break;
    default:
    case drone_status::idle:
        std::unreachable();
    }
}

static void Update(lua_State* L, world& w, ecs::drone& drone) {
    if (drone.progress > 0) {
        drone.progress--;
    }
    if (drone.progress == 0) {
        Arrival(L, w, drone);
    }
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : ecs_api::select<ecs::drone>(w.ecs)) {
        auto& drone = v.get<ecs::drone>();
        switch ((drone_status)drone.status) {
        case drone_status::idle:
            FindTask(L, w, drone);
            break;
        case drone_status::mov1:
        case drone_status::mov2:
        case drone_status::home:
            Update(L, w, drone);
            break;
        default:
            bee::unreachable();
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_hub_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
