#pragma once
#include <lua.hpp>
#if defined(_MSC_VER)
    #include <windows.h>
#endif
#include <functional>

namespace lua_world {
    template <typename T>
        requires (std::is_trivially_copyable_v<T>)
    void file_write(FILE* f, const T& v) {
        size_t n = fwrite(&v, sizeof(T), 1, f);
        (void)n;
        assert(n == 1);
    }

    template <typename T>
        requires (std::is_trivially_copyable_v<T>)
    void file_write(FILE* f, const T* v, size_t sz) {
        if (sz == 0) {
            return;
        }
        size_t n = fwrite(v, sizeof(T), sz, f);
        (void)n;
        assert(n == sz);
    }

    template <typename T>
        requires (std::is_trivially_copyable_v<T>)
    void file_read(FILE* f, T* v, size_t sz) {
        if (sz == 0) {
            return;
        }
        size_t n = fread(v, sizeof(T), sz, f);
        (void)n;
        assert(n == sz);
    }

    template <typename T>
        requires (std::is_trivially_copyable_v<T>)
    void file_read(FILE* f, T& v) {
        size_t n = fread(reinterpret_cast<void*>(&v), sizeof(T), 1, f);
        (void)n;
        assert(n == 1);
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