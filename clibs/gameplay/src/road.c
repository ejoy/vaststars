#define LUA_LIB

#include <lua.h>
#include <lauxlib.h>
#include <assert.h>

#include <string.h>
#include <stdlib.h>

#include "entity.h"
#include "luaecs.h"

#define HASHSIZE 2039
#define MAXNODE 0x10000
#define INVALID_DISTANCE 0xffff

static inline int
inthash(unsigned int p) {
	int h = (2654435761 * p) % HASHSIZE;
	return h;
}

union coord {
	unsigned short id;
	struct {
		unsigned char x;
		unsigned char y;
	} c;
};

struct node {
	union coord c;
	unsigned short distance;
	unsigned short rode_type;
};

struct road_map {
	struct node hash[HASHSIZE];
	int conflict_n;
	struct node conflict[MAXNODE];
};

static void
map_init(struct road_map *map) {
	memset(map->hash, -1, sizeof(map->hash));
	map->conflict_n = 0;
}

static int
compar(const void *aa, const void *bb) {
	const struct node *a = (const struct node *)aa;
	const struct node *b = (const struct node *)bb;
	return (int)(a->c.id - b->c.id);
}

static int
sort_conflict(struct road_map *map) {
	qsort(map->conflict, map->conflict_n, sizeof(struct node), compar);
	// remove duplicated
	int i,j;
	for (i=1,j=0;i<map->conflict_n;i++) {
		if (map->conflict[j].c.id != map->conflict[i].c.id) {
			j++;
			map->conflict[j] = map->conflict[i];
		}
	}
	map->conflict_n = j+1;
	return map->conflict_n;
}

static void
map_add(struct road_map *map, union coord c, unsigned short rode_type) {
	int h = inthash(c.id);
	if (map->hash[h].distance == INVALID_DISTANCE) {
		map->hash[h].distance = 0;
		map->hash[h].c = c;
		map->hash[h].rode_type = rode_type;
	} else if (map->hash[h].c.id == c.id) {
		// already added
		return;
	}
	int n;
	if (map->conflict_n >= MAXNODE) {
		n = sort_conflict(map);
		assert(n < MAXNODE);
	} else {
		n = map->conflict_n++;
	}
	map->conflict[n].c = c;
	map->conflict[n].distance = 0;
	map->conflict[n].rode_type = 0;
}

static struct node *
map_lookup(struct road_map *map, union coord c) {
	int h = inthash(c.id);
	if (map->hash[h].distance == INVALID_DISTANCE) {
		return NULL;
	}
	if (map->hash[h].c.id == c.id) {
		return &map->hash[h];
	}
	// conflict, bsearch in conflict
	int begin = 0;
	int end = map->conflict_n;
	while (begin < end) {
		int mid = (begin + end)/2;
		int id = map->conflict[mid].c.id;
		if (id == c.id) {
			return &map->conflict[mid];
		} else if (id < c.id) {
			begin = mid + 1;
		} else {
			end = mid;
		}
	}
	return NULL;
}

static int
checkstation(lua_State *L, int index) {
	int id = luaL_checkinteger(L, index);
	if (id < 0) {
		return luaL_error(L, "Invalid station id %d", id);
	}
	return id;
}

static const int neighbor[4][2] = {
	{ 1, 0 },
	{ -1, 0 },
	{ 0, 1 },
	{ 0, -1 },
};

// C:0; I:1; U:2; T:3; X:4; O:5;
//        y+1(2)
// x-1(1)   c    x-1(0)
//        y-1(3)
static const int rode_type_t_in_dir[6][4] = {
	{1, 0, 0, 1}, // C
	{1, 1, 0, 0}, // I
	{0, 1, 0, 0}, // O
	{1, 1, 0, 1}, // T
	{1, 1, 1, 1}, // X
	{0, 0, 0, 0}, // O
};

static const int dir_90_deg_cntclkws[4] = {
	2, // 0 -> 2
	3, // 1 -> 3
	1, // 2 -> 1
	0, // 3 -> 0
};

static const int in_2_out[4] = {
	1, // 0 -> 1
	0, // 1 -> 0
	3, // 2 -> 3
	2, // 3 -> 2
};

static unsigned short
rotate_dir(unsigned short out_dir, unsigned short times) {
	unsigned short r = out_dir;
	for(int i=0;i<times;i++) {
		r = dir_90_deg_cntclkws[r];
	}
	return r;
}

static void
path_flow(struct road_map *map, union coord starting) {
	int top;
	struct node * stack[MAXNODE];
	stack[0] = map_lookup(map, starting);
	stack[0]->distance = 1;
	top = 1;
	while (top > 0) {
		struct node * n = stack[--top];
		int i;
		int distance = n->distance + 1;
		for (i=0;i<4;i++) {
			int x = n->c.c.x + neighbor[i][0];
			int y = n->c.c.y + neighbor[i][1];
			if (x >= 0 && x < 256 && y >= 0 && y < 256) {
				union coord c;
				c.c.x = (unsigned char)x;
				c.c.y = (unsigned char)y;
				struct node * next = map_lookup(map, c);
				if (next && (next->distance == 0 || next->distance > distance)) {
					assert(top < MAXNODE);

					unsigned short road_type_t = (next->rode_type >> 8) & 0xFF;
					unsigned short rotation_times = next->rode_type & 0xFF;
					assert((road_type_t >= 0 && road_type_t <= 5) && (rotation_times >= 0 && rotation_times <= 3));
					unsigned short out_dir = rotate_dir(in_2_out[i], rotation_times);
					if(rode_type_t_in_dir[road_type_t][out_dir] == 1) {
						next->distance = distance;
						stack[top++] = next;
					}
				}
			}
		}
	}
}

/*
static void
print_map(struct road_map *map) {
	int x,y;
	int line[256];
	int empty = 0;
	for (y=0;y<256;y++) {
		int width = 0;
		for (x=0;x<256;x++) {
			union coord c;
			c.c.x = x;
			c.c.y = y;
			struct node *n = map_lookup(map, c);
			if (n) {
				line[x] = n->distance;
				width = x;
			} else {
				line[x] = 0;
			}
		}
		if (width > 0) {
			int i;
			for (i=0;i<empty;i++) {
				printf("\n");
			}
			empty = 0;
			for (i=0;i<=width;i++) {
				if (line[i]) {
					printf("%3d", line[i]);
				} else {
					printf("   ");
				}
			}
			printf("\n");
		}
	}
}
*/
static int
path(lua_State *L, struct road_map *map, union coord p) {
	struct node * n = map_lookup(map, p);
	int distance = n->distance;
	if (distance == 0)
		return 0;
	lua_createtable(L, distance, 0);
	int index = 1;
	do {
		--distance;
		int i;
		for (i=0;i<4;i++) {
			int x = n->c.c.x + neighbor[i][0];
			int y = n->c.c.y + neighbor[i][1];
			if (x >= 0 && x < 256 && y >= 0 && y < 256) {
				union coord c;
				c.c.x = (unsigned char)x;
				c.c.y = (unsigned char)y;
				struct node *p = map_lookup(map, c);
				if (p && p->distance == distance) {
					lua_pushinteger(L, i);
					lua_rawseti(L, -2, index++);
					n = p;
					break;
				}
			}
		}
	} while (distance > 0);
	return 1;
}

static int
lpath(lua_State *L) {
	struct ecs_context *ctx = (struct ecs_context *)lua_touserdata(L, 1);
	int starting = checkstation(L, 2);
	int ending = checkstation(L, 3);
	if (starting == ending)
		return luaL_error(L, "Starting station should be different to ending station");
	int i;
	struct station *station;
	struct road *road;
	struct road_map map;
	map_init(&map);
	for (i=0;(road = entity_iter(ctx, COMPONENT_ROAD, i));i++) {
		union coord c;
		c.id = road->coord;
		map_add(&map, c, road->road_type);
	}
	qsort(map.conflict, map.conflict_n, sizeof(struct node), compar);
	union coord starting_point;
	union coord ending_point;
	for (i=0;(station  = entity_iter(ctx, COMPONENT_STATION, i));i++) {
		if (station->id == starting) {
			starting_point.id = station->coord;
			starting = -1;
			if (ending < 0)
				break;
		}
		else if (station->id == ending) {
			ending_point.id = station->coord;
			ending = -1;
			if (starting < 0)
				break;
		}
	}
	if (starting >= 0 || ending >=0) {
		return luaL_error(L, "Can't find station %d %d", starting, ending);
	}
	if (map_lookup(&map, starting_point) == NULL) {
		return luaL_error(L, "starting Station (%d %d) is not on road", starting_point.c.x, starting_point.c.y);
	}
	if (map_lookup(&map, ending_point) == NULL) {
		return luaL_error(L, "ending Station (%d %d) is not on road", ending_point.c.x, ending_point.c.y);
	}
	path_flow(&map, ending_point);
//	print_map(&map);
	return path(L, &map, starting_point);
}

LUAMOD_API int
luaopen_vaststars_road_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "path", lpath },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
};
