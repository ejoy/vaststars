#include <system/trading.h>
#include <core/world.h>
#include <lua.hpp>
#include "roadnet_world.h"

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

void trading_sell(world& w, trading_who who, chest::slot& s) {
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

void trading_buy(world& w, trading_who who, chest::slot& s) {
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

template <>
uint8_t kdtree_getdata<uint8_t, trading_kdtree::pointcolud>(trading_kdtree::pointcolud const& dataset, uint16_t i, uint8_t dim) {
    if (dim == 0) {
        return dataset[i].x;
    }
    return dataset[i].y;
}

template <typename ElementType, typename Dataset, typename AccessorType = uint16_t>
class nearest_result {
public:
    nearest_result(roadnet::world& w)
        : w(w)
        , indices()
        , dists((std::numeric_limits<ElementType>::max)())
    {}
    bool addPoint(const Dataset& dataset, ElementType dist, AccessorType index) {
        if ((dists > dist) || ((dist == dists) && (indices > index))) {
            auto& ep = w.Endpoint(roadnet::endpointid{dataset[index].id});
            if (ep.popMap.size() > 0) {
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

static roadnet::loction getxy(roadnet::world& w, uint16_t id) {
    auto& ep = w.Endpoint(roadnet::endpointid{id});
    return ep.loc;
}

static int
lbuild(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    auto& rw = getroadnetworld(L);
    auto& kdtree = w.tradings.station_kdtree;
    for (auto& v : w.select<ecs::station>(L)) {
        auto& s = v.get<ecs::station>();
        auto loc = getxy(rw, s.endpoint);
        kdtree.dataset.emplace_back(loc.x, loc.y, s.endpoint);
    }
    kdtree.tree.build();
    return 0;
}

static int
lupdate(lua_State *L) {
    world& w = *(world*)lua_touserdata(L, 1);
    for (auto& [item, q] : w.tradings.queues) {
        trading_match(w, item, q);
    }
    if (w.tradings.orders.empty()) {
        return 0;
    }
    while (!w.tradings.orders.empty()) {
        auto& rw = getroadnetworld(L);
        auto& order = w.tradings.orders.front();
        auto& kdtree = w.tradings.station_kdtree;
        nearest_result<uint8_t, trading_kdtree::pointcolud> result(rw);
        auto loc = getxy(rw, order.sell.id);
        if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
            break;
        }
        roadnet::endpointid s{kdtree.dataset[result.value()].id};
        roadnet::endpointid e{order.sell.id};
        w.tradings.orders.pop();
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
