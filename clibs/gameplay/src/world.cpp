#include <lua.hpp>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h>
#include "world.h"
#include "container.h"

#define CONTAINER_TYPE(id)  ((id) & 0x8000)
#define CONTAINER_INDEX(id) ((id) & 0x3FFF)
#define CONTAINER_TYPE_CHEST  0x0000
#define CONTAINER_TYPE_RECIPE 0x8000

template <>
container& world::query_container<container>(uint16_t id) {
    uint16_t idx = CONTAINER_INDEX(id);
    if (CONTAINER_TYPE(id) == CONTAINER_TYPE_CHEST) {
        assert(containers.chest.size() > idx);
        return containers.chest[idx];
    }
    assert(containers.recipe.size() > idx);
    return containers.recipe[idx];
}

template <>
recipe_container& world::query_container<recipe_container>(uint16_t id) {
    uint16_t idx = CONTAINER_INDEX(id);
    assert(CONTAINER_TYPE(id) != CONTAINER_TYPE_CHEST);
    assert(containers.recipe.size() > idx);
    return containers.recipe[idx];
}

template <>
uint16_t world::container_id<chest_container>() {
    return CONTAINER_TYPE_CHEST | (uint16_t)(containers.chest.size()-1);
}

template <>
uint16_t world::container_id<recipe_container>() {
    return CONTAINER_TYPE_RECIPE | (uint16_t)(containers.recipe.size()-1);
}

static int
lcreate_world(lua_State* L) {
	struct world* w = (struct world*)lua_newuserdatauv(L, sizeof(struct world), 0);
	new (w) world;
	w->c.L = L;
	w->c.ecs = (struct ecs_context *)lua_touserdata(L, 1);
	w->c.P = (struct prototype_cache *)lua_touserdata(L, 2);
	return 1;
}

static FILE* tofile(lua_State* L, int idx) {
    struct luaL_Stream* p = (struct luaL_Stream*)luaL_checkudata(L, 2, LUA_FILEHANDLE);
    if (!p->closef)
        luaL_error(L, "attempt to use a closed file");
    lua_assert(p->f);
    return p->f;
}

template <typename T>
void file_write(FILE* f, const T& v) {
    size_t n = fwrite(&v, sizeof(T), 1, f);
    assert(n == 1);
}

template <typename T>
T file_read(FILE* f) {
    T v;
    size_t n = fread(&v, sizeof(T), 1, f);
    assert(n == 1);
    return std::move(v);
}

template <typename T>
void file_write(FILE* f, const T* v, size_t sz) {
    size_t n = fwrite(v, sizeof(T), sz, f);
    assert(n == sz);
}

template <typename T>
void file_read(FILE* f, T* v, size_t sz) {
    size_t n = fread(v, sizeof(T), sz, f);
    assert(n == sz);
}

struct sav_header {
    uint16_t chest_size;
    uint16_t recipe_size;
};

struct sav_chest_header {
    uint16_t slot_size;
    uint16_t used;
    uint16_t size;
};

struct sav_recipe_header {
    uint16_t in_size;
    uint16_t out_size;
};

static int
lbackup_world(lua_State* L) {
    struct world* w = (struct world*)lua_touserdata(L, 1);
    FILE* f = tofile(L, 2);
    sav_header h {
        (uint16_t)w->containers.chest.size(),
        (uint16_t)w->containers.recipe.size(),
    };
    file_write(f, h);
    for (auto const& c : w->containers.chest) {
        sav_chest_header chest_h {
            (uint16_t)c.slots.size(),
            c.used,
            c.size,
        };
        file_write(f, chest_h);
        file_write(f, c.slots.data(), c.slots.size());
    }
    for (auto const& c : w->containers.recipe) {
        sav_recipe_header recipe_h {
            (uint16_t)c.inslots.size(),
            (uint16_t)c.outslots.size(),
        };
        file_write(f, recipe_h);
        file_write(f, c.inslots.data(), c.inslots.size());
        file_write(f, c.outslots.data(), c.outslots.size());
    }
    return 0;
}

static int
lrestore_world(lua_State* L) {
    struct world* w = (struct world*)lua_touserdata(L, 1);
    FILE* f = tofile(L, 2);
    w->fluidflows.clear();
    w->containers.chest.clear();
    w->containers.recipe.clear();
    auto h = file_read<sav_header>(f);
    w->containers.chest.resize(h.chest_size);
    w->containers.recipe.resize(h.recipe_size);
    for (auto& c : w->containers.chest) {
        auto chest_h = file_read<sav_chest_header>(f);
        c.slots.resize(chest_h.slot_size);
        c.used = chest_h.used;
        c.size = chest_h.size;
        file_read(f, c.slots.data(), c.slots.size());
    }
    for (auto& c : w->containers.recipe) {
        auto recipe_h = file_read<sav_recipe_header>(f);
        c.inslots.resize(recipe_h.in_size);
        c.outslots.resize(recipe_h.out_size);
        file_read(f, c.inslots.data(), c.inslots.size());
        file_read(f, c.outslots.data(), c.outslots.size());
    }
    return 0;
}

#if defined(_MSC_VER)
#define MSVC_NONSTDC() _Pragma("warning(suppress: 4996)")
#else
#define MSVC_NONSTDC() 
#endif

static int
lfileno(lua_State* L) {
    struct world* w = (struct world*)lua_touserdata(L, 1);
    FILE* f = tofile(L, 2);
    MSVC_NONSTDC();
    lua_pushinteger(L, fileno(f));
    return 1;
}

extern "C" int
luaopen_vaststars_world_core(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "create_world", lcreate_world },
		{ "backup_world", lbackup_world },
		{ "restore_world", lrestore_world },
		{ "fileno", lfileno },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
