#pragma once
#include <lua.hpp>
#if defined(_MSC_VER)
    #include <windows.h>
#endif
#include <functional>

namespace lua_world {
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

    template <typename K, typename V>
    void file_write(FILE* f, const std::map<K, V>& map) {
        file_write<size_t>(f, map.size());
        for (auto& kv : map) {
            file_write(f, kv.first);
            file_write(f, kv.second);
        }
    }

    template <typename K, typename V>
    void file_read(FILE* f, std::map<std::remove_cv_t<K>, std::remove_cv_t<V>>& map) {
        map.clear();
        size_t n = 0;
        file_read(f, n);
        for (size_t i = 1; i <= n; ++i) {
            std::pair<K, V> pair;
            file_read(f, pair.first);
            file_read(f, pair.second);
            map.emplace(std::move(pair));
        }
    }

    template <typename Vec>
    static void write_vector(FILE* f, const Vec& vec) {
        file_write(f, vec.size());
        file_write(f, vec.data(), vec.size());
    }

    template <typename Vec, typename fn>
    static void write_vector(FILE* f, const Vec& vec, fn func) {
        file_write(f, vec.size());
        for (auto& v : vec) {
            func(v);
        }
    }

    template <typename Vec>
    static void read_vector(FILE* f, Vec& vec) {
        size_t n = 0;
        file_read(f, n);
        vec.resize(n);
        file_read(f, vec.data(), vec.size());
    }

    template <typename Vec, typename fn>
    static void read_vector(FILE* f, Vec& vec, fn func) {
        size_t n = 0;
        file_read(f, n);
        vec.resize(n);
        for (auto& v : vec) {
            func(v);
        }
    }

    template <typename List>
    static void write_list(FILE* f, const List& list) {
        file_write(f, list.size());
        for (auto& v : list) {
            file_write(f, v);
        }
    }

    template <typename List>
    static void read_list(FILE* f, List& list) {
        size_t n = 0;
        file_read(f, n);
        list.resize(n);
        for (auto& v : list) {
            file_read(f, v);
        }
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
    static void write_dynarray(FILE* f, const Vec& vec) {
        file_write(f, vec.size());
        file_write(f, vec.begin(), vec.size());
    }

    template <typename Vec>
    static void read_dynarray(FILE* f, Vec& vec) {
        size_t n = 0;
        file_read(f, n);
        vec.reset(n);
        file_read(f, vec.begin(), vec.size());
    }

    enum class filemode {
        read,
        write,
    };

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
}