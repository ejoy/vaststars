#define LUA_LIB
 
#include <lua.h>
#include <lauxlib.h>
#include <string.h>
 
#define PROTOTYPE_IMPLEMENTATION
#include "prototype.h"
 
static void
fetch_value(lua_State *L, struct prototype_cache *c, int id, const char *name, int type) {
	if (id == 0)
		luaL_error(L, "Invalid id 0");
	if (c->last != id) {
		c->last = 0;
		lua_settop(c->L, 1);
		if (lua_geti(c->L, 1, id) != LUA_TTABLE) {
			lua_pop(c->L, 1);
			luaL_error(L, "Absent id %d", id);
		}
		c->last = id;
	}
	lua_settop(c->L, 2);
	if (lua_getfield(c->L, 2, name) != type) {
		lua_pop(c->L, 1);
		luaL_error(L, "Invalid type .%s for %d", name, id);
	}
}
 
static lua_Number
read_float_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TNUMBER);
	return lua_tonumber(c->L, 3);
}
 
static lua_Integer
read_int_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TNUMBER);
	if (!lua_isinteger(c->L, 3)) {
		luaL_error(L, ".%s is not an integer", name);
	}
	return lua_tointeger(c->L, 3);
}
 
static int
read_bool_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TBOOLEAN);
	return lua_toboolean(c->L, 3);
}
 
static const char *
read_string_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TSTRING);
	return lua_tostring(c->L, 3);
}
 
struct prototype_cache* prototype_core(lua_State *L, int idx) {
	struct prototype_cache *cache = (struct prototype_cache *)lua_newuserdatauv(L, sizeof(*cache), 1);
	memset(cache, 0, sizeof(*cache));
	cache->L = lua_newthread(L);
	lua_setiuservalue(L, -2, 1);
	lua_pushvalue(L, idx);
	lua_xmove(L, cache->L, 1);
	return cache;
}
 
#ifdef TEST_PROTOTYPE
 
static int
lpower(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	int id = luaL_checkinteger(L, 2);
	struct prototype_cache *cache = (struct prototype_cache *)lua_touserdata(L, 1);
	float power = pt_power(L, cache, id);
	lua_pushnumber(L, power);
	return 1;
}
 
static int
lcount(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	int id = luaL_checkinteger(L, 2);
	struct prototype_cache *cache = (struct prototype_cache *)lua_touserdata(L, 1);
	int count = pt_count(L, cache, id);
	lua_pushinteger(L, count);
	return 1;
}
 
static int
lenable(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	int id = luaL_checkinteger(L, 2);
	struct prototype_cache *cache = (struct prototype_cache *)lua_touserdata(L, 1);
	int enable = pt_enable(L, cache, id);
	lua_pushboolean(L, enable);
	return 1;
}
 
static int
lname(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	int id = luaL_checkinteger(L, 2);
	struct prototype_cache *cache = (struct prototype_cache *)lua_touserdata(L, 1);
	const char * name = pt_name(L, cache, id);
	lua_pushstring(L, name);
	return 1;
}
 
LUAMOD_API int
luaopen_vaststars_prototype_test(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "power", lpower },
		{ "count", lcount },
		{ "enable", lenable },
		{ "name", lname },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
 
#endif
