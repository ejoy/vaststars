#include <lua.hpp>
#include <string>
#include <map>
#include "roadnet/coord.h"
#include "roadnet/world.h"
#include "core/world.h"

static world& getworld(lua_State* L, int idx) {
    return *(world*)lua_touserdata(L, idx);
}

static roadnet::world& getrworld(lua_State* L, int idx = 1) {
    return getworld(L, idx).rw;
}

namespace roadnet::lua {
    static std::string_view get_strview(lua_State* L, int idx) {
        size_t len = 0;
        const char* buf = luaL_checklstring(L, idx, &len);
        return std::string_view(buf, len);
    }

    static map_coord get_map_coord(lua_State* L, int idx) {
        auto v = luaL_checkinteger(L, idx);
        uint8_t x = (uint8_t)((v >>  0) & 0xFF);
        uint8_t y = (uint8_t)((v >>  8) & 0xFF);
        uint8_t z = (uint8_t)((v >> 16) & 0xFF);
        return {x,y,z};
    }

    static road_coord get_road_coord(lua_State* L, int idx) {
        auto v = luaL_checkinteger(L, idx);
        uint16_t id     = (uint16_t)((v >>  0) & 0xFFFF);
        uint16_t offset = (uint16_t)((v >> 16) & 0xFFFF);
        return {id, offset};
    }

    static loction get_loction(lua_State* L, int idx) {
        auto v = luaL_checkinteger(L, idx);
        uint8_t x = (uint8_t)((v >>  0) & 0xFF);
        uint8_t y = (uint8_t)((v >>  8) & 0xFF);
        return {x,y};
    }

    static std::map<loction, uint8_t> get_map_data(lua_State* L, int idx) {
        std::map<loction, uint8_t> map;
        luaL_checktype(L, idx, LUA_TTABLE);
        for(lua_pushnil(L); lua_next(L, idx); lua_pop(L, 1)) {
            auto l = get_loction(L, -2);
            uint8_t m = (uint8_t)luaL_checkinteger(L, -1);
            map.emplace(l, m);
        }
        return map;
    }

    static void push_map_coord(lua_State* L, map_coord& c) {
        uint32_t v = 0;
        v |= (uint32_t)c.x <<  0;
        v |= (uint32_t)c.y <<  8;
        v |= (uint32_t)c.z << 16;
        lua_pushinteger(L, v);
    }

    static void push_road_coord(lua_State* L, road_coord& c) {
        uint32_t v = 0;
        v |= (uint32_t)c.id.toint();
        v |= (uint32_t)c.offset << 16;
        lua_pushinteger(L, v);
    }

    static void push_route_map(lua_State* L, int from, int to, int cost) {
        lua_createtable(L, 4, 0);

        lua_pushinteger(L, 1);
        lua_pushinteger(L, from);
        lua_settable(L, -3);

        lua_pushinteger(L, 2);
        lua_pushinteger(L, to);
        lua_settable(L, -3);
        
        lua_pushinteger(L, 3);
        lua_pushinteger(L, cost);
        lua_settable(L, -3);
    }

    namespace world {
        static int load_map(lua_State* L) {
            auto& w = getrworld(L);
            w.loadMap(get_map_data(L, 2));
            return 0;
        }
        static int get_map(lua_State* L) {
            auto& w = getrworld(L);
            lua_createtable(L, 0, 0);
            for(auto& [l, m] : w.getMap()) {
                lua_pushinteger(L, l.id);
                lua_pushinteger(L, m);
                lua_settable(L, -3);
            }
            return 1;
        }
        static int create_lorry(lua_State* L) {
            auto& w = getrworld(L);
            lua_pushinteger(L, w.createLorry().id);
            return 1;
        }
        static int create_endpoint(lua_State* L) {
            auto& w = getrworld(L);
            auto connection_x ((uint8_t)luaL_checkinteger(L, 2));
            auto connection_y ((uint8_t)luaL_checkinteger(L, 3));
            auto connection_dir ((direction)luaL_checkinteger(L, 4));
            lua_pushinteger(L, w.createEndpoint(connection_x, connection_y, connection_dir).id);
            return 1;
        }
        static int map_coord(lua_State* L) {
            auto& w = getrworld(L);
            auto r = w.coordConvert(get_road_coord(L, 2));
            push_map_coord(L, r);
            return 1;
        }
        struct eachlorry {
            bool cross = true;
            uint32_t index = 0;
            uint16_t straight = 0;
            lorryid next(lua_State* L, roadnet::world& w, roadnet::road_coord& coord) {
                if (cross) {
                    if (index < 2 * w.crossAry.size()) {
                        uint16_t road_idx = (uint16_t)(index / 2);
                        uint8_t  entry_idx = index % 2;
                        index++;
                        auto& road = w.crossAry[road_idx];
                        auto& id = road.cross_lorry[entry_idx];
                        if (id != roadnet::lorryid::invalid()) {
                            coord = {{1, road_idx}, (uint16_t)road.cross_status[entry_idx]};
                            return id;
                        }
                        return next(L, w, coord);
                    }
                    cross = false;
                    index = 0;
                }
                
                if (index < w.lorryAry.size()) {
                    auto& id = w.lorryAry[index];
                    if (id != roadnet::lorryid::invalid()) {
                        while (index >= w.straightAry[straight].lorryOffset + w.straightAry[straight].len) {
                            straight++;
                        }
                        coord = {{0, straight}, (uint16_t)(index - w.straightAry[straight].lorryOffset)};
                        index++;
                        return id;
                    }
                    index++;
                    return next(L, w, coord);
                }
                return roadnet::lorryid::invalid();
            }

            static eachlorry& get(lua_State* L, int idx) {
                return *static_cast<eachlorry*>(lua_touserdata(L, idx));
            }
            static int next(lua_State* L) {
                auto& w = getrworld(L, lua_upvalueindex(2));
                eachlorry& self = get(L, lua_upvalueindex(1));
                roadnet::road_coord coord;
                auto id = self.next(L, w, coord);
                if (id == roadnet::lorryid::invalid()) {
                    return 0;
                }
                lua_pushinteger(L, id.id);
                push_road_coord(L, coord);
                lua_pushinteger(L, w.Lorry(id).tick);
                return 3;
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
    }
}

extern "C" int
luaopen_vaststars_roadnet_core(lua_State* L) {
    luaL_Reg l[] = {
        { "load_map", roadnet::lua::world::load_map },
        { "get_map", roadnet::lua::world::get_map },
        { "create_lorry", roadnet::lua::world::create_lorry},
        { "create_endpoint", roadnet::lua::world::create_endpoint},
        { "map_coord", roadnet::lua::world::map_coord },
        { "each_lorry", roadnet::lua::world::each_lorry },
        { NULL, NULL },
    };
    luaL_newlib(L,l);
    return 1;
}
