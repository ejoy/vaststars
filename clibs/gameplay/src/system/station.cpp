#include "core/world.h"
#include "core/capacitance.h"
#include "util/prototype.h"
#include "roadnet/lorry.h"
#include "roadnet/endpoint.h"
#include "luaecs.h"
#include "flatmap.h"
#include <lua.hpp>
#include <bee/nonstd/unreachable.h>

static bool station_valid_mov1(world& w, component::lorry&l, uint16_t mov1) {
    for (auto& s : chest::array_slice(w, container::index::from(mov1))) {
        if (s.item == l.item_prototype && s.type == container::slot::slot_type::supply) {
            if (s.amount > s.lock_item) {
                return true;
            }
            return false;
        }
    }
    return false;
}

static void station_lock_mov1(world& w, component::lorry&l, uint16_t mov1) {
    for (auto& s : chest::array_slice(w, container::index::from(mov1))) {
        if (s.item == l.item_prototype && s.type == container::slot::slot_type::supply) {
            s.lock_item++;
            return;
        }
    }
}

static bool station_valid_mov2(world& w, component::lorry&l, uint16_t mov2) {
    for (auto& s : chest::array_slice(w, container::index::from(mov2))) {
        if (s.item == l.item_prototype && s.type == container::slot::slot_type::demand) {
            if (s.limit > s.amount + s.lock_space) {
                return true;
            }
            return false;
        }
    }
    return false;
}

static void station_lock_mov2(world& w, component::lorry&l, uint16_t mov2) {
    for (auto& s : chest::array_slice(w, container::index::from(mov2))) {
        if (s.item == l.item_prototype && s.type == container::slot::slot_type::demand) {
            s.lock_space++;
            return;
        }
    }
}

static void startTask(world& w, component::lorry& l, market_match const& m) {
    auto from_e = ecs_api::index_entity<component::endpoint>(w.ecs, m.from);
    auto from_s = from_e.component<component::station>();
    auto from_c = container::index::from(from_s->chest);
    auto to_e   = ecs_api::index_entity<component::endpoint>(w.ecs, m.to);
    auto to_s   = to_e.component<component::station>();
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
    roadnet::lorryGoMov1(l, m.item, from_e.get<component::endpoint>(), to_e.get<component::endpoint>());
}

static void restartTask(world& w, component::lorry& l, uint16_t to) {
    auto to_e   = ecs_api::index_entity<component::endpoint>(w.ecs, to);
    auto to_s   = to_e.component<component::station>();
    auto to_c   = container::index::from(to_s->chest);
    if (auto s = chest::find_item(w, to_c, l.item_prototype)) {
        s->lock_space++;
    }
    else {
        assert(false);
    }
    roadnet::lorryGoMov2(l, to_e.get<component::endpoint>().rev_neighbor, l.item_amount);
}

static int lbuild(lua_State *L) {
    auto& w = getworld(L);
    if (w.dirty & (kDirtyRoadnet | kDirtyPark)) {
        w.market.reset_park();
        for (auto& v : ecs_api::select<component::park>(w.ecs)) {
            int id = v.component_index<component::endpoint>();
            assert(id >= 0);
            w.market.set_park(id);
        }
    }
    if (w.dirty & (kDirtyEndpoint | kDirtyStation)) {
        flatmap<roadnet::straightid, uint16_t>         stations;
        flatmap<roadnet::lorryid, roadnet::straightid> lorrywhere;
        for (auto& v : ecs_api::select<component::station, component::endpoint>(w.ecs)) {
            auto& station = v.get<component::station>();
            auto& endpoint = v.get<component::endpoint>();
            auto c = container::index::from(station.chest);
            if (c == container::kInvalidIndex) {
                continue;
            }
            stations.insert_or_assign(endpoint.rev_neighbor, station.chest);
            for (auto& s : chest::array_slice(w, c)) {
                s.lock_item = 0;
                s.lock_space = 0;
            }
        }
        for (auto& e : ecs_api::select<component::lorry>(w.ecs)) {
            auto& l = e.get<component::lorry>();
            if (roadnet::lorryInvalid(l)) {
                continue;
            }
            switch (l.target) {
            case roadnet::lorry_target::mov1: {
                auto mov1 = stations.find(l.ending);
                auto mov2 = stations.find(l.mov2);
                if (!mov1 || !mov2) {
                    roadnet::lorryTargetNone(l);
                    lorrywhere.insert_or_assign(w.rw.getLorryId(l), roadnet::straightid{});
                    break;
                }
                if (!station_valid_mov1(w, l, *mov1) || !station_valid_mov2(w, l, *mov2)) {
                    roadnet::lorryTargetNone(l);
                    lorrywhere.insert_or_assign(w.rw.getLorryId(l), roadnet::straightid {});
                    break;
                }
                station_lock_mov1(w, l, *mov1);
                station_lock_mov2(w, l, *mov2);
                break;
            }
            case roadnet::lorry_target::mov2: {
                auto mov2 = stations.find(l.ending);
                if (!mov2) {
                    roadnet::lorryTargetNone(l);
                    lorrywhere.insert_or_assign(w.rw.getLorryId(l), roadnet::straightid{});
                    break;
                }
                if (!station_valid_mov2(w, l, *mov2)) {
                    roadnet::lorryTargetNone(l);
                    lorrywhere.insert_or_assign(w.rw.getLorryId(l), roadnet::straightid {});
                    break;
                }
                station_lock_mov2(w, l, *mov2);
                break;
            }
            case roadnet::lorry_target::home:
                break;
            default:
                std::unreachable();
            }
        }
        w.market.reset_station();
        for (auto& v : ecs_api::select<component::station, component::endpoint>(w.ecs)) {
            auto& station = v.get<component::station>();
            auto c = container::index::from(station.chest);
            if (c == container::kInvalidIndex) {
                continue;
            }
            for (auto& s : chest::array_slice(w, c)) {
                if (s.item == 0) {
                    continue;
                }
                switch (s.type) {
                case container::slot::slot_type::supply:
                    for (uint16_t i = s.lock_item; i < s.amount; ++i) {
                        w.market.add_supply(v.get_index<component::endpoint>(), s.item);
                    }
                    break;
                case container::slot::slot_type::demand:
                    for (uint16_t i = s.amount + s.lock_space; i < s.limit; ++i) {
                        w.market.add_demand(v.get_index<component::endpoint>(), s.item);
                    }
                    break;
                default:
                    break;
                }
            }
        }
        if (!lorrywhere.empty()) {
            for (auto const& cross : w.rw.crossAry) {
                for (size_t i = 0; i < 2; ++i) {
                    if (cross.cross_lorry[i]) {
                        auto [found, slot] = lorrywhere.find_or_insert(cross.cross_lorry[i]);
                        if (found) {
                            auto t = cross.cross_status[i];
                            auto C = cross.neighbor[(uint8_t)t & 0x03u];
                            *slot = C;
                        }
                    }
                }
            }
            uint16_t N = (uint16_t)w.rw.straightAry.size();
            for (uint16_t id = 0; id < N; ++id) {
                auto& straight = w.rw.straightAry[id];
                for (uint16_t i = 0; i < straight.len; ++i) {
                    if (roadnet::lorryid lorryId = w.rw.LorryInRoad(straight.lorryOffset+i)) {
                        auto [found, slot] = lorrywhere.find_or_insert(lorryId);
                        if (found) {
                            *slot = roadnet::straightid{id};
                        }
                    }
                }
            }
            w.market.match_begin(w);
            for (auto& e : ecs_api::select<component::lorry>(w.ecs)) {
                auto& l = e.get<component::lorry>();
                if (roadnet::lorryInvalid(l)) {
                    continue;
                }
                if (l.status != roadnet::lorry_status::target_none) {
                    continue;
                }
                auto C = *lorrywhere.find(w.rw.getLorryId(l));
                if (!C) {
                    assert(false);
                    continue;
                }
                if (l.item_amount == 0) {
                    l.item_prototype = 0;
                    if (auto res = w.market.match(w, C)) {
                        startTask(w, l, *res);
                    }
                    else if (auto home = w.market.nearest_park(w, C); home != 0xffff) {
                        auto endpoints = ecs_api::array<component::endpoint>(w.ecs);
                        roadnet::lorryGoHome(l, endpoints[home]);
                    }
                    else {
                        //do nothing
                    }
                }
                else {
                    uint16_t to;
                    if (w.market.relocate(w, l.item_prototype, C, to)) {
                        restartTask(w, l, to);
                    }
                    else if (auto home = w.market.nearest_park(w, C); home != 0xffff) {
                        auto endpoints = ecs_api::array<component::endpoint>(w.ecs);
                        roadnet::lorryGoHome(l, endpoints[home]);
                    }
                    else {
                        //do nothing
                    }
                }
            }
            w.market.match_end(w);
        }
    }
    return 0;
}

static int lupdate(lua_State *L) {
    auto& w = getworld(L);
    for (auto& v : ecs_api::select<component::station, component::endpoint, component::chest>(w.ecs)) {
        auto& endpoint = v.get<component::endpoint>();
        if (!endpoint.neighbor || !endpoint.rev_neighbor) {
            continue;
        }
        auto& station = v.get<component::station>();
        auto& chest = v.get<component::chest>();
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
                        w.market.add_supply(v.get_index<component::endpoint>(), chest_s.item);
                    }
                }
                else if (chest_s.type == container::slot::slot_type::supply) {
                    if (chest_s.amount == 0 && station_s.amount > 0) {
                        chest_s.amount += chest_s.limit;
                        station_s.amount--;
                        w.market.add_demand(v.get_index<component::endpoint>(), chest_s.item);
                    }
                }
            }
        }
    }
    w.market.match_begin(w);
    for (auto& v : ecs_api::select<component::station, component::endpoint, component::chest>(w.ecs)) {
        auto& endpoint = v.get<component::endpoint>();
        if (!endpoint.neighbor || !endpoint.rev_neighbor) {
            continue;
        }
        auto& station = v.get<component::station>();
        auto& chest = v.get<component::chest>();
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
                            auto endpoints = ecs_api::array<component::endpoint>(w.ecs);
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
    for (auto& v : ecs_api::select<component::park, component::endpoint>(w.ecs)) {
        auto& endpoint = v.get<component::endpoint>();
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
    for (auto& v : ecs_api::select<component::factory, component::starting, component::chest>(w.ecs)) {
        auto& starting = v.get<component::starting>();
        if (!starting.neighbor) {
            continue;
        }
        auto& chest = v.get<component::chest>();
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
