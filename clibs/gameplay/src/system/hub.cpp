#include <lua.hpp>
#include "system/hub.h"
#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
#include "core/backpack.h"
#include <bee/nonstd/unreachable.h>
#include <math.h>
#include <algorithm>

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
    init,
    has_error,
    empty_task,
    idle,
    at_home,
    go_mov1,
    go_mov2,
    go_home,
};

static container::slot* ChestGetSlot(world& w, hub_mgr::berth const& berth) {
    if (auto chest = w.hubs.chests.find(berth.hash())) {
        return &chest::array_at(w, container::index::from(*chest), berth.chest_slot);
    }
    return nullptr;
}

static std::optional<uint8_t> ChestFindSlot(world& w, hub_mgr::berth const& berth, uint16_t item) {
    if (auto chest = w.hubs.chests.find(berth.hash())) {
        auto c = container::index::from(*chest);
        container::slot* index = chest::find_item(w, c, item);
        if (index) {
            auto& start = chest::array_at(w, c, 0);
            return (uint8_t)(index-&start);
        }
    }
    return std::nullopt;
}

static uint16_t getxy(uint8_t x, uint8_t y) {
    return ((uint16_t)x << 8) | (uint16_t)y;
}

static void SetStatus(ecs::drone& drone, drone_status status) {
    drone.status = (uint8_t)status;
}

static void AssertStatus(ecs::drone& drone, drone_status status) {
    assert(drone.status == (uint8_t)status);
}

static void CheckHasHome(world& w, ecs::drone& drone, std::function<void(world&, ecs::drone&, hub_mgr::hub_info const&)> f) {
    auto it = w.hubs.hubs.find(drone.home);
    if (it == w.hubs.hubs.end()) {
        if (drone.item != 0) {
            backpack_place(w, drone.item, 1);
            drone.item = 0;
        }
        SetStatus(drone, drone_status::has_error);
        return;
    }
    f(w, drone, it->second);
}

static void GoHome(world& w, ecs::drone& drone, const hub_mgr::hub_info& info);

static int
lbuild(lua_State *L) {
    auto& w = getworld(L);
    if (!(w.dirty & kDirtyHub)) {
        return 0;
    }
    auto& b = w.hubs;
    b.chests.clear();
    std::map<uint16_t, flatmap<uint16_t, hub_mgr::berth>> globalmap;
    flatset<uint16_t> used_id;
    for (auto& v : ecs_api::select<ecs::building>(w.ecs)) {
        auto& building = v.get<ecs::building>();
        uint16_t area = prototype::get<"area">(w, building.prototype);
        building_rect r(building, area);
        if (auto phub = v.component<ecs::hub>()) {
            auto& hub = *phub;
            auto& chestslot = chest::array_at(w, container::index::from(hub.chest), 0);
            auto item = chestslot.item;
            auto berth = create_berth(r, hub_mgr::berth_type::hub, 0);
            auto& map = globalmap[item];
            r.each([&](uint8_t x, uint8_t y) {
                map.insert_or_assign(getxy(x, y), berth);
            });
            b.chests.insert_or_assign(r.hash(), hub.chest);
            used_id.insert(hub.id);
        }
        else if (auto pchest = v.component<ecs::chest>()) {
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
                    map.insert_or_assign(getxy(x, y), berth);
                });
            }
        }
    }

    flatmap<uint16_t, uint16_t> created_hub;
    std::map<uint16_t, hub_mgr::hub_info> hubs;
    uint16_t maxid = 1;
    auto create_hubid = [&]()->uint16_t {
        for (; maxid <= (std::numeric_limits<uint16_t>::max)(); ++maxid) {
            if (!hubs.contains(maxid) && !used_id.contains(maxid)) {
                return maxid;
            }
        }
        return 0;
    };
    for (auto& v : ecs_api::select<ecs::hub, ecs::building>(w.ecs)) {
        auto& hub = v.get<ecs::hub>();
        auto& chestslot = chest::array_at(w, container::index::from(hub.chest), 0);
        auto& building = v.get<ecs::building>();
        uint16_t area = prototype::get<"area">(w, building.prototype);
        uint16_t supply_area = prototype::get<"supply_area">(w, building.prototype);
        building_rect r(building, area, supply_area);
        auto& map = globalmap[chestslot.item];
        flatset<hub_mgr::berth> set;
        r.each([&](uint8_t x, uint8_t y) {
            if (auto pm = map.find(getxy(x, y))) {
                auto m = *pm;
                set.insert(m);
            }
        });
        hub_mgr::hub_info hub_info;
        for (auto h: set) {
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
            default:
                assert(false);
                break;
            }
        }
        hub_info.self = create_berth({building, area}, hub_mgr::berth_type::home, 0);
        hub_info.item = hub_info.idle()? 0 : chestslot.item;
        if (hub.id == 0) {
            hub.id = create_hubid();
            created_hub.insert_or_assign(getxy(building.x, building.y), hub.id);
        }
        hubs.emplace(hub.id, std::move(hub_info));
    }
    b.hubs = std::move(hubs);

    for (auto& drone : ecs_api::array<ecs::drone>(w.ecs)) {
        auto status = (drone_status)drone.status;
        switch (status) {
        case drone_status::has_error:
            break;
        case drone_status::init:
            if (auto p = created_hub.find(drone.prev)) {
                drone.home = *p;
                drone.prev = 0;
                CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                    drone.prev = std::bit_cast<uint32_t>(info.self);
                    if (info.item == 0) {
                        SetStatus(drone, drone_status::idle);
                        return;
                    }
                    SetStatus(drone, drone_status::at_home);
                });
            }
            else {
                drone.prev = 0;
                SetStatus(drone, drone_status::has_error);
            }
            break;
        case drone_status::idle:
            CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                if (drone.prev != std::bit_cast<uint32_t>(info.self)) {
                    GoHome(w, drone, info);
                    return;
                }
                if (info.item != 0) {
                    SetStatus(drone, drone_status::at_home);
                }
            });
            break;
        case drone_status::at_home:
            CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                if (drone.prev != std::bit_cast<uint32_t>(info.self)) {
                    SetStatus(drone, drone_status::idle);
                    GoHome(w, drone, info);
                    return;
                }
                if (info.item == 0) {
                    SetStatus(drone, drone_status::idle);
                }
            });
            break;
        case drone_status::go_home:
        case drone_status::go_mov2:
        case drone_status::empty_task:
            CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                // nothing to do, just check home
            });
            break;
        case drone_status::go_mov1:
            CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                auto mov1 = std::bit_cast<hub_mgr::berth>(drone.next);
                auto mov2 = std::bit_cast<hub_mgr::berth>(drone.mov2);
                if (auto slot = ChestGetSlot(w, mov1)) {
                    if (slot->item != info.item || slot->type == container::slot::slot_type::blue) {
                        if (auto findshot = ChestFindSlot(w, mov1, info.item)) {
                            mov1.chest_slot = *findshot;
                            drone.next = std::bit_cast<uint32_t>(mov1);
                        }
                        else {
                            // undo mov2
                            if (auto mov2slot = ChestGetSlot(w, mov2)) {
                                if (slot->item == info.item && slot->type != container::slot::slot_type::red) {
                                    assert(mov2slot->lock_space > 0);
                                    mov2slot->lock_space--;
                                }
                            }
                            SetStatus(drone, drone_status::empty_task);
                            return;
                        }
                    }
                }
                if (auto slot = ChestGetSlot(w, std::bit_cast<hub_mgr::berth>(drone.mov2))) {
                    if (slot->item != info.item || slot->type == container::slot::slot_type::red) {
                        if (auto findshot = ChestFindSlot(w, mov2, info.item)) {
                            mov2.chest_slot = *findshot;
                            drone.mov2 = std::bit_cast<uint32_t>(mov2);
                        }
                        else {
                            // undo mov1
                            if (auto mov1slot = ChestGetSlot(w, mov1)) {
                                assert(mov1slot->lock_item > 0);
                                mov1slot->lock_item--;
                            }
                            SetStatus(drone, drone_status::empty_task);
                            return;
                        }
                    }
                }
            });
            break;
        default:
            std::unreachable();
        }
    }
    return 0;
}

static void Arrival(world& w, ecs::drone& drone);

static void Move(world& w, ecs::drone& drone, hub_mgr::berth target) {
    drone.next = std::bit_cast<uint32_t>(target);
    if (drone.prev == drone.next) {
        drone.maxprogress = drone.progress = 0;
        Arrival(w, drone);
        return;
    }
    uint32_t x1 = (drone.prev >> 23) & 0x1FF;
    uint32_t y1 = (drone.prev >> 14) & 0x1FF;
    uint32_t x2 = (drone.next >> 23) & 0x1FF;
    uint32_t y2 = (drone.next >> 14) & 0x1FF;
    uint32_t dx = (x1>x2)? (x1-x2): (x2-x1);
    uint32_t dy = (y1>y2)? (y1-y2): (y2-y1);
    float z = sqrt((float)dx*(float)dx+(float)dy*(float)dy) / 2.f;
    auto speed = prototype::get<"speed">(w, drone.prototype);
    drone.maxprogress = drone.progress = uint16_t(z*1000/speed);
}

static void DoTask(world& w, ecs::drone& drone, const hub_mgr::hub_info& info, hub_mgr::berth const& mov1, hub_mgr::berth const& mov2) {
    {
        //lock mov1
        auto chestslot = ChestGetSlot(w, mov1);
        assert(chestslot);
        assert(chestslot->amount > chestslot->lock_item);
        chestslot->lock_item += 1;
    }
    {
        //lock mov2
        auto chestslot = ChestGetSlot(w, mov2);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    SetStatus(drone, drone_status::go_mov1);
    drone.mov2 = std::bit_cast<uint32_t>(mov2);
    Move(w, drone, mov1);
}

static void DoTaskOnlyMov1(world& w, ecs::drone& drone, const hub_mgr::hub_info& info, hub_mgr::berth const& mov1) {
    {
        //lock mov1
        auto chestslot = ChestGetSlot(w, mov1);
        assert(chestslot);
        assert(chestslot->amount > chestslot->lock_item);
        chestslot->lock_item += 1;
    }
    //update drone
    AssertStatus(drone, drone_status::go_mov1);
    assert(drone.mov2 != 0);
    Move(w, drone, mov1);
}

static void DoTaskOnlyMov2(world& w, ecs::drone& drone, const hub_mgr::hub_info& info, hub_mgr::berth const& mov2) {
    {
        //lock mov2
        auto chestslot = ChestGetSlot(w, mov2);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    AssertStatus(drone, drone_status::go_mov2);
    assert(drone.mov2 == 0);
    Move(w, drone, mov2);
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

static size_t FindChestBlueForce(world& w, const hub_mgr::hub_info& info) {
    size_t N = info.chest_blue.size();
    for (size_t i = 0; i < N; ++i) {
        size_t ii = (i + w.time) % N;
        auto berth = info.chest_blue[ii];
        if (w.hubs.chests.find(berth.hash())) {
            return ii;
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

            auto amount1 = chestslot.amount + chestslot.lock_space;
            if (((min.index == (size_t)-1) || (amount1 < min.amount)) && (chestslot.limit > amount1)) {
                min.index = ii;
                min.amount = amount1;
            }

            auto amount2 = chestslot.amount - chestslot.lock_item;
            if (((max.index == (size_t)-1) || (amount2 > max.amount)) && (amount2 > 0)) {
                max.index = ii;
                max.amount = amount2;
            }
        }
    }
    bool moveable = false;
    if(min.index != (size_t)-1) { 
        moveable = min.amount + 2 <= max.amount;
    }
    return {min.index, max.index, moveable};
}

static size_t FindHubForce(world& w, const hub_mgr::hub_info& info) {
    struct hub_find {
        size_t index = -1;
        uint16_t amount = 0;
    };
    hub_find min;
    size_t N = info.hub.size();
    for (size_t i = 0; i < N; ++i) {
        size_t ii = (i + w.time) % N;
        auto berth = info.hub[ii];
        if (auto chest = w.hubs.chests.find(berth.hash())) {
            auto& chestslot = chest::array_at(w, container::index::from(*chest), berth.chest_slot);
            auto amount1 = chestslot.amount + chestslot.lock_space;
            if ((min.index == (size_t)-1) || (amount1 < min.amount)) {
                min.index = ii;
                min.amount = amount1;
            }
        }
    }
    return min.index;
}

static void GoHome(world& w, ecs::drone& drone, const hub_mgr::hub_info& info) {
    assert((drone_status)drone.status != drone_status::at_home);
    SetStatus(drone, drone_status::go_home);
    Move(w, drone, info.self);
}

static bool FindTask(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
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
    return false;
}

static void FindTaskAtHome(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
    if (info.item == 0) {
        SetStatus(drone, drone_status::idle);
        return;
    }
    if (FindTask(w, drone, info)) {
        return;
    }
    SetStatus(drone, drone_status::at_home);
}

static void FindTaskNotAtHome(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
    if (info.item == 0) {
        GoHome(w, drone, info);
        return;
    }
    if (FindTask(w, drone, info)) {
        return;
    }
    GoHome(w, drone, info);
}

static bool FindTaskOnlyMov1(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
    auto red = FindChestRed(w, info);
    if (red != (size_t)-1) {
        DoTaskOnlyMov1(w, drone, info, info.chest_red[red]);
        return true;
    }
    auto [_, max, _2] = FindHub(w, info);
    if (max != (size_t)-1) {
        auto mov1 = info.hub[max];
        if (drone.mov2 != std::bit_cast<uint32_t>(mov1)) {
            DoTaskOnlyMov1(w, drone, info, mov1);
            return true;
        }
    }
    return false;
}

static void FindTaskOnlyMov2(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
    if (info.item != drone.item) {
        backpack_place(w, drone.item, 1);
        drone.item = 0;
        GoHome(w, drone, info);
        return;
    }
    auto blue = FindChestBlue(w, info);
    if (blue != (size_t)-1) {
        DoTaskOnlyMov2(w, drone, info, info.chest_blue[blue]);
        return;
    }
    auto [min, _1, _2] = FindHub(w, info);
    if (min != (size_t)-1) {
        DoTaskOnlyMov2(w, drone, info, info.hub[min]);
        return;
    }
    blue = FindChestBlueForce(w, info);
    if (blue != (size_t)-1) {
        DoTaskOnlyMov2(w, drone, info, info.chest_blue[blue]);
        return;
    }
    min = FindHubForce(w, info);
    if (min != (size_t)-1) {
        DoTaskOnlyMov2(w, drone, info, info.hub[min]);
        return;
    }
    assert(false);
}

static void UnlockMov2(world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
    auto slot = ChestGetSlot(w, std::bit_cast<hub_mgr::berth>(drone.mov2));
    drone.mov2 = 0;
    if (slot && slot->item == drone.item) {
        if (slot->lock_space > 0) {
            slot->lock_space--;
        }
    }
}

static void Arrival(world& w, ecs::drone& drone) {
    drone.prev = drone.next;
    switch ((drone_status)drone.status) {
    case drone_status::go_mov1: {
        CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
            assert(info.item != 0);
            auto slot = ChestGetSlot(w, std::bit_cast<hub_mgr::berth>(drone.next));
            if (!slot || slot->item != info.item || slot->amount == 0) {
                if (slot && slot->item == info.item && slot->amount == 0 && slot->lock_item > 0) {
                    slot->lock_item--;
                }
                if (FindTaskOnlyMov1(w, drone, info)) {
                    return;
                }
                UnlockMov2(w, drone, info);
                GoHome(w, drone, info);
                return;
            }
            if (slot->lock_item > 0) {
                slot->lock_item--;
            }
            slot->amount--;
            drone.item = info.item;
            SetStatus(drone, drone_status::go_mov2);
            Move(w, drone, std::bit_cast<hub_mgr::berth>(drone.mov2));
            drone.mov2 = 0;
        });
        break;
    }
    case drone_status::go_mov2: {
        CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
            auto slot = ChestGetSlot(w, std::bit_cast<hub_mgr::berth>(drone.next));
            if (!slot || slot->item != drone.item) {
                FindTaskOnlyMov2(w, drone, info);
                return;
            }
            if (slot->lock_space > 0) {
                slot->lock_space--;
            }
            slot->amount++;
            drone.item = 0;
            FindTaskNotAtHome(w, drone, info);
        });
        break;
    }
    case drone_status::go_home:
        drone.next = 0;
        drone.maxprogress = 0;
        CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
            if (drone.prev != std::bit_cast<uint32_t>(info.self)) {
                GoHome(w, drone, info);
                return;
            }
            FindTaskAtHome(w, drone, info);
        });
        break;
    case drone_status::empty_task:
        CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
            FindTaskNotAtHome(w, drone, info);
        });
        break;
    default:
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
    auto& w = getworld(L);
    for (auto& drone : ecs_api::array<ecs::drone>(w.ecs)) {
        switch ((drone_status)drone.status) {
        case drone_status::at_home:
            CheckHasHome(w, drone, +[](world& w, ecs::drone& drone, hub_mgr::hub_info const& info) {
                FindTaskAtHome(w, drone, info);
            });
            break;
        case drone_status::go_mov1:
        case drone_status::go_mov2:
        case drone_status::go_home:
        case drone_status::empty_task:
            Update(w, drone);
            break;
        case drone_status::init:
        case drone_status::idle:
        case drone_status::has_error:
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
