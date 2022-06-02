#include <lua.hpp>
#include <string>
#include "core/world.h"

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
void file_read(FILE* f, T& v) {
    size_t n = fread(&v, sizeof(T), 1, f);
    assert(n == 1);
}

template <typename T>
void file_write(FILE* f, const T* v, size_t sz) {
    if (sz == 0) {
        return;
    }
    size_t n = fwrite(v, sizeof(T), sz, f);
    assert(n == sz);
}

template <typename T>
void file_read(FILE* f, T* v, size_t sz) {
    if (sz == 0) {
        return;
    }
    size_t n = fread(v, sizeof(T), sz, f);
    assert(n == sz);
}

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

template <typename Map>
static void write_flatmap(FILE* f, const Map& map) {
    auto const& data = map.toraw();
    file_write(f, data.h);
    if (data.h.mask != 0) {
        file_write(f, data.buckets, data.h.mask + 1);
    }
}

template <typename Map>
static void read_flatmap(FILE* f, Map& map) {
    auto& data = map.toraw();
    if (data.h.mask != 0) {
        std::free(data.buckets);
    }
    file_read(f, data.h);
    if (data.h.mask == 0) {
        data.buckets = reinterpret_cast<decltype(data.buckets)>(&data.h.mask);
    }
    else {
        data.buckets = static_cast<decltype(data.buckets)>(std::malloc(sizeof(data.buckets[0]) * (data.h.mask + 1)));
        if (!data.buckets) {
            throw std::bad_alloc {};
        }
        file_read(f, data.buckets, data.h.mask + 1);
    }
}

template <typename Vec>
static void write_vector(FILE* f, const Vec& vec) {
    file_write(f, vec.size());
    file_write(f, vec.data(), vec.size());
}

template <typename Vec>
static void read_vector(FILE* f, Vec& vec) {
    size_t n = 0;
    file_read(f, n);
    vec.resize(n);
    file_read(f, vec.data(), vec.size());
}

namespace sav_container {
    struct header {
        uint16_t chest_size;
        uint16_t recipe_size;
    };

    struct chest_header {
        uint16_t used;
        uint16_t size;
    };

    static void backup(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "container.bin", filemode::write);
        header h {
            (uint16_t)w.containers.chest.size(),
            (uint16_t)w.containers.recipe.size(),
        };
        file_write(f, h);
        for (auto const& c : w.containers.chest) {
            chest_header chest_h {
                c.used,
                c.size,
            };
            file_write(f, chest_h);
            write_vector(f, c.slots);
        }
        for (auto const& c : w.containers.recipe) {
            write_vector(f, c.inslots);
            write_vector(f, c.outslots);
        }
        fclose(f);
    }

    static void restore(lua_State* L, world& w) {
        FILE* f = createfile(L, 2, "container.bin", filemode::read);
        auto h = file_read<header>(f);
        w.containers.chest.resize(h.chest_size);
        w.containers.recipe.resize(h.recipe_size);
        for (auto& c : w.containers.chest) {
            auto chest_h = file_read<chest_header>(f);
            c.used = chest_h.used;
            c.size = chest_h.size;
            read_vector(f, c.slots);
        }
        for (auto& c : w.containers.recipe) {
            read_vector(f, c.inslots);
            read_vector(f, c.outslots);
        }
        fclose(f);
    }
}

static int
lbackup(lua_State* L) {
    world& w = *(world*)lua_touserdata(L, 1);
    FILE* f = createfile(L, 2, "world.bin", filemode::write);
    file_write(f, w.time);
    write_flatmap(f, w.stat.production);
    write_flatmap(f, w.stat.consumption);
    write_vector(f, w.techtree.queue);
    write_flatmap(f, w.techtree.researched);
    write_flatmap(f, w.techtree.progress);
    fclose(f);
    sav_container::backup(L, w);
    return 0;
}

static int
lrestore(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    FILE* f = createfile(L, 2, "world.bin", filemode::read);
    file_read(f, w.time);
    read_flatmap(f, w.stat.production);
    read_flatmap(f, w.stat.consumption);
    read_vector(f, w.techtree.queue);
    read_flatmap(f, w.techtree.researched);
    read_flatmap(f, w.techtree.progress);
    fclose(f);
    sav_container::restore(L, w);
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
