#include <lua.hpp>
#include <string>
#include "core/world.h"
#include <functional>

#if defined(_MSC_VER)
#include <windows.h>
#endif

namespace lua_world {
#if defined(_MSC_VER)
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
        (void)n;
        assert(n == 1);
    }

    template <typename T>
    T file_read(FILE* f) {
        T v;
        size_t n = fread(&v, sizeof(T), 1, f);
        (void)n;
        assert(n == 1);
        return std::move(v);
    }

    template <typename T>
    void file_read(FILE* f, T& v) {
        size_t n = fread(&v, sizeof(T), 1, f);
        (void)n;
        assert(n == 1);
    }

    template <typename T>
    void file_write(FILE* f, const T* v, size_t sz) {
        if (sz == 0) {
            return;
        }
        size_t n = fwrite(v, sizeof(T), sz, f);
        (void)n;
        assert(n == sz);
    }

    template <typename T>
    void file_read(FILE* f, T* v, size_t sz) {
        if (sz == 0) {
            return;
        }
        size_t n = fread(v, sizeof(T), sz, f);
        (void)n;
        assert(n == sz);
    }

    enum class filemode {
        read,
        write,
    };

    static FILE* createfile(lua_State* L, int idx, filemode mode) {
        const char* filename = luaL_checkstring(L, idx);
#if defined(_MSC_VER)
        FILE* f = NULL;
        errno_t err = _wfopen_s(&f, u2w(filename).c_str(), mode == filemode::read? L"rb": L"wb");
        if (err != 0 || !f) {
            if (!f) {
                fclose(f);
            }
            luaL_error(L, "open file `%s` failed.", filename);
        }
#else
        FILE* f = fopen(filename, mode == filemode::read? "r": "w");
        if (!f) {
            luaL_error(L, "open file `%s` failed.", filename);
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

    static void backup_scope(lua_State* L, FILE* f, const char* name, std::function<void()> func) {
        lua_Integer head = (lua_Integer)ftell(f);
        func();
        lua_Integer tail = (lua_Integer)ftell(f);
        lua_pushstring(L, name);
        lua_createtable(L, 2, 0);
        lua_pushinteger(L, head);
        lua_rawseti(L, -2, 1);
        lua_pushinteger(L, tail);
        lua_rawseti(L, -2, 2);
        lua_rawset(L, -3);
    }

    static bool restore_scope(lua_State* L, FILE* f, const char* name, std::function<void()> func, std::function<void()> errfunc) {
        lua_pushstring(L, name);
        if (lua_rawget(L, -2) != LUA_TTABLE) {
            lua_pop(L, 1);
            printf("restore `%s` failed", name);
            errfunc();
            return false;
        }
        lua_rawgeti(L, -1, 1);
        lua_Integer head = luaL_checkinteger(L, -1); lua_pop(L, 1);
        lua_rawgeti(L, -1, 2);
        lua_Integer tail = luaL_checkinteger(L, -1); lua_pop(L, 1);
        fseek(f, (long)head, SEEK_SET);
        func();
        if (ftell(f) != (long)tail) {
            lua_pop(L, 1);
            printf("restore `%s` failed", name);
            errfunc();
            return false;
        }
        lua_pop(L, 1);
        return true;
    }

    int backup_world(lua_State* L) {
        world& w = *(world*)lua_touserdata(L, 1);
        FILE* f = createfile(L, 2, filemode::write);

        lua_newtable(L);

        backup_scope(L, f, "time", [&](){
            file_write(f, w.time);
        });

        backup_scope(L, f, "stat", [&](){
            write_flatmap(f, w.stat.production);
            write_flatmap(f, w.stat.consumption);
            write_flatmap(f, w.stat.manual_production);
        });

        backup_scope(L, f, "techtree", [&](){
            write_vector(f, w.techtree.queue);
            write_flatmap(f, w.techtree.researched);
            write_flatmap(f, w.techtree.progress);
        });

        backup_scope(L, f, "manual", [&](){
            write_vector(f, w.manual.todos);
            write_flatmap(f, w.manual.container);
        });

        fclose(f);
        return 1;
    }

    int restore_world(lua_State *L) {
        world& w = *(world*)lua_touserdata(L, 1);
        FILE* f = createfile(L, 2, filemode::read);
        luaL_checktype(L, 3, LUA_TTABLE);
        lua_settop(L, 3);

        restore_scope(L, f, "time", [&](){
            file_read(f, w.time);
        }, [&](){
            w.time = 0;
        });

        restore_scope(L, f, "stat", [&](){
            read_flatmap(f, w.stat.production);
            read_flatmap(f, w.stat.consumption);
            read_flatmap(f, w.stat.manual_production);
        }, [&](){
            w.stat.production.clear();
            w.stat.consumption.clear();
            w.stat.manual_production.clear();
        });

        restore_scope(L, f, "techtree", [&](){
            read_vector(f, w.techtree.queue);
            read_flatmap(f, w.techtree.researched);
            read_flatmap(f, w.techtree.progress);
        }, [&](){
            w.techtree.queue.clear();
            w.techtree.researched.clear();
            w.techtree.progress.clear();
        });

        restore_scope(L, f, "manual", [&](){
            read_vector(f, w.manual.todos);
            read_flatmap(f, w.manual.container);
        }, [&](){
            w.manual.todos.clear();
            w.manual.container.clear();
        });

        fclose(f);
        return 0;
    }

    namespace sav_chest {
        struct header {
            uint16_t chest_size;
        };

        static void backup(lua_State* L, world& w) {
            FILE* f = createfile(L, 2, filemode::write);
            header h {
                (uint16_t)w.chests.size(),
            };
            file_write(f, h);
            for (auto const& c : w.chests) {
                file_write(f, c.type_);
                write_vector(f, c.slots);
            }
            fclose(f);
        }

        static void restore(lua_State* L, world& w) {
            FILE* f = createfile(L, 2, filemode::read);
            auto h = file_read<header>(f);
            w.chests.resize(h.chest_size, {0, chest::type::none, nullptr, 0});
            uint16_t id = 0;
            for (auto& c : w.chests) {
                c.id = id++;
                file_read(f, c.type_);
                read_vector(f, c.slots);
            }
            fclose(f);
        }
    }
    int backup_chest(lua_State* L) {
        world& w = *(world*)lua_touserdata(L, 1);
        sav_chest::backup(L, w);
        return 0;
    }
    int restore_chest(lua_State* L) {
        world& w = *(world*)lua_touserdata(L, 1);
        sav_chest::restore(L, w);
        return 0;
    }
}
