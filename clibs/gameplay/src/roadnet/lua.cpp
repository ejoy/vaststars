#include <lua.hpp>
#include <string>
#include "roadnet/type.h"
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
        if (map.empty()) {
            w.cleanMap(get_world(L));
            lua_newtable(L);
            return 1;
        }
        auto endpointMap = w.updateMap(get_world(L), map);
        lua_createtable(L, 0, (int)endpointMap.size());
        lua_Integer n = 0;
        for (const auto& [loc, ep] : endpointMap) {
            lua_pushinteger(L, loc.id);
            lua_pushinteger(L, std::bit_cast<uint32_t>(ep));
            lua_rawset(L, -3);
        }
        return 1;
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
        using result_type = std::tuple<lorryid, map_coord>;
        void reset() {
            status = status::cross;
            index = 0;
            straightId = 0;
        }
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
                    map_coord coord {road.getLoction(w), map_index::w1, road.cross_status[entry_idx]};
                    return std::make_tuple(id, coord);
                }
            }
        }
        result_type next_straight(roadnet::network& w) {
            for (;;) {
                if (index >= w.straightLorry.size()) {
                    status = status::finish;
                    return {};
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
                return {};
            }
        }
        static eachlorry& get(lua_State* L, int idx) {
            return *static_cast<eachlorry*>(lua_touserdata(L, idx));
        }
        static int next(lua_State* L) {
            auto& w = get_network(L, lua_upvalueindex(2));
            eachlorry& self = get(L, lua_upvalueindex(1));
            auto [lorryid, coord] = self.next(w);
            if (!lorryid) {
                return 0;
            }
            lua_pushinteger(L, lorryid.get_index());
            lua_pushinteger(L, coord.get_value());
            return 2;
        }
        static int gc(lua_State* L) {
            get(L, 1).~eachlorry();
            return 0;
        }
    };
    static int sync_lorry(lua_State* L) {
        auto& w = get_network(L);
        lua_Integer n = luaL_len(L, lua_upvalueindex(1));
        if (n < (lua_Integer)w.lorryVec.size()) {
            ptrdiff_t diff = w.lorryVec.size() - n;
            for (ptrdiff_t i = 0; i < diff; ++i) {
                lua_createtable(L, 0, 5);
                lua_rawseti(L, lua_upvalueindex(1), n+1+i);
            }
        }
        return 0;
    }
    static int each_lorry(lua_State* L) {
        sync_lorry(L);
        eachlorry& self = eachlorry::get(L, lua_upvalueindex(2));
        self.reset();
        lua_pushvalue(L, lua_upvalueindex(2));
        lua_pushvalue(L, 1);
        lua_pushcclosure(L, eachlorry::next, 2);
        return 1;
    }
    static int lorry(lua_State* L) {
        auto& w = get_network(L);
        lorryid lorryId = (uint16_t)luaL_checkinteger(L, 2);
        auto& l = w.Lorry(lorryId);
        auto [item_classid, item_amount] = l.get_item();
        auto [progress, maxprogress] = l.get_progress();
        lua_rawgeti(L, lua_upvalueindex(1), lorryId.get_index() + 1);
        lua_pushinteger(L, l.get_classid());
        lua_setfield(L, -2, "classid");
        lua_pushinteger(L, item_classid);
        lua_setfield(L, -2, "item");
        lua_pushinteger(L, item_amount);
        lua_setfield(L, -2, "amount");
        lua_pushinteger(L, progress);
        lua_setfield(L, -2, "progress");
        lua_pushinteger(L, maxprogress);
        lua_setfield(L, -2, "maxprogress");
        return 1;
    }
    static int remove_lorry(lua_State* L) {
        return 0;
    }
}

extern "C" int
luaopen_vaststars_roadnet_core(lua_State* L) {
    luaL_Reg lib[] = {
        { "reset", roadnet::lua::reset },
        { "each_lorry", NULL },
        { "lorry", NULL },
        { "remove_lorry", roadnet::lua::remove_lorry },
        { NULL, NULL },
    };
    luaL_newlib(L, lib);
    luaL_Reg lorry_lib[] = {
        { "each_lorry", roadnet::lua::each_lorry },
        { "lorry", roadnet::lua::lorry },
        { NULL, NULL },
    };
    lua_newtable(L);
    void* storage = lua_newuserdatauv(L, sizeof(roadnet::lua::eachlorry), 0);
    new (storage) roadnet::lua::eachlorry;
    if (luaL_newmetatable(L, "roadnet::each_lorry")) {
        static luaL_Reg mt[] = {
            { "__gc", roadnet::lua::eachlorry::gc },
            { NULL, NULL },
        };
        luaL_setfuncs(L, mt, 0);
    }
    lua_setmetatable(L, -2);
    luaL_setfuncs(L, lorry_lib, 2);
    return 1;
}
