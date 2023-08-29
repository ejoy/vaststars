#include "core/world.h"
#include "core/capacitance.h"
#include "util/prototype.h"
#include "roadnet/lorry.h"
#include "roadnet/endpoint.h"
#include "luaecs.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

static int lbuild(lua_State *L) {
    auto& w = getworld(L);
    if (w.dirty & (kDirtyRoadnet | kDirtyPark)) {
        w.market.reset_park();
        for (auto& v : ecs_api::select<ecs::park>(w.ecs)) {
            int id = v.component_index<ecs::endpoint>();
            assert(id >= 0);
            w.market.set_park(id);
        }
    }
    if (w.dirty & kDirtyStation) {
        w.market.reset_station();
        for (auto& v : ecs_api::select<ecs::station, ecs::endpoint, ecs::chest>(w.ecs)) {
            auto& station = v.get<ecs::station>();
            auto& chest = v.get<ecs::chest>();
            auto station_c = container::index::from(station.chest);
            auto chest_c = container::index::from(chest.chest);
            if (station_c == container::kInvalidIndex || chest_c == container::kInvalidIndex) {
                continue;
            }
            container::size_type n = std::min(chest::size(w, station_c), chest::size(w, chest_c));
            for (uint8_t i = 0; i < (uint8_t)n; ++i) {
                auto& station_s = chest::array_at(w, station_c, i);
                if (station_s.item != 0) {
                    if (station_s.type == container::slot::slot_type::supply) {
                        for (uint16_t i = station_s.lock_item; i < station_s.amount; ++i) {
                            w.market.add_supply(v.get_index<ecs::endpoint>(), station_s.item);
                        }
                    }
                    else if (station_s.type == container::slot::slot_type::demand) {
                        for (uint16_t i = station_s.amount + station_s.lock_space; i < station_s.limit; ++i) {
                            w.market.add_demand(v.get_index<ecs::endpoint>(), station_s.item);
                        }
                    }
                }
            }
        }
    }
    return 0;
}

static void startTask(world& w, ecs::lorry& l, market_match const& m) {
    auto from_e = ecs_api::index_entity<ecs::endpoint>(w.ecs, m.from);
    auto from_s = from_e.component<ecs::station>();
    auto from_c = container::index::from(from_s->chest);
    auto to_e   = ecs_api::index_entity<ecs::endpoint>(w.ecs, m.to);
    auto to_s   = to_e.component<ecs::station>();
    auto to_c   = container::index::from(to_s->chest);
    if (auto s = chest::find_item(w, from_c, m.item)) {
        s->lock_item++;
    }
    else {
        assert(false);
    }
    if (auto s = chest::find_item(w, to_c, m.item)) {
        s->lock_space++;
    }
    else {
        assert(false);
    }
    roadnet::lorryGoMov1(l, m.item, from_e.get<ecs::endpoint>(), to_e.get<ecs::endpoint>());
}

static int lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (auto& v : ecs_api::select<ecs::station, ecs::endpoint, ecs::chest>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        auto& chest = v.get<ecs::chest>();
        auto station_c = container::index::from(station.chest);
        auto chest_c = container::index::from(chest.chest);
        if (station_c == container::kInvalidIndex || chest_c == container::kInvalidIndex) {
            continue;
        }
        container::size_type n = std::min(chest::size(w, station_c), chest::size(w, chest_c));
        for (uint8_t i = 0; i < (uint8_t)n; ++i) {
            auto& chest_s = chest::array_at(w, chest_c, i);
            auto& station_s = chest::array_at(w, station_c, i);
            if (chest_s.item != 0) {
                if (chest_s.type == container::slot::slot_type::demand) {
                    if (chest_s.amount >= chest_s.limit && station_s.amount < station_s.limit) {
                        chest_s.amount -= chest_s.limit;
                        station_s.amount++;
                        w.market.add_supply(v.get_index<ecs::endpoint>(), chest_s.item);
                    }
                }
                else if (chest_s.type == container::slot::slot_type::supply) {
                    if (chest_s.amount == 0 && station_s.amount > 0) {
                        chest_s.amount += chest_s.limit;
                        station_s.amount--;
                        w.market.add_demand(v.get_index<ecs::endpoint>(), chest_s.item);
                    }
                }
            }
        }
    }
    w.market.match_begin(w);
    for (auto& v : ecs_api::select<ecs::station, ecs::endpoint, ecs::chest>(w.ecs)) {
        auto& station = v.get<ecs::station>();
        auto& endpoint = v.get<ecs::endpoint>();
        auto& chest = v.get<ecs::chest>();
        auto station_c = container::index::from(station.chest);
        auto chest_c = container::index::from(chest.chest);
        if (station_c == container::kInvalidIndex || chest_c == container::kInvalidIndex) {
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
        container::size_type n = std::min(chest::size(w, station_c), chest::size(w, chest_c));
        switch (l.target) {
        case roadnet::lorry_target::mov1: {
            bool valid = false;
            for (uint8_t i = 0; i < (uint8_t)n; ++i) {
                auto& chest_s = chest::array_at(w, chest_c, i);
                auto& station_s = chest::array_at(w, station_c, i);
                if (station_s.type == container::slot::slot_type::supply && station_s.item == l.item_prototype) {
                    valid = true;
                    if (station_s.amount > 0) {
                        station_s.amount--;
                        station_s.lock_item--;
                        roadnet::lorryGoMov2(l, l.mov2, chest_s.limit);
                        roadnet::endpointSetOut(w, endpoint);
                        break;
                    }
                }
            }
            if (!valid) {
                assert(false);
            }
            break;
        }
        case roadnet::lorry_target::mov2: {
            bool valid = false;
            for (uint8_t i = 0; i < (uint8_t)n; ++i) {
                auto& station_s = chest::array_at(w, station_c, i);
                if (station_s.type == container::slot::slot_type::demand && station_s.item == l.item_prototype) {
                    valid = true;
                    if (station_s.amount < station_s.limit) {
                        if (auto res = w.market.match(w, endpoint.neighbor)) {
                            station_s.amount++;
                            station_s.lock_space--;
                            startTask(w, l, *res);
                            roadnet::endpointSetOut(w, endpoint);
                        }
                        else if (auto home = w.market.nearest_park(w, endpoint.neighbor); home != 0xffff) {
                            station_s.amount++;
                            station_s.lock_space--;
                            auto endpoints = ecs_api::array<ecs::endpoint>(w.ecs);
                            roadnet::lorryGoHome(l, endpoints[home]);
                            roadnet::endpointSetOut(w, endpoint);
                        }
                        break;
                    }
                }
            }
            if (!valid) {
                assert(false);
            }
            break;
        }
        case roadnet::lorry_target::home:
            assert(false);
            break;
        default:
            std::unreachable();
        }
    }
    for (auto& v : ecs_api::select<ecs::park, ecs::endpoint>(w.ecs)) {
        auto& endpoint = v.get<ecs::endpoint>();
        if (!endpoint.neighbor) {
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
        if (auto res = w.market.match(w, endpoint.neighbor)) {
            assert(l.target == roadnet::lorry_target::home);
            startTask(w, l, *res);
            roadnet::endpointSetOut(w, endpoint);
        }
    }
    for (auto& v : ecs_api::select<ecs::factory, ecs::starting, ecs::chest>(w.ecs)) {
        auto& starting = v.get<ecs::starting>();
        if (!starting.neighbor) {
            continue;
        }
        auto& chest = v.get<ecs::chest>();
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
        if (auto res = w.market.match(w, starting.neighbor)) {
            chestslot.amount--;
            roadnet::lorryid lorryId = w.rw.createLorry(w, chestslot.item);
            auto& l = w.rw.Lorry(w, lorryId);
            startTask(w, l, *res);
            roadnet::startingSetOut(w, starting, lorryId);
        }
    }
    w.market.match_end(w);
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
