#include <lua.hpp>
#include <string>
#include "world.h"

#if defined(_MSC_VER)
#include <windows.h>
static std::wstring u2w(const std::string_view& str) {
    if (str.empty())  {
        return L"";
    }
    int wlen = ::MultiByteToWideChar(CP_UTF8, 0, str.data(), (int)str.size(), NULL, 0);
    if (wlen <= 0)  {
        return L"";
    }
    std::vector<wchar_t> result(wlen);
    ::MultiByteToWideChar(CP_UTF8, 0, str.data(), (int)str.size(), result.data(), wlen);
    return std::wstring(result.data(), result.size());
}
#endif

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

enum class filemode {
    read,
    write,
};

static FILE* createfile(lua_State* L, int idx, const char* filename, filemode mode) {
    size_t sz = 0;
    const char* dir = luaL_checklstring(L, idx, &sz);
    std::string path = std::string(dir, sz) + "/" + filename;
#if defined(_MSC_VER)
    FILE* f = NULL;
    errno_t err = _wfopen_s(&f, u2w(path).c_str(), mode == filemode::read? L"rb": L"wb");
    if (err != 0 || !f) {
        if (!f) {
            fclose(f);
        }
        luaL_error(L, "open file `%s` failed.", path.c_str());
    }
#else
    FILE* f = fopen(path.c_str(), mode == filemode::read? "r": "w");
    if (!f) {
        luaL_error(L, "open file `%s` failed.", path.c_str());
    }
#endif
    return f;
}

static int
lbackup(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    FILE* f = createfile(L, 2, "world.bin", filemode::write);
    sav_header h {
        (uint16_t)w.containers.chest.size(),
        (uint16_t)w.containers.recipe.size(),
    };
    file_write(f, h);
    for (auto const& c : w.containers.chest) {
        sav_chest_header chest_h {
            (uint16_t)c.slots.size(),
            c.used,
            c.size,
        };
        file_write(f, chest_h);
        file_write(f, c.slots.data(), c.slots.size());
    }
    for (auto const& c : w.containers.recipe) {
        sav_recipe_header recipe_h {
            (uint16_t)c.inslots.size(),
            (uint16_t)c.outslots.size(),
        };
        file_write(f, recipe_h);
        file_write(f, c.inslots.data(), c.inslots.size());
        file_write(f, c.outslots.data(), c.outslots.size());
    }
    fclose(f);
    return 0;
}

static int
lrestore(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    FILE* f = createfile(L, 2, "world.bin", filemode::read);
    w.fluidflows.clear();
    w.containers.chest.clear();
    w.containers.recipe.clear();
    auto h = file_read<sav_header>(f);
    w.containers.chest.resize(h.chest_size);
    w.containers.recipe.resize(h.recipe_size);
    for (auto& c : w.containers.chest) {
        auto chest_h = file_read<sav_chest_header>(f);
        c.slots.resize(chest_h.slot_size);
        c.used = chest_h.used;
        c.size = chest_h.size;
        file_read(f, c.slots.data(), c.slots.size());
    }
    for (auto& c : w.containers.recipe) {
        auto recipe_h = file_read<sav_recipe_header>(f);
        c.inslots.resize(recipe_h.in_size);
        c.outslots.resize(recipe_h.out_size);
        file_read(f, c.inslots.data(), c.inslots.size());
        file_read(f, c.outslots.data(), c.outslots.size());
    }
    fclose(f);
    return 0;
}

extern "C" int
luaopen_vaststars_saveload_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "backup", lbackup },
		{ "restore", lrestore },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
