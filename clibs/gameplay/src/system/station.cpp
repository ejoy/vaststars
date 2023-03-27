#include "system/station.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}
#include "luaecs.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

using station_vector = std::vector<ecs::station*>;

template <>
uint8_t kdtree_getdata<uint8_t, station_consumer_kdtree::pointcolud>(station_consumer_kdtree::pointcolud const& dataset, uint16_t i, uint8_t dim) {
    if (dim == 0) {
        return dataset[i].x;
    }
    return dataset[i].y;
}

template <typename ElementType = uint8_t, typename Dataset = station_consumer_kdtree::pointcolud, typename AccessorType = uint16_t>
class nearest_result {
public:
    nearest_result(world& w)
        : w(w)
        , indices()
        , dists((std::numeric_limits<ElementType>::max)())
    {}
    bool needLorry(const Dataset& dataset, AccessorType index) {
        ecs_api::entity<ecs::station, ecs::building> e {w.ecs};
        if (!e.init(dataset[index].cid)) {
            return false;
        }
        auto& station = e.get<ecs::station>();
        return station.lorry < station.weights;
    }
    bool addPoint(const Dataset& dataset, ElementType dist, AccessorType index) {
        if ((dists > dist) || ((dist == dists) && (indices > index))) {
            if (needLorry(dataset, index)) {
                dists   = dist;
                indices = index;
            }
        }
        return true;
    }
    ElementType accumDist(ElementType a, ElementType b) const {
        return abs(a - b);
    }
    ElementType worstDist() const { return dists; }
    explicit operator bool() const {
        return dists != (std::numeric_limits<ElementType>::max)();
    }
    AccessorType value() const {
        return indices;
    }
private:
    world& w;
    AccessorType indices;
    ElementType  dists;
};

static uint8_t safe_add(uint8_t a, uint8_t b) {
    if (b > UINT8_C(255) - a)
        return UINT8_C(255);
    return a + b;
}

static std::tuple<uint8_t, uint8_t> building_center(world& world, ecs::building& building) {
    //TODO 使用更精确的x/y
    prototype_context pt = world.prototype(building.prototype);
    uint16_t area = (uint16_t)pt_area(&pt);
    uint8_t w = area >> 8;
    uint8_t h = area & 0xFF;
    assert(w > 0 && h > 0);
    w--;
    h--;
    uint8_t dx = w / 2;
    uint8_t dy = h / 2;
    switch (building.direction) {
    case 0: // N
        break;
    case 1: // E
        if (h % 2 != 0) dy++;
        std::swap(dx, dy);
        break;
    case 2: // S
        if (w % 2 != 0) dx++;
        if (h % 2 != 0) dy++;
        break;
    case 3: // W
        if (w % 2 != 0) dx++;
        std::swap(dx, dy);
        break;
    default:
        std::unreachable();
    }
    return {safe_add(building.x, dx), safe_add(building.y, dy)};
}

static int lbuild(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& rw = w.rw;
    auto& s = w.stations;
    s.consumers.clear();
    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::station, ecs::building>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        auto& chestslot = chest::array_at(w, container::index::from(station.chest), 0);
        auto& kdtree = s.consumers[chestslot.item];
        auto& building = v.get<ecs::building>();
        auto [x, y] = building_center(w, building);
        kdtree.dataset.emplace_back(x, y, v.getid());
    }
    for (auto& [_, kdtree]: s.consumers) {
        kdtree.tree.build();
    }
    return 0;
}

static ecs::station& find_producer(world& w, station_vector& producers) {
    assert(producers.size() > 0);
    float min_cap = -1.f;
    ecs::station* result = nullptr;
    size_t N = producers.size();
    for (size_t i = 0; i < N; ++i) {
        size_t ii = (i + w.time) % N;
        auto& station = *producers[ii];
        float cap = (float)station.lorry / station.weights;
        if(!result || (cap < min_cap)) {
            min_cap = cap;
            result = &station;
            if (station.lorry == 0) {
                break;
            }
        }
    }
    assert(min_cap >= 0.f);
    assert(result);
    return *result;
}

static std::optional<ecs_cid> find_consumer(world& w, ecs::building& starting, uint16_t item) {
    auto& consumers = w.stations.consumers;
    auto it = consumers.find(item);
    if (it == consumers.end()) {
        return std::nullopt;
    }
    auto& kdtree = it->second;
    nearest_result result(w);
    auto [x, y] = building_center(w, starting);
    if (!kdtree.tree.nearest(result, {x,y})) {
        return std::nullopt;
    }
    return kdtree.dataset[result.value()].cid;
}

static std::optional<uint8_t> recipeFirstOutput(world& w, uint16_t recipe) {
    if (recipe == 0) {
        return std::nullopt;
    }
    prototype_context pt = w.prototype(recipe);
    recipe_items* ingredients = (recipe_items*)pt_ingredients(&pt);
    recipe_items* results = (recipe_items*)pt_results(&pt);
    if (results->n == 0) {
        return std::nullopt;
    }
    if (ingredients->n >= (std::numeric_limits<uint8_t>::max)()) {
        return std::nullopt;
    }
    return (uint8_t)ingredients->n;
}

static int lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    size_t sz = ecs_api::count<ecs::station_producer>(w.ecs);
    if (sz == 0) {
        return 0;
    }
    size_t i = 0;
    station_vector producers(sz);
    for (auto& v : ecs_api::select<ecs::station_producer, ecs::station, ecs::building>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        producers[i++] = &station;
        if (station.endpoint == 0xFFFF) {
            continue;
        }
        auto& ep = w.rw.Endpoint(station.endpoint);
        auto lorryId = ep.waitingLorry(w.rw);
        if (!lorryId) {
            continue;
        }
        auto& l = w.rw.Lorry(lorryId);
        if (!l.ready() || !ep.isReady(w.rw)) {
            continue;
        }
        auto& chestslot = chest::array_at(w, container::index::from(station.chest), 0);
        if (chestslot.item == 0) {
            continue;
        }
        if (chestslot.amount == 0 || chestslot.amount < chestslot.limit) {
            continue;
        }
        if (auto consumer_cid = find_consumer(w, v.get<ecs::building>(), chestslot.item)) {
            ecs_api::entity<ecs::station_consumer, ecs::station> target {w.ecs};
            if (!target.init(*consumer_cid)) {
                continue;
            }
            ep.setOutForce(w.rw);
            auto& target_station = target.get<ecs::station>();
            auto& target_ep = w.rw.Endpoint(target_station.endpoint);
            l.item_classid = chestslot.item;
            l.item_amount = chestslot.amount;
            l.ending = target_ep.rev_neighbor;
            chestslot.amount = 0;
            station.lorry--;
            target_station.lorry++;
        }
    }
    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::station>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        if (station.endpoint == 0xFFFF) {
            continue;
        }
        auto& ep = w.rw.Endpoint(station.endpoint);
        auto lorryId = ep.waitingLorry(w.rw);
        if (!lorryId) {
            continue;
        }
        auto& l = w.rw.Lorry(lorryId);
        if (!l.ready() || !ep.isReady(w.rw)) {
            continue;
        }
        auto& chestslot = chest::array_at(w, container::index::from(station.chest), 0);
        if (chestslot.item == 0) {
            continue;
        }
        if (chestslot.amount > 0) {
            continue;
        }
        auto& producer = find_producer(w, producers);
        ep.setOutForce(w.rw);
        auto& target_station = producer;
        auto& target_ep = w.rw.Endpoint(target_station.endpoint);
        chestslot.amount = l.item_amount;
        l.item_classid = 0;
        l.item_amount = 0;
        l.ending = target_ep.rev_neighbor;
        station.lorry--;
        target_station.lorry++;
    }
    for (auto& v : ecs_api::select<ecs::lorry_factory, ecs::assembling, ecs::chest>(w.ecs)) {
        auto& lorry_factory = v.get<ecs::lorry_factory>();
        if (lorry_factory.endpoint == 0xFFFF) {
            continue;
        }
        auto& ep = w.rw.Endpoint(lorry_factory.endpoint);
        if (!ep.isReady(w.rw)) {
            continue;
        }
        auto& assembling = v.get<ecs::assembling>();
        auto slot_opt = recipeFirstOutput(w, assembling.recipe);
        if (!slot_opt) {
            continue;
        }
        auto& slot = *slot_opt;
        auto& chest = v.get<ecs::chest>();
        auto& chestslot = chest::array_at(w, container::index::from(chest.chest), slot);
        if (chestslot.amount == 0) {
            continue;
        }
        chestslot.amount--;
        auto& producer = find_producer(w, producers);
        roadnet::lorryid lorryId = w.rw.createLorry(w, chestslot.item);
        auto& l = w.rw.Lorry(lorryId);
        l.item_classid = 0;
        l.item_amount = 0;
        l.ending = w.rw.Endpoint(producer.endpoint).rev_neighbor;
        ep.setOutForce(w.rw, lorryId);
    }
    return 0;
}

extern "C" int
luaopen_vaststars_station_system(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "build", lbuild },
        { "update", lupdate },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
