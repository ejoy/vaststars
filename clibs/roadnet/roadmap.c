#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <assert.h>

#define MAX_EDGE 4

typedef unsigned short crossing_t;
typedef unsigned short length_t;

struct edge {
	crossing_t endpoint;
	length_t len;	
};

struct crossing {
	struct edge e[MAX_EDGE];
};

static int
get_int(lua_State *L, int n) {
	if (lua_geti(L, -1, n) != LUA_TNUMBER) {
		return luaL_error(L, "Need number");
	}
	int v = lua_tointeger(L, -1);
	if (v <=0 || v >= 0x10000)
		return luaL_error(L, "Need integer [1,0xffff]");
	lua_pop(L, 1);
	return v;
}

static int
count_endpoint(lua_State *L, int index) {
	int i;
	int n = 0;
	for (i=1;lua_geti(L, index, i) == LUA_TTABLE;i++) {
		int a = get_int(L, 1);
		int b = get_int(L, 2);
		get_int(L, 3);	// length
		if (a > n)
			n = a;
		if (b > n)
			n = b;
		lua_pop(L,1);
	}
	lua_pop(L, 1);
	return n;
}

static void
insert_edge(lua_State *L, struct crossing *c, int a, int b, int length) {
	struct crossing *edge = &c[a-1];
	int i;
	for (i=0;i<MAX_EDGE;i++) {
		if (edge->e[i].len == 0) {
			edge->e[i].endpoint = b;
			edge->e[i].len = length;
			return;
		} else if (edge->e[i].endpoint == b) {
			if (edge->e[i].len != length) {
				luaL_error(L, "length mismatch %d != %d", (int)edge->e[i].len, length);
			}
			// already insert
			return;
		}
	}
	luaL_error(L, "Too many edges for %d", a);
}

static int
lmap(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	int n = count_endpoint(L, 1);
	struct crossing * c = (struct crossing *)lua_newuserdatauv(L, n * sizeof(struct crossing), 0);
	memset(c, 0, n * sizeof(struct crossing));
	int i;
	for (i=1;lua_geti(L, 1, i) == LUA_TTABLE;i++) {
		int a = get_int(L, 1);
		int b = get_int(L, 2);
		int len = get_int(L, 3);	// length
		insert_edge(L, c, a, b, len);
		insert_edge(L, c, b, a, len);
		lua_pop(L, 1);
	}
	lua_pop(L, 1);
	return 1;
}

static int
ldumpmap(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	size_t sz = lua_rawlen(L, 1);
	int n = sz / sizeof(struct crossing);
	int i,j;
	struct crossing *c = (struct crossing *)lua_touserdata(L, 1);
	for (i=0;i<n;i++) {
		struct crossing *edge = &c[i];
		if (edge->e[0].len > 0) {
			printf("%d :", i+1);
			for (j=0;j < MAX_EDGE;j++) {
				if (edge->e[j].len == 0)
					break;
				printf(" %u(%u)", edge->e[j].endpoint, edge->e[j].len);
			}
			printf("\n");
		}
	}
	return 0;
}


struct route {
	int len;
	crossing_t id;
	crossing_t from;
	crossing_t index;
	unsigned char shortest;
};

static inline struct route *
find_shortest(struct route *r, int n) {
	int i;
	int min_index;
	int min_length = INT_MAX;
	for (i=0;i<n;i++) {
		if (!r[i].shortest && r[i].len < min_length) {
			min_length = r[i].len;
			min_index = i;
		}
	}
	if (min_length < INT_MAX) {
		struct route * s = &r[min_index];
		s->shortest = 1;
		return s;
	}
	return NULL;
}

static inline struct route *
fetch_route(struct route *r, crossing_t id) {
	int index = r[id-1].index;
	if (index == 0) {
		return NULL;
	}
	struct route * result = &r[index-1];
	assert(result->id == id);
	return result;
}

static void
find_route(struct crossing *c, struct route r[], int sz, crossing_t from, crossing_t to) {
	memset(r, 0, sizeof(struct route) * sz);
	int n = 0;
	struct route *current = &r[n++];
	current->len = 0;
	current->id = from;
	current->from = from;
	r[from-1].index = n;

	int i;
	while ((current = find_shortest(r, n))) {
		if (current->id == to) {
			return;
		}
		struct crossing *edge = &c[current->id-1];
		int len = current->len;
		for (i=0;i<MAX_EDGE && edge->e[i].len != 0;i++) {
			crossing_t id = edge->e[i].endpoint;
			int path_len = len + edge->e[i].len;
			struct route *e = fetch_route(r, id);
			if (e == NULL) {
				// new endpoint
				e = &r[n++];
				e->len = path_len;
				e->id = id;
				e->from = current->id;
				r[id-1].index = n;
			} else {
				if (e->len > path_len) {
					e->len = path_len;
					e->from = current->id;
				}
			}
		}
	}
}

static int
findroute(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	unsigned int index = luaL_checkinteger(L, 2);
	crossing_t from = index >> 16;
	crossing_t to = index & 0xffff;
	struct crossing *c = (struct crossing *)lua_touserdata(L, lua_upvalueindex(1));
	size_t sz = lua_rawlen(L, lua_upvalueindex(1));
	int n = sz / sizeof(struct crossing);
	if (from == 0 || from > n)
		return luaL_error(L, "Invalid from %d", from);
	if (to == 0 || to > n)
		return luaL_error(L, "Invalid to %d", to);

	struct route tmp[0x10000];
	find_route(c, tmp, n, from, to);
	crossing_t checkpoint = to;
	crossing_t dest = to;

	while (checkpoint != from) {
		struct route *e = fetch_route(tmp, checkpoint);
		if (e == NULL)
			return 0;
		dest = checkpoint;
		checkpoint = e->from;
		// checkpoint -> dest -> to
		unsigned int index = ((unsigned int)checkpoint << 16) | to;
		lua_pushinteger(L, dest);
		lua_rawseti(L, 1, index);
	}
	lua_pushinteger(L, dest);
	return 1;
}

static int
lroutecache(lua_State *L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	lua_settop(L, 1);
	lua_pushcclosure(L, findroute, 1);
	lua_newtable(L);	// cachetable
	lua_newtable(L);	// metatable
	lua_pushvalue(L, -3);
	lua_setfield(L, -2, "__index");
	lua_setmetatable(L, -2);

	return 1;
}

LUAMOD_API int
luaopen_vaststars_roadmap_core(lua_State* L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "map", lmap },
		{ "dumpmap", ldumpmap },
		{ "routecache", lroutecache },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}