#include <lua.hpp>
#include <string>
#include <map>
#include "roadnet_coord.h"
#include "roadnet_world.h"
#include "core/saveload.h"

namespace roadnet::lua {
    template <typename T>
    static T& class_get(lua_State* L, int idx) {
        return *(T*)lua_touserdata(L, idx);
    }

    template <typename T>
    static int class_destroy(lua_State* L) {
        class_get<T>(L, 1).~T();
        return 0;
    }

    template <typename T>
    struct class_metatable {};

    template <typename T, typename ...Args>
    static int class_create(lua_State* L, const luaL_Reg *l, Args... args) {
        T* v = (T*)lua_newuserdatauv(L, sizeof(T), 0);
        if (!v) {
            throw std::bad_alloc {};
        }
        new (v) T(std::forward<Args>(args)...);
        if (luaL_newmetatable(L, class_metatable<T>::name)) {
            luaL_setfuncs(L, l, 0);
            lua_pushvalue(L, -1);
            lua_setfield(L, -2, "__index");
            lua_pushcfunction(L, class_destroy<T>);
            lua_setfield(L, -2, "__gc");
        }
        lua_setmetatable(L, -2);
        return 1;
    }

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
            auto& w = class_get<roadnet::world>(L, 1);
            w.loadMap(get_map_data(L, 2));
            return 0;
        }
        static int create_lorry(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            lua_pushinteger(L, w.createLorry().id);
            return 1;
        }
        static int place_lorry(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            endpointid e ((uint16_t)luaL_checkinteger(L, 2));
            lorryid l ((uint16_t)luaL_checkinteger(L, 3));
            w.placeLorry(e, l);
            return 0;
        }
        static int create_endpoint(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            auto connection_x ((uint8_t)luaL_checkinteger(L, 2));
            auto connection_y ((uint8_t)luaL_checkinteger(L, 3));
            auto connection_dir ((direction)luaL_checkinteger(L, 4));
            lua_pushinteger(L, w.createEndpoint(connection_x, connection_y, connection_dir).id);
            return 1;
        }
        static int push_lorry(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            lorryid l((uint16_t)luaL_checkinteger(L, 2));
            auto starting((uint16_t)luaL_checkinteger(L, 3));
            auto ending((uint16_t)luaL_checkinteger(L, 4));
            lua_pushboolean(L, w.pushLorry(l, (endpointid)starting, (endpointid)ending));
            return 1;
        }
        static int pop_lorry(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            auto id((uint16_t)luaL_checkinteger(L, 2));
            auto l = w.popLorry((endpointid)id);
            if (l) {
                lua_pushinteger(L, l.id);
            } else {
                lua_pushnil(L);
            }
        }
        static int map_coord(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
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
                auto& w = class_get<roadnet::world>(L, lua_upvalueindex(2));
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
        static int update(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            w.update(0);
            return 0;
        }
        static int backup(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            FILE* f = lua_world::createfile(L, 2, lua_world::filemode::write);
            lua_world::write_dynarray(f, w.crossAry);
            lua_world::write_dynarray(f, w.straightAry);
            lua_world::write_dynarray(f, w.endpointAry);
            lua_world::write_vector(f, w.endpointVec, [&](const endpoint& e) {
                lua_world::file_write(f, e.loc);
                lua_world::write_list(f, e.pushMap);
                lua_world::write_list(f, e.popMap);
                lua_world::file_write(f, e.lorry[0]);
                lua_world::file_write(f, e.lorry[1]);
            });

            lua_world::write_dynarray(f, w.lorryAry);
            lua_world::write_vector(f, w.lorryVec, [&](const lorry& l) {
                lua_world::file_write(f, l.tick);
                lua_world::file_write(f, l.ending);
                lua_world::file_write(f, l.pathIdx);
                lua_world::write_vector(f, l.path);
                lua_world::file_write(f, l.gameplay);
            });

            lua_world::write_vector(f, w.straightVec);
            lua_world::write_map(f, w.map);
            lua_world::write_map(f, w.crossMap);
            lua_world::write_map(f, w.crossMapR);
            lua_world::write_map(f, w.EndpointToRoadcoordMap);
            fclose(f);
            return 0;
        }
        static int restore(lua_State* L) {
            auto& w = class_get<roadnet::world>(L, 1);
            FILE* f = lua_world::createfile(L, 2, lua_world::filemode::read);
            lua_world::read_dynarray(f, w.crossAry);
            lua_world::read_dynarray(f, w.straightAry);
            lua_world::read_dynarray(f, w.endpointAry);
            lua_world::read_vector(f, w.endpointVec, [&](endpoint& e) {
                lua_world::file_read(f, e.loc);
                lua_world::read_list(f, e.pushMap);
                lua_world::read_list(f, e.popMap);
                lua_world::file_read(f, e.lorry[0]);
                lua_world::file_read(f, e.lorry[1]);
            });
            lua_world::read_dynarray(f, w.lorryAry);
            lua_world::read_vector(f, w.lorryVec, [&](lorry& l) {
                lua_world::file_read(f, l.tick);
                lua_world::file_read(f, l.ending);
                lua_world::file_read(f, l.pathIdx);
                lua_world::read_vector(f, l.path);
                lua_world::file_read(f, l.gameplay);
            });

            lua_world::read_vector(f, w.straightVec);
            lua_world::read_map(f, w.map);
            lua_world::read_map(f, w.crossMap);
            lua_world::read_map(f, w.crossMapR);
            lua_world::read_map(f, w.EndpointToRoadcoordMap);
            fclose(f);
            return 0;
        }
        static int create(lua_State* L) {
            luaL_Reg l[] = {
                { "load_map", load_map },
                { "create_lorry", create_lorry},
                { "create_endpoint", create_endpoint},
                { "push_lorry", push_lorry },
                { "place_lorry", place_lorry },
                { "map_coord", map_coord },
                { "each_lorry", each_lorry },
                { "update", update },
                { "backup", backup },
                { "restore", restore },
                { NULL, NULL },
            };
            class_create<roadnet::world>(L, l);
            lua_pushvalue(L, -1);
            lua_setfield(L, LUA_REGISTRYINDEX, "ROADNET_WORLD");
            return 1;
        }
    }

    template <>
    struct class_metatable<roadnet::world> {
        static inline const char name[] = "roadnet::world";
    };
}

extern "C" int
luaopen_vaststars_roadnet_core(lua_State* L) {
    luaL_Reg l[] = {
        { "create_world", roadnet::lua::world::create },
        { NULL, NULL },
    };
    luaL_newlib(L,l);
    return 1;
}
