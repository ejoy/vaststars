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

static float
read_float_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TNUMBER);
	return (float)lua_tonumber(c->L, 3);
}

static int
read_int_lua(lua_State *L, struct prototype_cache *c, int id, const char *name) {
	fetch_value(L, c, id, name, LUA_TNUMBER);
	if (!lua_isinteger(c->L, 3)) {
		luaL_error(L, ".%s is not an integer", name);
	}
	return (int)lua_tointeger(c->L, 3);
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

static int
insert_type(lua_State *L) {
	int id = (int)luaL_checkinteger(L, 2);
	if (id == 0) {
		return luaL_error(L, "Invalid id 0");
	}
	luaL_checktype(L, 3, LUA_TTABLE);
	lua_getiuservalue(L, 1, 1);
	lua_State *cL = lua_tothread(L, -1);
	if (lua_geti(cL, 1, id) != LUA_TNIL) {
		lua_pop(cL, 1);
		return luaL_error(L, "Duplicated id %d", id);
	}
	lua_pop(cL, 1);
	lua_settop(L, 3);
	lua_xmove(L, cL, 1);
	lua_seti(cL, 1, id);
	return 0;
}

static int
get_type(lua_State *L) {
	int id = (int)luaL_checkinteger(L, 2);
	lua_getiuservalue(L, 1, 1);
	lua_State *cL = lua_tothread(L, -1);
	lua_geti(cL, 1, id);
	lua_xmove(cL, L, 1);
	return 1;
}

static void
prototype_meta(lua_State *L) {
	luaL_Reg l[] = {
		{ "__newindex", insert_type },
		{ "__index", get_type },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
}

LUAMOD_API int
luaopen_vaststars_prototype_core(lua_State *L) {
	luaL_checkversion(L);
	struct prototype_cache *cache = (struct prototype_cache *)lua_newuserdatauv(L, sizeof(*cache), 1);
	memset(cache, 0, sizeof(*cache));
	cache->L = lua_newthread(L);
	lua_setiuservalue(L, -2, 1);
	lua_newtable(cache->L);
	prototype_meta(L);
	lua_setmetatable(L, -2);
	return 1;
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