#include "system/station.h"
#include "core/world.h"
#include "core/capacitance.h"
#include "util/prototype.h"
#include "luaecs.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

template <>
struct std::less<station_ref> {
    constexpr bool operator()(const station_ref& a, const station_ref& b) const {
        return ((uint32_t)a.ptr->lorry * b.ptr->weights) < ((uint32_t)b.ptr->lorry * a.ptr->weights);
    }
};

static void producer_sort(station_vector& producers) {
    std::sort(producers.begin(), producers.end(), std::less<station_ref> {});
}

static void producer_update(station_vector& producers, size_t idx) {
    ecs::station new_value = *producers[idx].ptr;
    station_ref new_ref { &new_value };
    new_value.lorry++;
    auto it = std::lower_bound(producers.begin(), producers.end(), new_ref, std::less<station_ref> {});
    auto old_it = producers.begin() + idx;
    old_it->ptr->lorry++;
    if (old_it == it) {
    }
    else if (old_it < it) {
        std::rotate(old_it, old_it + 1, it);
    }
    else if (it < old_it) {
        std::rotate(it, old_it, old_it + 1);
    }
}

static std::optional<size_t> find_producer(world& w, station_vector& producers, const roadnet::road::endpoint& from) {
    for (size_t i = 0; i < producers.size(); ++i) {
        const auto& ep = w.rw.Endpoint(producers[i].ptr->endpoint);
        if (from.distance(w.rw, ep)) {
            return i;
        }
    }
    return std::nullopt;
}

static void goto_producer(world& w, station_vector& producers, size_t producer_idx, roadnet::lorry& l, roadnet::road::endpoint& ep) {
    auto& producer = *producers[producer_idx].ptr;
    auto& producer_ep = w.rw.Endpoint(producer.endpoint);
    l.go(producer_ep.rev_neighbor, 0, 0);
    producer_update(producers, producer_idx);
}

static std::optional<station_ref> find_consumer(world& w, uint16_t item, const roadnet::road::endpoint& from) {
    auto it = w.stations.consumers.find(item);
    if (it == w.stations.consumers.end()) {
        return std::nullopt;
    }
    uint16_t min_distance = (uint16_t)-1;
    std::optional<station_ref> min_station;
    auto& consumers = it->second;
    for (size_t i = 0; i < consumers.size(); ++i) {
        auto station = consumers[i];
        const auto& ep = w.rw.Endpoint(consumers[i].ptr->endpoint);
        if (station.ptr->lorry < station.ptr->weights) {
            if (auto distance = from.distance(w.rw, ep)) {
                if (*distance < min_distance) {
                    min_distance = *distance;
                    min_station = station;
                }
            }
        }
    }
    return min_station;
}

static std::optional<uint8_t> recipeFirstOutput(world& w, uint16_t recipe) {
    if (recipe == 0) {
        return std::nullopt;
    }
    auto const& ingredients = prototype::get<"ingredients", recipe_items>(w, recipe);
    auto const& results = prototype::get<"results", recipe_items>(w, recipe);
    if (results.n == 0) {
        return std::nullopt;
    }
    if (ingredients.n >= (std::numeric_limits<uint8_t>::max)()) {
        return std::nullopt;
    }
    return (uint8_t)ingredients.n;
}

static int lbuild(lua_State *L) {
    auto& w = getworld(L);
    auto& s = w.stations;

    s.consumers.clear();
    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::station>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        if (station.endpoint == 0xFFFF) {
            continue;
        }
        auto& chestslot = chest::array_at(w, container::index::from(station.chest), 0);
        auto& consumers = s.consumers[chestslot.item];
        consumers.emplace_back(station_ref{&station});
    }

    s.producers.clear();
    size_t sz = ecs_api::count<ecs::station_producer>(w.ecs);
    if (sz != 0) {
        size_t i = 0;
        s.producers.resize(sz);
        for (auto& v : ecs_api::select<ecs::station_producer, ecs::station>(w.ecs)) {
            auto& station = v.get<ecs::station>();
            if (station.endpoint == 0xFFFF) {
                continue;
            }
            s.producers[i++].ptr = &station;
        }
        s.producers.resize(i);
        producer_sort(s.producers);
    }
    return 0;
}

static int lupdate(lua_State *L) {
    auto& w = getworld(L);
    auto& s = w.stations;
    if (s.producers.empty()) {
        return 0;
    }
    bool producer_changed = false;
    for (auto& v : ecs_api::select<ecs::station_producer, ecs::station, ecs::building>(w.ecs)) {
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
        if (chestslot.amount == 0 || chestslot.amount < chestslot.limit) {
            continue;
        }
        if (auto pconsumer = find_consumer(w, chestslot.item, ep)) {
            ep.setOutForce(w.rw);
            auto& target_ep = w.rw.Endpoint(pconsumer->ptr->endpoint);
            l.go(target_ep.rev_neighbor, chestslot.item, chestslot.amount);
            chestslot.amount = 0;
            station.lorry--;
            pconsumer->ptr->lorry++;
            producer_changed = true;
        }
    }
    if (producer_changed) {
        producer_sort(s.producers);
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
        auto producer_idx = find_producer(w, s.producers, ep);
        if (!producer_idx) {
            continue;
        }
        chestslot.amount = l.get_item_amount();
        station.lorry--;
        goto_producer(w, s.producers, *producer_idx, l, ep);
        ep.setOutForce(w.rw);
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
        if (chestslot.amount == 0 || chestslot.limit == 0) {
            continue;
        }
        auto producer_idx = find_producer(w, s.producers, ep);
        if (!producer_idx) {
            continue;
        }
        chestslot.amount--;
        chestslot.limit--;
        roadnet::lorryid lorryId = w.rw.createLorry(w, chestslot.item);
        auto& l = w.rw.Lorry(lorryId);
        goto_producer(w, s.producers, *producer_idx, l, ep);
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
