#include <lua.hpp>
#include "system/hub.h"
#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}
#include <bee/nonstd/unreachable.h>
#include <math.h>
#include <algorithm>

template <typename Map>
static typename Map::mapped_type const* map_find(Map const& map, typename Map::key_type const& key) {
    auto it = map.find(key);
    if (it == map.end()) {
        return nullptr;
    }
    return &it->second;
}

static uint8_t safe_add(uint8_t a, uint8_t b) {
    if (b > UINT8_C(255) - a)
        return UINT8_C(255);
    return a + b;
}

static uint8_t safe_sub(uint8_t a, uint8_t b) {
    if (a > b)
        return a - b;
    return UINT8_C(0);
}

struct building_rect {
    uint8_t x1, x2, y1, y2;
    building_rect(uint8_t x, uint8_t y, uint8_t direction, uint16_t area, uint16_t scale_area) {
        uint8_t w = area >> 8;
        uint8_t h = area & 0xFF;
        uint8_t sw = scale_area >> 8;
        uint8_t sh = scale_area & 0xFF;
        assert(w > 0 && h > 0);
        assert(sw > 0 && sh > 0);
        if (sw < w) {
            std::swap(sw, w);
        }
        if (sh < h) {
            std::swap(sh, h);
        }
        w--; sw--;
        h--; sh--;
        uint8_t wl = (sw - w) / 2;
        uint8_t wr = sw - wl;
        uint8_t hl = (sh - h) / 2;
        uint8_t hr = sh - hl;
        switch (direction) {
        case 0: // N
        case 2: // S
            x1 = safe_sub(x, wl); x2 = safe_add(x, wr);
            y1 = safe_sub(y, hl); y2 = safe_add(y, hr);
            break;
        case 1: // E
        case 3: // W
            x1 = safe_sub(x, hl); x2 = safe_add(x, hr);
            y1 = safe_sub(y, wl); y2 = safe_add(y, wr);
            break;
        default:
            std::unreachable();
        }
    }
    building_rect(ecs::building const& b, uint16_t area)
        : building_rect(b.x, b.y, b.direction, area, area)
    {}
    building_rect(ecs::building const& b, uint16_t area, uint16_t scale_area)
        : building_rect(b.x, b.y, b.direction, area, scale_area)
    {}
    void each(std::function<void(uint8_t,uint8_t)> f) {
        for (uint8_t i = x1; i <= x2; ++i)
            for (uint8_t j = y1; j <= y2; ++j)
                f(i, j);
    }
    uint32_t hash() const;
};

static hub_mgr::berth create_berth(building_rect const& r, hub_mgr::berth_type type, uint8_t chest_slot, uint8_t berth_slot = 0) {
    return {
        0
        , (uint32_t)type
        , chest_slot
        , berth_slot
        , (uint32_t)r.y1+(uint32_t)r.y2
        , (uint32_t)r.x1+(uint32_t)r.x2
    };
}

uint32_t building_rect::hash() const {
    hub_mgr::berth berth = create_berth(*this, (hub_mgr::berth_type)0, 0);
    return *(uint32_t*)&berth;
}

enum class drone_status : uint8_t {
    idle,
    mov1,
    mov2,
    home,
    error,
};

static container::slot* GetChestSlot(world& w, hub_mgr::berth const& berth) {
    if (auto chest = w.hubs.chests.find(berth.hash())) {
        return &chest::array_at(w, container::index::from(*chest), berth.chest_slot);
    }
    return nullptr;
}

static container::slot* GetChestSlot(world& w, hub_mgr::berth const& berth, uint16_t item) {
    if (auto chest = w.hubs.chests.find(berth.hash())) {
        return chest::find_item(w, container::index::from(*chest), item);
    }
    return nullptr;
}

static uint16_t getxy(uint8_t x, uint8_t y) {
    return ((uint16_t)x << 8) | (uint16_t)y;
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    auto& b = w.hubs;
    b.chests.clear();
    std::map<uint16_t, std::map<uint16_t, hub_mgr::berth>> globalmap;
    for (auto& v : ecs_api::select<ecs::building>(w.ecs)) {
        auto& building = v.get<ecs::building>();
        prototype_context pt = w.prototype(building.prototype);
        uint16_t area = (uint16_t)pt_area(&pt);
        building_rect r(building, area);
        if (auto phub = v.sibling<ecs::hub>()) {
            auto& hub = *phub;
            auto& chestslot = chest::array_at(w, container::index::from(hub.chest), 0);
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
            auto c = container::index::from(chest.chest);
            auto slice = chest::array_slice(w, c);
            for (uint8_t i = 0; i < slice.size(); ++i) {
                auto& chestslot = slice[i];
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
            }
        }
    }
    b.hubs.clear();
    for (auto& v : ecs_api::select<ecs::hub, ecs::building, ecs::eid>(w.ecs)) {
        auto hub = v.get<ecs::hub>();
        auto& chestslot = chest::array_at(w, container::index::from(hub.chest), 0);
        auto& building = v.get<ecs::building>();
        prototype_context pt = w.prototype(building.prototype);
        uint16_t area = (uint16_t)pt_area(&pt);
        uint16_t supply_area = (uint16_t)pt_supply_area(&pt);
        building_rect r(building, area, supply_area);
        auto& map = globalmap[chestslot.item];
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

        auto s = create_berth({building, area}, hub_mgr::berth_type::hub, 0);
        b.hubs.emplace(std::move(s), std::move(hub_info));
    }
    
    //TODO when remove chest
    for (auto& v : ecs_api::select<ecs::drone>(w.ecs)) {
        auto& drone = v.get<ecs::drone>();
        auto status = (drone_status)drone.status;
        if (status == drone_status::error) {
            continue;
        }
        hub_mgr::berth home = std::bit_cast<hub_mgr::berth>(drone.home);
        if (!map_find(b.hubs, home)) {
            drone.status = (uint8_t)drone_status::error;
            drone.prev = 0;
            drone.next = 0;
            drone.mov2 = 0;
            drone.home = 0;
            drone.maxprogress = 0;
            drone.progress = 0;
            drone.item = 0;
        }
    }

    std::erase_if(b.hubs, [](const auto& v) {
        const auto& hub_info = v.second;
        return hub_info.hub.size() <= 1 && hub_info.chest_red.empty() && hub_info.chest_blue.empty();
    });
    return 0;
}

static void Move(world& w, ecs::drone& drone, uint32_t target) {
    if (!drone.prev) {
        drone.prev = drone.home;
    }
    drone.next = target;
    uint32_t x1 = (drone.prev >> 23) & 0x1FF;
    uint32_t y1 = (drone.prev >> 14) & 0x1FF;
    uint32_t x2 = (drone.next >> 23) & 0x1FF;
    uint32_t y2 = (drone.next >> 14) & 0x1FF;
    uint32_t dx = (x1>x2)? (x1-x2): (x2-x1);
    uint32_t dy = (y1>y2)? (y1-y2): (y2-y1);
    float z = sqrt((float)dx*(float)dx+(float)dy*(float)dy) / 2.f;
    prototype_context p = w.prototype(drone.classid);
    int speed = pt_speed(&p);
    drone.maxprogress = drone.progress = uint16_t(z*1000/speed);
}

static void DoTask(world& w, ecs::drone& drone, const hub_mgr::hub_info& info, hub_mgr::berth const& mov1, hub_mgr::berth const& mov2) {
    {
        //lock mov1
        auto chestslot = GetChestSlot(w, mov1);
        assert(chestslot);
        assert(chestslot->amount > chestslot->lock_item);
        chestslot->lock_item += 1;
    }
    {
        //lock mov2
        auto chestslot = GetChestSlot(w, mov2);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    drone.status = (uint8_t)drone_status::mov1;
    drone.mov2 = std::bit_cast<uint32_t>(mov2);
    Move(w, drone, std::bit_cast<uint32_t>(mov1));
}

static void DoTask(world& w, ecs::drone& drone, const hub_mgr::hub_info& info, hub_mgr::berth const& mov2) {
    {
        //lock mov2
        auto chestslot = GetChestSlot(w, mov2);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    drone.status = (uint8_t)drone_status::mov2;
    drone.mov2 = 0;
    Move(w, drone, std::bit_cast<uint32_t>(mov2));
}

static size_t FindChestRed(world& w, const hub_mgr::hub_info& info) {
    size_t N = info.chest_red.size();
    for (size_t i = 0; i < N; ++i) {
        size_t ii = (i + w.time) % N;
        auto berth = info.chest_red[ii];
        if (auto chest = w.hubs.chests.find(berth.hash())) {
            auto& chestslot = chest::array_at(w, container::index::from(*chest), berth.chest_slot);
            if (chestslot.amount > chestslot.lock_item) {
                return ii;
            }
        }
    }
    return (size_t)-1;
}

static size_t FindChestBlue(world& w, const hub_mgr::hub_info& info) {
    size_t N = info.chest_blue.size();
    for (size_t i = 0; i < N; ++i) {
        size_t ii = (i + w.time) % N;
        auto berth = info.chest_blue[ii];
        if (auto chest = w.hubs.chests.find(berth.hash())) {
            auto& chestslot = chest::array_at(w, container::index::from(*chest), berth.chest_slot);
            if (chestslot.limit > chestslot.amount + chestslot.lock_space) {
                return ii;
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
        size_t ii = (i + w.time) % N;
        auto berth = info.hub[ii];
        if (auto chest = w.hubs.chests.find(berth.hash())) {
            auto& chestslot = chest::array_at(w, container::index::from(*chest), berth.chest_slot);

            auto amount1 = chestslot.amount + chestslot.lock_space - chestslot.lock_item;
            if (((min.index == -1) || (amount1 < min.amount)) && (chestslot.limit > amount1)) {
                min.index = ii;
                min.amount = amount1;
            }

            auto amount2 = chestslot.amount + chestslot.lock_space - chestslot.lock_item;
            if (((max.index == -1) || (amount2 > max.amount)) && (amount2 > 0)) {
                max.index = ii;
                max.amount = amount2;
            }
        }
    }
    bool moveable = false;
    if(min.index != -1) { 
        moveable = min.amount + 2 <= max.amount;
    }
    return {min.index, max.index, moveable};
}

static bool FindTask(world& w, ecs::drone& drone) {
    hub_mgr::berth home = std::bit_cast<hub_mgr::berth>(drone.home);
    if (auto v = map_find(w.hubs.hubs, home)) {
        auto& info = *v;
        auto red = FindChestRed(w, info);
        auto blue = FindChestBlue(w, info);
        // red -> blue
        if (red != (size_t)-1 && blue != (size_t)-1) {
            DoTask(w, drone, info, info.chest_red[red], info.chest_blue[blue]);
            return true;
        }
        auto [min, max, moveable] = FindHub(w, info);
        // red -> hub
        if (red != (size_t)-1 && min != (size_t)-1) {
            DoTask(w, drone, info, info.chest_red[red], info.hub[min]);
            return true;
        }
        // hub -> blue
        if (blue != (size_t)-1 && max != (size_t)-1) {
            DoTask(w, drone, info, info.hub[max], info.chest_blue[blue]);
            return true;
        }
        // hub -> hub
        if (moveable) {
            DoTask(w, drone, info, info.hub[max], info.hub[min]);
            return true;
        }
    }
    return false;
}

static void NextTask(world& w, ecs::drone& drone) {
    if (!FindTask(w, drone)) {
        drone.status = (uint8_t)drone_status::home;
        Move(w, drone, drone.home);
    }
}

static bool FindTask(world& w, ecs::drone& drone, uint16_t item) {
    hub_mgr::berth home = std::bit_cast<hub_mgr::berth>(drone.home);
    if (auto v = map_find(w.hubs.hubs, home)) {
        auto& info = *v;
        auto blue = FindChestBlue(w, info);
        if (blue != (size_t)-1) {
            DoTask(w, drone, info, info.chest_blue[blue]);
            return true;
        }
        auto [min, _1, _2] = FindHub(w, info);
        if (min != (size_t)-1) {
            DoTask(w, drone, info, info.hub[min]);
            return true;
        }
    }
    return false;
}

static void NextTask(world& w, ecs::drone& drone, uint16_t item) {
    if (!FindTask(w, drone, item)) {
        drone.item = 0;
        drone.status = (uint8_t)drone_status::home;
        Move(w, drone, drone.home);
    }
}

static void Arrival(world& w, ecs::drone& drone) {
    drone.prev = drone.next;
    switch ((drone_status)drone.status) {
    case drone_status::mov1: {
        hub_mgr::berth home = std::bit_cast<hub_mgr::berth>(drone.home);
        auto info = map_find(w.hubs.hubs, home);
        assert(info);
        auto slot = GetChestSlot(w, std::bit_cast<hub_mgr::berth>(drone.next), info->item);
        if (!slot || slot->lock_item == 0 || slot->amount == 0) {
            NextTask(w, drone);
            break;
        }
        slot->lock_item--;
        slot->amount--;
        drone.item = info->item;
        drone.status = (uint8_t)drone_status::mov2;
        Move(w, drone, drone.mov2);
        drone.mov2 = 0;
        break;
    }
    case drone_status::mov2: {
        auto slot = GetChestSlot(w, std::bit_cast<hub_mgr::berth>(drone.next), drone.item);
        if (!slot || slot->lock_space == 0) {
            NextTask(w, drone, drone.item);
            break;
        }
        slot->lock_space--;
        slot->amount++;
        drone.item = 0;
        NextTask(w, drone);
        break;
    }
    case drone_status::home:
        if (!FindTask(w, drone)) {
            drone.status = (uint8_t)drone_status::idle;
            drone.next = 0;
            drone.maxprogress = 0;
        }
        break;
    default:
    case drone_status::error:
    case drone_status::idle:
        std::unreachable();
    }
}

static void Update(world& w, ecs::drone& drone) {
    if (drone.progress > 0) {
        drone.progress--;
    }
    if (drone.progress == 0) {
        Arrival(w, drone);
    }
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : ecs_api::select<ecs::drone>(w.ecs)) {
        auto& drone = v.get<ecs::drone>();
        switch ((drone_status)drone.status) {
        case drone_status::idle:
            FindTask(w, drone);
            break;
        case drone_status::mov1:
        case drone_status::mov2:
        case drone_status::home:
            Update(w, drone);
            break;
        case drone_status::error:
            break;
        default:
            std::unreachable();
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
