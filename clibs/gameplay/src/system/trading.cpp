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

template <bool Check, typename ElementType = uint8_t, typename Dataset = trading_kdtree::pointcolud, typename AccessorType = uint16_t>
class nearest_result {
public:
    nearest_result(roadnet::world& w)
        : w(w)
        , indices()
        , dists((std::numeric_limits<ElementType>::max)())
    {}
    bool hasLorry(const Dataset& dataset, AccessorType index) {
        return w.Endpoint(roadnet::endpointid{dataset[index].id}).popMap.size() > 0;
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

static roadnet::loction getxy(roadnet::world& w, uint16_t id) {
    auto& ep = w.Endpoint(roadnet::endpointid{id});
    return ep.loc;
}

static int
lbuild(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& rw = getroadnetworld(L);
    auto& kdtree = w.tradings.station_kdtree;
    for (auto& v : w.select<ecs::station>(L)) {
        auto& s = v.get<ecs::station>();
        assert(s.endpoint > 0);
        auto loc = getxy(rw, s.endpoint);
        kdtree.dataset.emplace_back(loc.x, loc.y, s.endpoint);
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
        roadnet::endpointid e{order.sell.endpoint};
        auto lorryId = rw.popLorry(s);
        if (!rw.pushLorry(lorryId, s, e)) {
            assert(false);
            break;
        }
        auto& l = rw.Lorry(lorryId);
        l.gameplay = {
            order.item,
            order.sell.endpoint,
            order.buy.endpoint,
        };
        w.tradings.orders.pop();
    }
    for (auto& v : w.select<ecs::chest_2>(L)) {
        auto& c = v.get<ecs::chest_2>();
        for (auto lorryId = rw.popLorry(roadnet::endpointid{c.endpoint}); !!lorryId; lorryId = rw.popLorry(roadnet::endpointid{c.endpoint})) {
            auto& l = rw.Lorry(lorryId);
            if (l.gameplay.sell == 0xffff) {
                auto& chest = w.query_chest(c.chest_in);
                chest.place_force(w, l.gameplay.item, 1);
                nearest_result<false> result(rw);
                auto loc = getxy(rw, c.endpoint);
                if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
                    assert(false);
                }
                bool ok = rw.pushLorry(lorryId, roadnet::endpointid{c.endpoint}, roadnet::endpointid{kdtree.dataset[result.value()].id});
                (void)ok;assert(ok);
            }
            else {
                auto& chest = w.query_chest(c.chest_out);
                chest.pickup_force(w, l.gameplay.item, 1);
                bool ok = rw.pushLorry(lorryId, roadnet::endpointid{c.endpoint}, roadnet::endpointid{l.gameplay.buy});
                (void)ok;assert(ok);
                l.gameplay.sell = 0xffff;
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
