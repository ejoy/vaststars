#include <system/trading.h>
#include <core/world.h>
#include <lua.hpp>

static void trading_match(world& w, trading_network& network, uint16_t item, trading_queue& q) {
    while (!q.sell.empty() && !q.buy.empty()) {
        network.orders.push({
            item,
            q.sell.front(),
            q.buy.front()
        });
        q.buy.pop();
        q.sell.pop();
    }
}

void trading_sell(world& w, uint16_t who, uint8_t network, chest::slot& s) {
    if (s.amount <= s.lock) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.amount - s.lock;
    s.lock = s.amount;
    auto& n = w.tradings[network].queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.sell.push(who);
    }
}

void trading_buy(world& w, uint16_t who, uint8_t network, chest::slot& s) {
    if (s.amount + s.lock <= s.limit) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.limit - s.amount - s.lock;
    s.lock = s.limit - s.amount;
    auto& n = w.tradings[network].queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.buy.push(who);
    }
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (size_t i = 0; i <= 255; ++i) {
        auto& network = w.tradings[i];
        for (auto& [item, q] : network.queues) {
            trading_match(w, network, item, q);
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
