#include <lua.hpp>
#include <string>
#include <map>
#include "roadnet/coord.h"
#include "roadnet/network.h"
#include "core/world.h"
#include <bee/nonstd/bit.h>

namespace roadnet::lua {
    static roadnet::network& get_network(lua_State* L, int idx = 1) {
        auto& w = *(world*)lua_touserdata(L, idx);
        return w.rw;
    }
    static world& get_world(lua_State* L, int idx = 1) {
        return *(world*)lua_touserdata(L, idx);
    }

    static loction get_loction(lua_State* L, int idx) {
        auto v = luaL_checkinteger(L, idx);
        uint8_t x = (uint8_t)((v >>  0) & 0xFF);
        uint8_t y = (uint8_t)((v >>  8) & 0xFF);
        return {x,y};
    }

    static void push_map_coord(lua_State* L, map_coord& c) {
        uint32_t v = std::bit_cast<uint32_t>(c);
        lua_pushinteger(L, v);
    }

    static int reset(lua_State* L) {
        auto& w = get_network(L);
        luaL_checktype(L, 2, LUA_TTABLE);
        flatmap<loction, uint8_t> map;
        lua_pushnil(L);
        while (lua_next(L, 2)) {
            auto l = get_loction(L, -2);
            uint8_t m = (uint8_t)luaL_checkinteger(L, -1);
            map.insert_or_assign(l, m);
            lua_pop(L, 1);
        }
        w.updateMap(map);
        return 0;
    }

    struct eachlorry {
        enum class status {
            cross,
            straight,
            finish,
        };
        status status = status::cross;
        uint32_t index = 0;
        uint16_t straightId = 0;
        using result_type = std::optional<std::tuple<lorryid, map_coord>>;
        result_type next_cross(roadnet::network& w) {
            static constexpr int N = 2;
            for (;;) {
                if (index >= N * w.crossAry.size()) {
                    status = status::straight;
                    index = 0;
                    return next_straight(w);
                }
                uint16_t road_idx = (uint16_t)(index / N);
                uint8_t  entry_idx = index % N;
                index++;
                auto& road = w.crossAry[road_idx];
                auto id = road.cross_lorry[entry_idx];
                if (id) {
                    map_coord coord {road.loc, map_index::w1, road.cross_status[entry_idx]};
                    return std::make_tuple(id, coord);
                }
            }
        }
        result_type next_straight(roadnet::network& w) {
            for (;;) {
                if (index >= w.straightLorry.size()) {
                    status = status::finish;
                    return std::nullopt;
                }
                auto& id = w.straightLorry[index];
                if (id) {
                    for (;;) {
                        auto& straight = w.straightAry[straightId];
                        uint32_t offset = index - straight.lorryOffset;
                        if (offset >= straight.len) {
                            straightId++;
                            continue;
                        }
                        index++;
                        map_coord coord = straight.getCoord(w, offset);
                        return std::make_tuple(id, coord);
                    }
                }
                index++;
            }
        }
        result_type next(roadnet::network& w) {
            switch (status) {
            case status::cross:
                return next_cross(w);
            case status::straight:
                return next_straight(w);
            default:
            case status::finish:
                return std::nullopt;
            }
        }
        static eachlorry& get(lua_State* L, int idx) {
            return *static_cast<eachlorry*>(lua_touserdata(L, idx));
        }
        static int next(lua_State* L) {
            auto& w = get_network(L, lua_upvalueindex(2));
            eachlorry& self = get(L, lua_upvalueindex(1));
            auto res = self.next(w);
            if (!res) {
                return 0;
            }
            auto lorryid = std::get<0>(*res);
            auto& l = w.Lorry(lorryid);
            lua_pushinteger(L, lorryid.id);
            lua_pushinteger(L, l.get_classid());
            auto [item_classid, item_amount] = l.get_item();
            lua_pushinteger(L, item_classid);
            lua_pushinteger(L, item_amount);
            push_map_coord(L, std::get<1>(*res));
            auto [progress, maxprogress] = l.get_progress();
            lua_pushinteger(L, progress);
            lua_pushinteger(L, maxprogress);
            return 7;
        }
        static int gc(lua_State* L) {
            get(L, 1).~eachlorry();
            return 0;
        }
    };
    static int each_lorry(lua_State* L) {
        void* storage = lua_newuserdatauv(L, sizeof(eachlorry), 0);
        new (storage) eachlorry;
        if (luaL_newmetatable(L, "roadnet::each_lorry")) {
            static luaL_Reg mt[] = {
                {"__gc", eachlorry::gc},
                {NULL, NULL},
            };
            luaL_setfuncs(L, mt, 0);
        }
        lua_setmetatable(L, -2);
        lua_pushvalue(L, -1);
        lua_pushvalue(L, 1);
        lua_pushcclosure(L, eachlorry::next, 2);
        return 1;
    }
    static int endpoint_loction(lua_State* L) {
        auto& w = get_network(L);
        lua_createtable(L, 0, (int)w.endpointAry.size());
        lua_Integer n = 0;
        for (const auto& ep : w.endpointAry) {
            lua_pushinteger(L, ep.loc.id);
            lua_pushinteger(L, n++);
            lua_rawset(L, -3);
        }
        return 1;
    }
    static int remove_lorry(lua_State* L) {
        auto& w = get_world(L);
        auto& network = get_network(L);
        network.destroyLorry(w, (lorryid)(uint16_t)luaL_checkinteger(L, 2));
        return 0;
    }
}

extern "C" int
luaopen_vaststars_roadnet_core(lua_State* L) {
    luaL_Reg l[] = {
        { "reset", roadnet::lua::reset },
        { "each_lorry", roadnet::lua::each_lorry },
        { "endpoint_loction", roadnet::lua::endpoint_loction },
        { "remove_lorry", roadnet::lua::remove_lorry},
        { NULL, NULL },
    };
    luaL_newlib(L, l);
    return 1;
}
