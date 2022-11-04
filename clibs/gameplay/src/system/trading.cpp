#include <system/trading.h>
#include <core/world.h>
#include <lua.hpp>
#include "roadnet_world.h"

static void trading_match(world& w, uint16_t item, trading_queue& q, uint8_t sell_priority, uint8_t buy_priority) {
    auto& s = q.sell[sell_priority];
    auto& b = q.buy[buy_priority];
    while (!s.empty() && !b.empty()) {
        w.tradings.orders.push({
            item,
            s.front(),
            b.front()
        });
        b.pop();
        s.pop();
    }
}

static void trading_match(world& w, uint16_t item, trading_queue& q) {
    trading_match(w, item, q, 0, 0);
    trading_match(w, item, q, 0, 1);
    trading_match(w, item, q, 1, 0);
}

void trading_sell(world& w, trading_who who, uint8_t priority, container_slot& s) {
    if (s.amount <= s.lock_item) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.amount - s.lock_item;
    s.lock_item = s.amount;
    auto& n = w.tradings.queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.sell[priority].push(who);
    }
}

void trading_buy(world& w, trading_who who, uint8_t priority, container_slot& s) {
    if (s.amount + s.lock_space >= s.limit) {
        return;
    }
    uint16_t item = s.item;
    uint16_t amount = s.limit - s.amount - s.lock_space;
    s.lock_space = s.limit - s.amount;
    auto& n = w.tradings.queues[item];
    for (uint16_t i = 0; i < amount; ++i) {
        n.buy[priority].push(who);
    }
}

template <>
uint8_t kdtree_getdata<uint8_t, trading_kdtree::pointcolud>(trading_kdtree::pointcolud const& dataset, uint16_t i, uint8_t dim) {
    if (dim == 0) {
        return dataset[i].x;
    }
    return dataset[i].y;
}

template <bool Check, typename ElementType = uint8_t, typename Dataset = trading_kdtree::pointcolud, typename AccessorType = uint16_t>
class nearest_result {
public:
    nearest_result(roadnet::world& w)
        : w(w)
        , indices()
        , dists((std::numeric_limits<ElementType>::max)())
    {}
    bool hasLorry(const Dataset& dataset, AccessorType index) {
        return w.Endpoint(dataset[index].id).popMap.size() > 0;
    }
    bool addPoint(const Dataset& dataset, ElementType dist, AccessorType index) {
        if ((dists > dist) || ((dist == dists) && (indices > index))) {
            if (!Check || hasLorry(dataset, index)) {
                dists   = dist;
                indices = index;
            }
        }
        return true;
    }
    ElementType accumDist(ElementType a, ElementType b) const {
        return abs(a - b);
    }
    ElementType worstDist() const { return dists; }
    explicit operator bool() const {
        return dists != (std::numeric_limits<ElementType>::max)();
    }
    AccessorType value() const {
        return indices;
    }
private:
    roadnet::world& w;
    AccessorType indices;
    ElementType  dists;
};

static roadnet::world&
getroadnetworld(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "ROADNET_WORLD");
    auto& rw = *(roadnet::world*)lua_touserdata(L, -1);
    lua_pop(L, 1);
    return rw;
}

static roadnet::loction getxy(roadnet::world& w, roadnet::endpointid id) {
    auto& ep = w.Endpoint(id);
    return ep.loc;
}

static void GoHome(world& w, roadnet::world& rw, roadnet::lorryid lorryId, roadnet::endpointid current) {
    auto& kdtree = w.tradings.station_kdtree;
    nearest_result<false> result(rw);
    auto loc = getxy(rw, current);
    if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
        assert(false);
    }
    if (!rw.pushLorry(lorryId, current, kdtree.dataset[result.value()].id)) {
        assert(false);
    }
}

static bool DoTask(world& w, roadnet::world& rw, roadnet::lorryid lorryId, roadnet::endpointid current) {
    if (w.tradings.orders.empty()) {
        return false;
    }
    auto& order = w.tradings.orders.front();
    roadnet::endpointid s{current};
    roadnet::endpointid e{order.sell.endpoint};
    if (!rw.pushLorry(lorryId, s, e)) {
        assert(false);
        return false;
    }
    auto& l = rw.Lorry(lorryId);
    l.gameplay = {
        order.item,
        {order.sell.endpoint, order.sell.index},
        {order.buy.endpoint, order.buy.index},
    };
    w.tradings.orders.pop();
    return true;
}

static int
lbuild(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& rw = getroadnetworld(L);
    auto& kdtree = w.tradings.station_kdtree;
    kdtree.dataset.clear();
    for (auto& v : w.select<ecs::station>(L)) {
        auto& s = v.get<ecs::station>();
        if (s.endpoint != 0xffff) {
            assert(s.endpoint >= 0);
            auto loc = getxy(rw, s.endpoint);
            kdtree.dataset.emplace_back(loc.x, loc.y, s.endpoint);
        }
    }
    kdtree.tree.build();
    return 0;
}

static int
lupdate(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& rw = getroadnetworld(L);
    auto& kdtree = w.tradings.station_kdtree;
    for (auto& [item, q] : w.tradings.queues) {
        trading_match(w, item, q);
    }
    while (!w.tradings.orders.empty()) {
        auto& order = w.tradings.orders.front();
        nearest_result<true> result(rw);
        auto loc = getxy(rw, order.sell.endpoint);
        if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
            break;
        }
        roadnet::endpointid s{kdtree.dataset[result.value()].id};
        auto lorryId = rw.popLorry(s);
        if (!DoTask(w, rw, lorryId, s)) {
            assert(false);
            break;
        }
    }
    for (auto& v : w.select<ecs::chest>(L)) {
        auto& c = v.get<ecs::chest>();
        for (auto lorryId = rw.popLorry(c.endpoint); !!lorryId; lorryId = rw.popLorry(c.endpoint)) {
            auto& l = rw.Lorry(lorryId);
            if (l.gameplay.sell.endpoint == 0xffff) {
                assert(c.endpoint == l.gameplay.buy.endpoint);
                auto& chest = chest::query(c);
                chest::place_force(w, chest, l.gameplay.buy.index, l.gameplay.item, 1);
                if (!DoTask(w, rw, lorryId, c.endpoint)) {
                    GoHome(w, rw, lorryId, c.endpoint);
                }
            }
            else {
                assert(c.endpoint == l.gameplay.sell.endpoint);
                auto& chest = chest::query(c);
                chest::pickup_force(w, chest, l.gameplay.sell.index, l.gameplay.item, 1);
                if (!rw.pushLorry(lorryId, c.endpoint, l.gameplay.buy.endpoint)) {
                    assert(false);
                }
                l.gameplay.sell.endpoint = 0xffff;
            }
        }
    }
    return 0;
}

extern "C" int
luaopen_vaststars_trading_system(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "build", lbuild },
		{ "update", lupdate },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);
	return 1;
}
