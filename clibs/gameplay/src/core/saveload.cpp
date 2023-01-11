#include <string>
#include "core/world.h"
#include "core/saveload.h"

namespace lua_world {
    template <typename T, size_t N>
    void file_write(FILE* f, const queue<T, N>& q) {
        file_write(f, q.size());
        for (auto const& e : q) {
            file_write(f, e);
        }
    }

    void file_write(FILE* f, const trading_queue& tq) {
        for (size_t i = 0; i < SELL_PRIORITY; ++i) {
            file_write(f, tq.sell[i]);
        }
        for (size_t i = 0; i < BUY_PRIORITY; ++i) {
            file_write(f, tq.buy[i]);
        }
    }

    template <typename T, size_t N>
    void file_read(FILE* f, queue<T, N>& q) {
        //TODO: performance optimization
        q.clear();
        size_t n = 0;
        file_read(f, n);
        for (size_t i = 0; i < n; ++i) {
            T v;
            file_read(f, v);
            q.push(v);
        }
    }

    void file_read(FILE* f, trading_queue& tq) {
        for (size_t i = 0; i < SELL_PRIORITY; ++i) {
            file_read(f, tq.sell[i]);
        }
        for (size_t i = 0; i < BUY_PRIORITY; ++i) {
            file_read(f, tq.buy[i]);
        }
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

        backup_scope(L, f, "container", [&](){
            file_write(f, w.container.pages.size());
            for (auto const& page : w.container.pages) {
                file_write(f, page->slots);
            }
            file_write(f, w.container.freelist.size());
            for (auto const& lst : w.container.freelist) {
                file_write(f, lst.size());
                for (auto const& node : lst) {
                    file_write(f, node);
                }
            }
            file_write(f, w.container.top);
        });

        backup_scope(L, f, "tradings", [&](){
            file_write(f, w.tradings.queues);
            file_write(f, w.tradings.orders);
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

        restore_scope(L, f, "container", [&](){
            w.container.clear();
            auto page_n = file_read<size_t>(f);
            w.container.pages.reserve(page_n);
            for (size_t i = 0; i < page_n; ++i) {
                auto page = std::make_unique<container::page>();
                file_read(f, page->slots);
                w.container.pages.emplace_back(std::move(page));
            }
            auto freelist_n = file_read<size_t>(f);
            w.container.freelist.reserve(freelist_n);
            for (size_t i = 0; i < freelist_n; ++i) {
                std::list<container::chunk> lst;
                auto lst_n = file_read<size_t>(f);
                for (size_t j = 0; j < lst_n; ++j) {
                    lst.push_back(file_read<container::chunk>(f));
                }
                w.container.freelist.emplace_back(std::move(lst));
            }
            file_read(f, w.container.top);
        }, [&](){
            w.container.clear();
            w.container.init();
        });

        restore_scope(L, f, "tradings", [&](){
            file_read(f, w.tradings.queues);
            file_read(f, w.tradings.orders);
        }, [&](){
            w.tradings.queues.clear();
            w.tradings.orders.clear();
        });
        fclose(f);
        return 0;
    }

    int backup_chest(lua_State* L) {
        return 0;
    }
    int restore_chest(lua_State* L) {
        return 0;
    }
}
