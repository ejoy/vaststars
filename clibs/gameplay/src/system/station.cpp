#include "system/station.h"
#include "core/world.h"
#include "core/capacitance.h"
extern "C" {
#include "util/prototype.h"
}
#include "luaecs.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

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
        //TODO 使用更精确的x/y
        kdtree.dataset.emplace_back(building.x, building.y, v.getid());
    }
    for (auto& [_, kdtree]: s.consumers) {
        kdtree.tree.build();
    }
    return 0;
}

static std::optional<ecs_cid> find_producer(world& w) {
    float min_cap = -1.f;
    ecs_cid result;
    for (auto& v : ecs_api::select<ecs::station_producer, ecs::station>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        float cap = (float)station.lorry / station.weights;
        if (cap < min_cap) {
            min_cap = cap;
            result = v.getid();
            if (station.lorry == 0) {
                break;
            }
        }
    }
    if (min_cap < 0.f) {
        return std::nullopt;
    }
    return result;
}

static std::optional<ecs_cid> find_consumer(world& w, ecs::building& starting, uint16_t item) {
    auto& consumers = w.stations.consumers;
    auto it = consumers.find(item);
    if (it == consumers.end()) {
        return std::nullopt;
    }
    auto& kdtree = it->second;
    nearest_result result(w);
    if (!kdtree.tree.nearest(result, {starting.x,starting.y})) {
        return std::nullopt;
    }
    return kdtree.dataset[result.value()].cid;
}

enum class station_type {
    producer,
    consumer,
};

static void update_station(world& w, station_type type, ecs::station& station, ecs::building& building) {
    auto& ep = w.rw.Endpoint(station.endpoint);
    auto lorryId = ep.waitingLorry(w.rw);
    if (!lorryId) {
        return;
    }
    auto& l = w.rw.Lorry(lorryId);
    if (!l.ready()) {
        return;
    }
    auto& chestslot = chest::array_at(w, container::index::from(station.chest), 0);
    if (chestslot.item == 0) {
        return;
    }
    switch (type) {
    case station_type::producer:
        if (chestslot.amount == 0 || chestslot.amount < chestslot.limit) {
            break;
        }
        if (auto consumer_cid = find_consumer(w, building, chestslot.item)) {
            ecs_api::entity<ecs::station_consumer, ecs::station> target {w.ecs};
            if (!target.init(*consumer_cid)) {
                break;
            }
            if (ep.setOut(w.rw)) {
                auto& target_station = target.get<ecs::station>();
                auto& target_ep = w.rw.Endpoint(target_station.endpoint);
                chestslot.amount = 0;
                l.item_classid = chestslot.item;
                l.item_amount = chestslot.amount;
                l.ending = target_ep.rev_neighbor;
                station.lorry--;
                target_station.lorry++;
            }
        }
        break;
    case station_type::consumer:
        if (chestslot.amount > 0) {
            break;
        }
        if (auto producer_cid = find_producer(w)) {
            ecs_api::entity<ecs::station_producer, ecs::station> target {w.ecs};
            if (!target.init(*producer_cid)) {
                break;
            }
            if (ep.setOut(w.rw)) {
                auto& target_station = target.get<ecs::station>();
                auto& target_ep = w.rw.Endpoint(target_station.endpoint);
                chestslot.amount = l.item_amount;
                l.item_classid = 0;
                l.item_amount = 0;
                l.ending = target_ep.rev_neighbor;
                station.lorry--;
                target_station.lorry++;
            }
        }
        break;
    default:
        std::unreachable();
    }
}

static int lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : ecs_api::select<ecs::station_producer, ecs::station, ecs::building>(w.ecs)) {
        update_station(w, station_type::producer, v.get<ecs::station>(), v.get<ecs::building>());
    }
    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::station, ecs::building>(w.ecs)) {
        update_station(w, station_type::consumer, v.get<ecs::station>(), v.get<ecs::building>());
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
