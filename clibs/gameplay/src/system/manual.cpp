#include <lua.hpp>
#include <optional>
#include <algorithm>
#include <memory>

#include "luaecs.h"
#include "core/world.h"
#include "core/entity.h"
#include "core/select.h"
#include "system/manual.h"
extern "C" {
#include "util/prototype.h"
}

#define STATUS_IDLE 0
#define STATUS_DONE 1
#define STATUS_FINISH 2
#define STATUS_REBUILD 3

bool manual_container::pickup(recipe_items& r) {
    for (size_t i = 0; i < r.n; ++i) {
        uint16_t item = r.items[i].item;
        uint16_t amount = r.items[i].amount;
        auto iter = mybase::find(item);
        if (!iter || *iter < amount) {
            return false;
        }
    }
    for (size_t i = 0; i < r.n; ++i) {
        pickup(r.items[i].item, r.items[i].amount);
    }
    return true;
}

void manual_container::place(recipe_items& r) {
    for (size_t i = 0; i < r.n; ++i) {
        place(r.items[i].item, r.items[i].amount);
    }
}

uint16_t manual_container::pickup(uint16_t item, uint16_t amount) {
    auto iter = mybase::find(item);
    if (!iter) {
        return amount;
    }
    if (*iter <= amount) {
        uint16_t r = amount - *iter;
        mybase::erase(item);
        return r;
    }
    *iter -= amount;
    return 0;
}

void manual_container::place(uint16_t item, uint16_t amount) {
    auto iter = mybase::find(item);
    if (iter) {
        *iter += amount;
    }
    else {
        mybase::insert_or_assign(item, std::move(amount));
    }
}

void manual_crafting::next() {
    if (todos.empty()) {
        return;
    }
    todos.pop_back();
}

void manual_crafting::sync(ecs::manual& m) {
    m.progress = 0;
    if (todos.empty()) {
        m.recipe = 0;
        m.status = (container.size() == 0)
            ? STATUS_IDLE
            : STATUS_REBUILD
            ;
        return;
    }
    todo& td = todos.back();
    m.recipe = td.id;
    m.status = (td.type == type::craft)
        ? STATUS_IDLE
        : STATUS_FINISH
        ;
}

static manual_container sub(manual_container const& a, manual_container const& b) {
    manual_container ab;
    for (auto [item, amount] : a) {
        auto iter = b.find(item);
        if (iter) {
            if (amount > *iter) {
                ab.insert_or_assign(item, amount - *iter);
            }
        }
        else {
            ab.insert_or_assign(item, std::move(amount));
        }
    }
    return ab;
}

bool manual_crafting::rebuild(lua_State* L, world& w, int id) {
    chest_container& chest = w.query_container<chest_container>(id);

    manual_container expected;
    manual_container current;
    for (auto& todo: todos) {
        if (todo.type == type::craft) {
            prototype_context recipe = w.prototype(L, todo.id);
            recipe_items& in  = *(recipe_items*)pt_ingredients(&recipe);
            recipe_items& out = *(recipe_items*)pt_results(&recipe);
            for (uint8_t j = 0; j < in.n; ++j) {
                auto& s = in.items[j];
                uint16_t r = current.pickup(s.item, s.amount);
                if (r > 0) {
                    expected.place(s.item, r);
                }
            }
            for (uint8_t j = 0; j < out.n; ++j) {
                auto& s = out.items[j];
                current.place(s.item, s.amount);
            }
        }
        else {
            if (0 != current.pickup(todo.id, 1)) {
                return false;
            }
        }
    }

    manual_container abound = sub(container, expected);
    for (auto [item, amount] : abound) {
        uint16_t r = container.pickup(item, amount);
        if (!chest.place(L, w, item, amount - r)) {
            container.place(item, amount - r);
            return false;
        }
    }

    manual_container lack = sub(expected, container);
    for (auto [item, amount] : lack) {
        auto idx = chest.find(item);
        if (idx == -1 || chest.slots[idx].amount < amount) {
            return false;
        }
    }
    for (auto [item, amount] : lack) {
        auto idx = chest.find(item);
        chest.slots[idx].amount -= amount;
        container.place(item, amount);
    }
    chest.resize(L, w);
    return true;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& v : w.select<ecs::manual, ecs::chest>(L)) {
        ecs::manual& m = v.get<ecs::manual>();
        ecs::chest& c = v.get<ecs::chest>();

        if (m.status == STATUS_REBUILD) {
            if (!w.manual.rebuild(L, w, c.container)) {
                continue;
            }
            w.manual.sync(m);
        }
        if (m.status == STATUS_FINISH) {
            if (!w.manual.container.pickup(m.recipe, 1)) {
                continue;
            }
            chest_container& container = w.query_container<chest_container>(c.container);
            if (!container.place(L, w, m.recipe, 1)) {
                w.manual.container.place(m.recipe, 1);
                continue;
            }
            w.manual.next();
            w.manual.sync(m);
        }
        if (m.recipe != 0 && m.progress <= 0 && m.status == STATUS_DONE) {
            prototype_context recipe = w.prototype(L, m.recipe);
            recipe_items& in = *(recipe_items*)pt_ingredients(&recipe);
            recipe_items& out = *(recipe_items*)pt_results(&recipe);
            if (!w.manual.container.pickup(in)) {
                continue;
            }
            w.manual.container.place(out);
            w.stat.finish_recipe(L, w, m.recipe);
            w.manual.next();
            w.manual.sync(m);
        }
        if (m.recipe != 0 && m.progress <= 0 && m.status == STATUS_IDLE) {
            prototype_context recipe = w.prototype(L, m.recipe);
            int time = pt_time(&recipe);
            m.progress += time * 100;
            m.status = STATUS_DONE;
        }
        if (m.recipe != 0 && m.progress > 0) {
            m.progress -= m.speed;
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_manual_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
