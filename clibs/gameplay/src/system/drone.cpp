#include <lua.hpp>
#include "system/drone.h"
#include "luaecs.h"
#include "core/world.h"
#include "core/capacitance.h"
#include "core/backpack.h"
#include <bee/nonstd/unreachable.h>
#include <math.h>
#include <algorithm>

using DroneEntity = ecs_api::entity<ecs::drone>;

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
};

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

static uint16_t getxy(uint8_t x, uint8_t y) {
    return ((uint16_t)x << 8) | (uint16_t)y;
}

static container::slot* ChestGetSlot(world& w, airport_berth const& berth) {
    if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
        return &chest::array_at(w, container::index::from(building->chest), berth.slot);
    }
    return nullptr;
}

static std::optional<uint8_t> ChestFindSlot(world& w, airport_berth const& berth, uint16_t item) {
    if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
        auto c = container::index::from(building->chest);
        container::slot* index = chest::find_item(w, c, item);
        if (index) {
            auto& start = chest::array_at(w, c, 0);
            return (uint8_t)(index-&start);
        }
    }
    return std::nullopt;
}

static void SetStatus(ecs::drone& drone, drone_status status) {
    drone.status = (uint8_t)status;
}

static void AssertStatus(ecs::drone& drone, drone_status status) {
    assert(drone.status == (uint8_t)status);
}

static void CheckHasHome(world& w, DroneEntity& e, ecs::drone& drone, std::function<void(world&, DroneEntity&, ecs::drone&, airport&)> f) {
    auto it = w.airports.find(drone.home);
    if (it == w.airports.end()) {
        if (drone.item != 0) {
            backpack_place(w, drone.item, 1);
            drone.item = 0;
        }
        SetStatus(drone, drone_status::has_error);
        e.enable_tag<ecs::drone_changed>();
        return;
    }
    f(w, e, drone, it->second);
}

static void GoHome(world& w, DroneEntity& e, ecs::drone& drone, const airport& info);

struct ChestSearcher {
    struct Node {
        airport_berth berth;
        building* building;
    };
    struct ItemNode: public Node {
        uint16_t item;
    };
    struct AmountNode: public Node {
        uint16_t amount;
    };
    std::vector<Node> demand_place;
    std::vector<AmountNode> transit_pickup;
    std::vector<AmountNode> transit_place;
    static bool PickupTimeSort(const ChestSearcher::Node& a, const ChestSearcher::Node& b) {
        return a.building->pickup_time < b.building->pickup_time;
    }
    static bool PlaceTimeSort(const ChestSearcher::Node& a, const ChestSearcher::Node& b) {
        return a.building->place_time < b.building->place_time;
    }
    static bool AmountSort(const ChestSearcher::AmountNode& a, const ChestSearcher::AmountNode& b) {
        return a.amount < b.amount;
    }
};

static void rebuild(world& w) {
    w.drone_time = 0;
    struct chestinfo {
        uint16_t item;
        container::slot::slot_type type;
    };
    struct mapinfo {
        uint8_t x;
        uint8_t y;
        std::vector<chestinfo> chest;
    };
    std::map<uint16_t, mapinfo> globalmap;
    flatset<uint16_t> used_id;
    for (auto& v : ecs_api::select<ecs::airport>(w.ecs)) {
        auto& airport = v.get<ecs::airport>();
        used_id.insert(airport.id);
    }

    for (auto& v : ecs_api::select<ecs::chest, ecs::building>(w.ecs)) {
        auto& chest = v.get<ecs::chest>();
        auto& building = v.get<ecs::building>();
        uint16_t area = prototype::get<"area">(w, building.prototype);
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        mapinfo m;
        m.x = building.x;
        m.y = building.y;
        for (auto& chestslot : chest::array_slice(w, c)) {
            chestslot.lock_item = 0;
            chestslot.lock_space = 0;
            m.chest.emplace_back(chestslot.item, chestslot.type);
        }
        building_rect(building, area).each([&](uint8_t x, uint8_t y) {
            globalmap.insert_or_assign(getxy(x, y), m);
        });
    }

    flatmap<uint16_t, uint16_t> created_airport;
    std::map<uint16_t, airport> airports;
    uint16_t maxid = 1;
    auto create_hubid = [&]()->uint16_t {
        for (; maxid <= (std::numeric_limits<uint16_t>::max)(); ++maxid) {
            if (!airports.contains(maxid) && !used_id.contains(maxid)) {
                return maxid;
            }
        }
        return 0;
    };
    for (auto& v : ecs_api::select<ecs::airport, ecs::building, ecs::capacitance>(w.ecs)) {
        auto& airport = v.get<ecs::airport>();
        auto& building = v.get<ecs::building>();
        if (airport.id == 0) {
            airport.id = create_hubid();
            created_airport.insert_or_assign(getxy(building.x, building.y), airport.id);
        }
        auto homeBuilding = createBuildingCache(w, building, 0);
        struct airport info;
        info.prototype = building.prototype;
        info.width = homeBuilding.w;
        info.height = homeBuilding.h;
        info.homeBerth = airport_berth { building.x, building.y, 0 };
        info.capacitance = &v.get<ecs::capacitance>();
        std::map<uint16_t, mapinfo> set;
        uint16_t area = prototype::get<"area">(w, building.prototype);
        uint16_t supply_area = prototype::get<"supply_area">(w, building.prototype);
        building_rect(building, area, supply_area).each([&](uint8_t x, uint8_t y) {
            auto pm = globalmap.find(getxy(x, y));
            if (pm != globalmap.end()) {
                auto& m = pm->second;
                set.emplace(getxy(m.x, m.y), m);
            }
        });
        for (auto& [_, m]: set) {
            for (uint8_t i = 0; i < (uint8_t)m.chest.size(); ++i) {
                auto& slot = m.chest[i];
                airport_berth berth {m.x, m.y, i};
                switch (slot.type) {
                case container::slot::slot_type::supply:
                    info.market[slot.item].supply.emplace_back(berth);
                    break;
                case container::slot::slot_type::demand:
                    info.market[slot.item].demand.emplace_back(berth);
                    break;
                case container::slot::slot_type::transit:
                    info.market[slot.item].transit.emplace_back(berth);
                    break;
                default:
                    break;
                }
            }
        }
        for (auto it = info.market.begin(); it != info.market.end();) {
            if (it->second.active()) {
                ++it;
            }
            else {
                it = info.market.erase(it);
            }
        }
        airports.emplace(airport.id, std::move(info));
    }
    w.airports = std::move(airports);

    for (auto& e : ecs_api::select<ecs::drone>(w.ecs)) {
        auto& drone = e.get<ecs::drone>();
        auto status = (drone_status)drone.status;
        switch (status) {
        case drone_status::has_error:
            break;
        case drone_status::init:
            if (auto p = created_airport.find(drone.home)) {
                drone.home = *p;
                CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                    drone.prev = std::bit_cast<airport_berth>(info.homeBerth);
                    if (info.market.empty()) {
                        SetStatus(drone, drone_status::idle);
                        return;
                    }
                    SetStatus(drone, drone_status::at_home);
                });
            }
            else {
                SetStatus(drone, drone_status::has_error);
            }
            e.enable_tag<ecs::drone_changed>();
            break;
        case drone_status::idle:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                if (drone.prev != info.homeBerth) {
                    GoHome(w, e, drone, info);
                    return;
                }
                if (!info.market.empty()) {
                    SetStatus(drone, drone_status::at_home);
                }
            });
            break;
        case drone_status::at_home:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                if (drone.prev != info.homeBerth) {
                    SetStatus(drone, drone_status::idle);
                    GoHome(w, e, drone, info);
                    return;
                }
                if (info.market.empty()) {
                    SetStatus(drone, drone_status::idle);
                }
            });
            break;
        case drone_status::go_home:
        case drone_status::empty_task:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                // nothing to do, just check home
            });
            break;
        case drone_status::go_mov1:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                auto& mov1 = drone.next;
                auto& mov2 = drone.mov2;
                auto slot1 = ChestGetSlot(w, mov1);
                auto slot2 = ChestGetSlot(w, mov2);
                if (0
                    || !slot1
                    || !slot2
                    || slot1->item != slot2->item
                    || (slot1->type != container::slot::slot_type::supply && slot1->type != container::slot::slot_type::transit)
                    || (slot2->type != container::slot::slot_type::demand && slot2->type != container::slot::slot_type::transit)
                    || slot1->amount <= slot1->lock_item
                    || slot2->limit <= slot2->amount + slot2->lock_space
                ) {
                    SetStatus(drone, drone_status::empty_task);
                    return;
                }
                slot1->lock_item++;
                slot2->lock_space++;
            });
            break;
        case drone_status::go_mov2:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport const& info) {
                auto& mov2 = drone.next;
                auto slot2 = ChestGetSlot(w, mov2);
                if (0
                    || !slot2
                    || drone.item != slot2->item
                    || (slot2->type != container::slot::slot_type::demand && slot2->type != container::slot::slot_type::transit)
                    || slot2->limit <= slot2->amount + slot2->lock_space
                ) {
                    SetStatus(drone, drone_status::empty_task);
                    return;
                }
                slot2->lock_space++;
            });
            break;
        default:
            std::unreachable();
        }
    }
}

static int lbuild(lua_State* L) {
    auto& w = getworld(L);
    if (w.dirty & (kDirtyChest | kDirtyAirport)) {
        rebuild(w);
    }
    return 0;
}

static void Arrival(world& w, DroneEntity& e, ecs::drone& drone);

static void Move(world& w, DroneEntity& e, ecs::drone& drone, const ChestSearcher::Node& target) {
    drone.next = std::bit_cast<airport_berth>(target.berth);
    if (drone.prev == drone.next) {
        drone.maxprogress = drone.progress = 0;
        Arrival(w, e, drone);
        return;
    }
    auto source = drone.prev;
    auto sourceBuilding = w.buildings.find(getxy(source.x, source.y));
    if (!sourceBuilding) {
        static building dummy {0,0,0};
        sourceBuilding = &dummy;
    }
    float x1 = source.x + sourceBuilding->w / 2.f;
    float y1 = source.y + sourceBuilding->h / 2.f;
    float x2 = target.berth.x + target.building->w / 2.f;
    float y2 = target.berth.y + target.building->h / 2.f;
    float dx = x1-x2;
    float dy = y1-y2;
    float z = sqrt(dx*dx+dy*dy);
    auto speed = prototype::get<"speed">(w, drone.prototype);
    drone.maxprogress = drone.progress = uint16_t(z*1000/speed);
    e.enable_tag<ecs::drone_changed>();
}

static void DoTask(world& w, DroneEntity& e, ecs::drone& drone, const airport& info, const ChestSearcher::Node& mov1, const ChestSearcher::Node& mov2) {
    {
        //lock mov1
        auto chestslot = ChestGetSlot(w, mov1.berth);
        assert(chestslot);
        assert(chestslot->amount > chestslot->lock_item);
        chestslot->lock_item += 1;
    }
    {
        //lock mov2
        auto chestslot = ChestGetSlot(w, mov2.berth);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    mov1.building->pickup_time = w.drone_time;
    mov2.building->place_time = w.drone_time;
    SetStatus(drone, drone_status::go_mov1);
    drone.mov2 = std::bit_cast<airport_berth>(mov2.berth);
    Move(w, e, drone, mov1);
}

static void DoTaskOnlyMov2(world& w, DroneEntity& e, ecs::drone& drone, const airport& info, const ChestSearcher::Node& mov2) {
    {
        //lock mov2
        auto chestslot = ChestGetSlot(w, mov2.berth);
        assert(chestslot);
        assert(chestslot->limit > chestslot->amount + chestslot->lock_space);
        chestslot->lock_space += 1;
    }
    //update drone
    mov2.building->place_time = w.drone_time;
    Move(w, e, drone, mov2);
}

static void GoHome(world& w, DroneEntity& e, ecs::drone& drone, const airport& info) {
    assert((drone_status)drone.status != drone_status::at_home);
    SetStatus(drone, drone_status::go_home);
    building homeBuilding {0, 0, info.width, info.height};
    ChestSearcher::Node node {
        info.homeBerth,
        &homeBuilding,
    };
    Move(w, e, drone, node);
}

static bool FindTask(world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
    auto consumer = consumer_context {
        *info.capacitance,
        prototype::get<"cost">(w, drone.prototype),
        0,
        prototype::get<"capacitance">(w, info.prototype),
    };
    if (!consumer.has_power()) {
        return false;
    }
    w.drone_time++;
    std::map<uint16_t, ChestSearcher> searcher;
    std::vector<ChestSearcher::ItemNode> searcher_array;
    for (auto& [item, market] : info.market) {
        std::vector<ChestSearcher::Node> supply_pickup;
        ChestSearcher s;
        for (auto& berth : market.supply) {
            if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
                auto& chestslot = chest::array_at(w, container::index::from(building->chest), berth.slot);
                if (chestslot.amount > chestslot.lock_item) {
                    supply_pickup.push_back({
                        berth,
                        building,
                    });
                }
            }
        }
        for (auto& berth : market.demand) {
            if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
                auto& chestslot = chest::array_at(w, container::index::from(building->chest), berth.slot);
                if (chestslot.limit > chestslot.amount + chestslot.lock_space) {
                    s.demand_place.push_back({
                        berth,
                        building,
                    });
                }
            }
        }
        for (auto& berth : market.transit) {
            if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
                auto& chestslot = chest::array_at(w, container::index::from(building->chest), berth.slot);
                assert(chestslot.amount >= chestslot.lock_item);
                if (chestslot.amount > chestslot.lock_item) {
                    s.transit_pickup.push_back({
                        berth,
                        building,
                        (uint16_t)(chestslot.amount - chestslot.lock_item),
                    });
                }
                if (chestslot.limit > chestslot.amount + chestslot.lock_space) {
                    s.transit_place.push_back({
                        berth,
                        building,
                        (uint16_t)(chestslot.amount - chestslot.lock_item),
                    });
                }
            }
        }
        if (s.demand_place.empty() && s.transit_place.empty()) {
            continue;
        }
        if (supply_pickup.empty()) {
            if (s.transit_pickup.empty()) {
                continue;
            }
        }
        else {
            for (auto const& s : supply_pickup) {
                searcher_array.emplace_back(ChestSearcher::ItemNode {
                    s.berth,
                    s.building,
                    item
                });
            }
        }
        searcher.emplace(item, std::move(s));
    }
    if (!searcher_array.empty()) {
        auto& supply = *std::min_element(std::begin(searcher_array), std::end(searcher_array), ChestSearcher::PickupTimeSort);
        auto& suite = searcher[supply.item];
        if (!suite.demand_place.empty()) {
            auto& demand = *std::min_element(std::begin(suite.demand_place), std::end(suite.demand_place), ChestSearcher::PlaceTimeSort);
            DoTask(w, e, drone, info, supply, demand);
            consumer.cost_power();
            return true;
        }
        if (!suite.transit_place.empty()) {
            auto& transit = *std::min_element(std::begin(suite.transit_place), std::end(suite.transit_place), ChestSearcher::AmountSort);
            DoTask(w, e, drone, info, supply, transit);
            consumer.cost_power();
            return true;
        }
        assert(false);
        return false;
    }
    for (auto& [item, suite] : searcher) {
        assert(!suite.transit_pickup.empty());
        if (!suite.demand_place.empty()) {
            for (auto const& s : suite.demand_place) {
                searcher_array.emplace_back(ChestSearcher::ItemNode {
                    s.berth,
                    s.building,
                    item
                });
            }
        }
    }
    if (!searcher_array.empty()) {
        auto& demand = *std::min_element(std::begin(searcher_array), std::end(searcher_array), ChestSearcher::PlaceTimeSort);
        auto& suite = searcher[demand.item];
        auto& transit = *std::max_element(std::begin(suite.transit_pickup), std::end(suite.transit_pickup), ChestSearcher::AmountSort);
        DoTask(w, e, drone, info, transit, demand);
        consumer.cost_power();
        return true;
    }
    for (auto& [item, suite] : searcher) {
        assert(!suite.transit_place.empty());
        auto& max_transit = *std::max_element(std::begin(suite.transit_pickup), std::end(suite.transit_pickup), ChestSearcher::AmountSort);
        auto& min_transit = *std::min_element(std::begin(suite.transit_place), std::end(suite.transit_place), ChestSearcher::AmountSort);
        if (min_transit.amount + 2 <= max_transit.amount) {
            searcher_array.emplace_back(ChestSearcher::ItemNode {
                max_transit.berth,
                max_transit.building,
                item
            });
        }
    }
    if (!searcher_array.empty()) {
        auto& max_transit = *std::min_element(std::begin(searcher_array), std::end(searcher_array), ChestSearcher::PickupTimeSort);
        auto& suite = searcher[max_transit.item];
        auto& min_transit = *std::min_element(std::begin(suite.transit_place), std::end(suite.transit_place), ChestSearcher::AmountSort);
        DoTask(w, e, drone, info, max_transit, min_transit);
        consumer.cost_power();
        return true;
    }
    return false;
}

static bool FindTaskOnlyMov2(world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
    auto it = info.market.find(drone.item);
    if (it == info.market.end()) {
        return false;
    }
    w.drone_time++;
    auto& market = it->second;
    std::vector<ChestSearcher::Node> demand_place;
    for (auto& berth : market.demand) {
        if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
            auto& chestslot = chest::array_at(w, container::index::from(building->chest), berth.slot);
            if (chestslot.limit > chestslot.amount + chestslot.lock_space) {
                demand_place.push_back({
                    berth,
                    building,
                });
            }
        }
    }
    if (!demand_place.empty()) {
        auto& demand = *std::min_element(std::begin(demand_place), std::end(demand_place), ChestSearcher::PlaceTimeSort);
        DoTaskOnlyMov2(w, e, drone, info, demand);
        return true;
    }
    std::vector<ChestSearcher::Node> transit_place;
    for (auto& berth : market.transit) {
        if (auto building = w.buildings.find(getxy(berth.x, berth.y))) {
            auto& chestslot = chest::array_at(w, container::index::from(building->chest), berth.slot);
            if (chestslot.limit > chestslot.amount + chestslot.lock_space) {
                transit_place.push_back({
                    berth,
                    building,
                });
            }
        }
    }
    if (!demand_place.empty()) {
        auto& transit = *std::min_element(std::begin(transit_place), std::end(transit_place), ChestSearcher::PlaceTimeSort);
        DoTaskOnlyMov2(w, e, drone, info, transit);
        return true;
    }
    return false;
}

static void FindTaskNotAtHome(world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
    if (info.market.empty()) {
        GoHome(w, e, drone, info);
        return;
    }
    if (FindTask(w, e, drone, info)) {
        return;
    }
    GoHome(w, e, drone, info);
}

static void Arrival(world& w, DroneEntity& e, ecs::drone& drone) {
    drone.prev = drone.next;
    switch ((drone_status)drone.status) {
    case drone_status::go_mov1: {
        CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
            auto slot = ChestGetSlot(w, drone.next);
            assert(slot 
                && slot->item != 0
                && (slot->type == container::slot::slot_type::supply || slot->type == container::slot::slot_type::transit)
                && slot->amount >= slot->lock_item
                && slot->lock_item > 0
            );
            auto mov2Berth = drone.mov2;
            auto movBuilding = w.buildings.find(getxy(mov2Berth.x, mov2Berth.y));
            assert(movBuilding);
            slot->lock_item--;
            slot->amount--;
            drone.item = slot->item;
            SetStatus(drone, drone_status::go_mov2);
            ChestSearcher::Node node {
                mov2Berth,
                movBuilding,
            };
            Move(w, e, drone, node);
            drone.mov2 = airport_berth {0,0,0};
        });
        break;
    }
    case drone_status::go_mov2: {
        CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
            auto slot = ChestGetSlot(w, drone.next);
            assert(slot);
            assert(slot->item == drone.item);
            assert(slot->type == container::slot::slot_type::demand || slot->type == container::slot::slot_type::transit);
            assert(slot->limit >= slot->amount + slot->lock_space);
            assert(slot->lock_space > 0);
            slot->lock_space--;
            slot->amount++;
            drone.item = 0;
            FindTaskNotAtHome(w, e, drone, info);
        });
        break;
    }
    case drone_status::go_home:
        drone.next = airport_berth {0,0,0};
        drone.maxprogress = 0;
        CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
            if (drone.prev != info.homeBerth) {
                GoHome(w, e, drone, info);
                return;
            }
            if (info.market.empty()) {
                SetStatus(drone, drone_status::idle);
                return;
            }
            if (FindTask(w, e, drone, info)) {
                return;
            }
            SetStatus(drone, drone_status::at_home);
        });
        break;
    case drone_status::empty_task:
        CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
            if (drone.item == 0) {
                FindTaskNotAtHome(w, e, drone, info);
                return;
            }
            if (FindTaskOnlyMov2(w, e, drone, info)) {
                return;
            }
            backpack_place(w, drone.item, 1);
            drone.item = 0;
            GoHome(w, e, drone, info);
        });
        break;
    default:
        std::unreachable();
    }
}

static void Update(world& w, DroneEntity& e, ecs::drone& drone) {
    if (drone.progress > 0) {
        drone.progress--;
    }
    if (drone.progress == 0) {
        Arrival(w, e, drone);
    }
}

static int
lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (auto& e : ecs_api::select<ecs::drone>(w.ecs)) {
        auto& drone = e.get<ecs::drone>();
        switch ((drone_status)drone.status) {
        case drone_status::at_home:
            CheckHasHome(w, e, drone, +[](world& w, DroneEntity& e, ecs::drone& drone, airport& info) {
                if (info.market.empty()) {
                    SetStatus(drone, drone_status::idle);
                    return;
                }
                FindTask(w, e, drone, info);
            });
            break;
        case drone_status::go_mov1:
        case drone_status::go_mov2:
        case drone_status::go_home:
        case drone_status::empty_task:
            Update(w, e, drone);
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
luaopen_vaststars_drone_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
