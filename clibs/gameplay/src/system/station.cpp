#include "system/station.h"
#include "core/world.h"
#include "core/capacitance.h"
#include "util/prototype.h"
#include "roadnet/lorry.h"
#include "roadnet/endpoint.h"
#include "luaecs.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

template <>
struct std::less<station_producer_ref> {
    constexpr bool operator()(const station_producer_ref& a, const station_producer_ref& b) const {
        return ((uint32_t)a.endpoint->lorry * b.station->weights) < ((uint32_t)b.endpoint->lorry * a.station->weights);
    }
};

static void producer_sort(station_vector& producers) {
    std::sort(producers.begin(), producers.end(), std::less<station_producer_ref> {});
}

static void producer_update(station_vector& producers, size_t idx) {
    auto station = *producers[idx].station;
    auto endpoint = *producers[idx].endpoint;
    station_producer_ref new_ref { &station, &endpoint };
    endpoint.lorry++;
    auto it = std::lower_bound(producers.begin(), producers.end(), new_ref, std::less<station_producer_ref> {});
    auto old_it = producers.begin() + idx;
    if (old_it == it) {
    }
    else if (old_it < it) {
        std::rotate(old_it, old_it + 1, it);
    }
    else if (it < old_it) {
        std::rotate(it, old_it, old_it + 1);
    }
}

static std::optional<size_t> find_producer(world& w, station_vector& producers, const ecs::starting& from) {
    for (size_t i = 0; i < producers.size(); ++i) {
        if (roadnet::endpointDistance(w.rw, from, *producers[i].endpoint)) {
            return i;
        }
    }
    return std::nullopt;
}

static std::optional<size_t> find_producer(world& w, station_vector& producers, const ecs::endpoint& from) {
    for (size_t i = 0; i < producers.size(); ++i) {
        if (roadnet::endpointDistance(w.rw, from, *producers[i].endpoint)) {
            return i;
        }
    }
    return std::nullopt;
}

static void goto_producer(world& w, station_vector& producers, size_t producer_idx, ecs::lorry& l) {
    auto& producer = producers[producer_idx];
    producer_update(producers, producer_idx);
    roadnet::lorryItemReset(l);
    roadnet::lorryGo(l, *producer.endpoint);
}

static std::optional<station_consumer_ref> find_consumer(world& w, uint16_t item, const ecs::endpoint& from) {
    auto it = w.stations.consumers.find(item);
    if (it == w.stations.consumers.end()) {
        return std::nullopt;
    }
    uint16_t min_distance = (uint16_t)-1;
    std::optional<station_consumer_ref> min_consumer;
    auto& consumers = it->second;
    for (size_t i = 0; i < consumers.size(); ++i) {
        auto& consumer = consumers[i];
        if (consumer.endpoint->lorry < consumer.station->maxlorry) {
            if (auto distance = roadnet::endpointDistance(w.rw, from, *consumer.endpoint)) {
                if (*distance < min_distance) {
                    min_distance = *distance;
                    min_consumer = consumer;
                }
            }
        }
    }
    return min_consumer;
}

static void rebuild_consumers(world& w) {
    auto& s = w.stations;
    s.consumers.clear();
    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::endpoint, ecs::chest>(w.ecs)) {
        auto& station = v.get<ecs::station_consumer>();
        auto& endpoint = v.get<ecs::endpoint>();
        auto& chest = v.get<ecs::chest>();
        if (!endpoint.neighbor || !endpoint.rev_neighbor) {
            continue;
        }
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        auto& chestslot = chest::array_at(w, c, 0);
        auto& consumers = s.consumers[chestslot.item];
        consumers.emplace_back(station_consumer_ref{&station, &endpoint});
    }
}

static void rebuild_producers(world& w) {
    auto& s = w.stations;
    s.producers.clear();
    size_t sz = ecs_api::count<ecs::station_producer>(w.ecs);
    if (sz != 0) {
        size_t i = 0;
        s.producers.resize(sz);
        for (auto& v : ecs_api::select<ecs::station_producer, ecs::endpoint>(w.ecs)) {
            auto& station = v.get<ecs::station_producer>();
            auto& endpoint = v.get<ecs::endpoint>();
            if (!endpoint.neighbor || !endpoint.rev_neighbor) {
                continue;
            }
            s.producers[i].station = &station;
            s.producers[i].endpoint = &endpoint;
            i++;
        }
        s.producers.resize(i);
        producer_sort(s.producers);
    }
}

static int lrestore_finish(lua_State *L) {
    auto& w = getworld(L);
    rebuild_producers(w);
    rebuild_consumers(w);
    return 0;
}

static int lbuild(lua_State *L) {
    auto& w = getworld(L);
    if (w.dirty & kDirtyStationConsumer) {
        rebuild_consumers(w);
    }
    if (w.dirty & kDirtyStationProducer) {
        rebuild_producers(w);
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
    for (auto& v : ecs_api::select<ecs::station_producer, ecs::endpoint, ecs::chest>(w.ecs)) {
        auto& endpoint = v.get<ecs::endpoint>();
        auto& chest = v.get<ecs::chest>();
        if (!endpoint.neighbor || !endpoint.rev_neighbor) {
            continue;
        }
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        auto lorryId = roadnet::endpointWaitingLorry(w.rw, endpoint);
        if (!lorryId) {
            continue;
        }
        auto& l = w.rw.Lorry(w, lorryId);
        if (!roadnet::lorryReady(l) || !roadnet::endpointIsReady(w.rw, endpoint)) {
            continue;
        }
        auto& chestslot = chest::array_at(w, c, 0);
        if (chestslot.item == 0) {
            continue;
        }
        if (chestslot.amount == 0 || chestslot.amount < chestslot.limit) {
            continue;
        }
        if (auto pconsumer = find_consumer(w, chestslot.item, endpoint)) {
            roadnet::endpointSetOut(w, endpoint);
            roadnet::lorryItemSet(l, chestslot.item, chestslot.amount);
            roadnet::lorryGo(l, *pconsumer->endpoint);
            chestslot.amount = 0;
            endpoint.lorry--;
            producer_changed = true;
        }
    }
    if (producer_changed) {
        producer_sort(s.producers);
    }

    for (auto& v : ecs_api::select<ecs::station_consumer, ecs::endpoint, ecs::chest>(w.ecs)) {
        auto& endpoint = v.get<ecs::endpoint>();
        auto& chest = v.get<ecs::chest>();
        if (!endpoint.neighbor || !endpoint.rev_neighbor) {
            continue;
        }
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        auto lorryId = roadnet::endpointWaitingLorry(w.rw, endpoint);
        if (!lorryId) {
            continue;
        }
        auto& l = w.rw.Lorry(w, lorryId);
        if (!roadnet::lorryReady(l) || !roadnet::endpointIsReady(w.rw, endpoint)) {
            continue;
        }
        auto& chestslot = chest::array_at(w, c, 0);
        if (chestslot.item == 0) {
            continue;
        }
        if (chestslot.amount > 0) {
            continue;
        }
        auto producer_idx = find_producer(w, s.producers, endpoint);
        if (!producer_idx) {
            continue;
        }
        chestslot.amount = l.item_amount;
        endpoint.lorry--;
        roadnet::lorryItemReset(l);
        goto_producer(w, s.producers, *producer_idx, l);
        roadnet::endpointSetOut(w, endpoint);
    }
    for (auto& v : ecs_api::select<ecs::lorry_factory, ecs::starting, ecs::chest>(w.ecs)) {
        auto& starting = v.get<ecs::starting>();
        auto& chest = v.get<ecs::chest>();
        if (!starting.neighbor) {
            continue;
        }
        auto c = container::index::from(chest.chest);
        if (c == container::kInvalidIndex) {
            continue;
        }
        if (!roadnet::startingIsReady(w.rw, starting)) {
            continue;
        }
        auto& chestslot = chest::array_at(w, c, 0);
        if (chestslot.item == 0 || chestslot.amount == 0) {
            continue;
        }
        auto producer_idx = find_producer(w, s.producers, starting);
        if (!producer_idx) {
            continue;
        }
        chestslot.amount--;
        roadnet::lorryid lorryId = w.rw.createLorry(w, chestslot.item);
        auto& l = w.rw.Lorry(w, lorryId);
        goto_producer(w, s.producers, *producer_idx, l);
        roadnet::startingSetOut(w, starting, lorryId);
    }
    return 0;
}

extern "C" int
luaopen_vaststars_station_system(lua_State *L) {
    luaL_checkversion(L);
    luaL_Reg l[] = {
        { "restore_finish", lrestore_finish },
        { "build", lbuild },
        { "update", lupdate },
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
