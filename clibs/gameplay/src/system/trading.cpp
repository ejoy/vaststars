#include <system/trading.h>
#include <core/world.h>
#include <util/kdtree.h>
#include <lua.hpp>

static void trading_match(world& w, uint16_t item, trading_queue& q) {
    while (!q.sell.empty() && !q.buy.empty()) {
        w.tradings.orders.push({
            item,
            q.sell.front(),
            q.buy.front()
        });
        q.buy.pop();
        q.sell.pop();
    }
}

void trading_sell(world& w, uint16_t who, chest::slot& s) {
    if (s.amount <= s.lock) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.amount - s.lock;
    s.lock = s.amount;
    auto& n = w.tradings.queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.sell.push(who);
    }
}

void trading_buy(world& w, uint16_t who, chest::slot& s) {
    if (s.amount + s.lock <= s.limit) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.limit - s.amount - s.lock;
    s.lock = s.limit - s.amount;
    auto& n = w.tradings.queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.buy.push(who);
    }
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& [item, q] : w.tradings.queues) {
        trading_match(w, item, q);
    }
    if (!w.tradings.orders.empty()) {
        for (auto& v : w.select<ecs::station>(L)) {
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_trading_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
