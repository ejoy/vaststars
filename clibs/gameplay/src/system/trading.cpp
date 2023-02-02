#include <system/trading.h>
#include <core/world.h>
#include <lua.hpp>
#include "roadnet/world.h"

constexpr uint8_t BLUE_PRIORITY = 0;
constexpr uint8_t RED_PRIORITY = 0;
constexpr uint8_t GREEN_PRIORITY = 1;

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

static void trading_sell(world& w, trading_who who, uint8_t priority, container_slot& s) {
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

static void trading_buy(world& w, trading_who who, uint8_t priority, container_slot& s) {
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

void trading_flush(world& w, trading_who who, container_slot& s) {
    if (s.item == 0) {
        return;
    }
    switch (s.type) {
    case container_slot::slot_type::red:
        trading_sell(w, who, RED_PRIORITY, s);
        break;
    case container_slot::slot_type::blue:
        trading_buy(w, who, BLUE_PRIORITY, s);
        break;
    case container_slot::slot_type::green:
        trading_sell(w, who, GREEN_PRIORITY, s);
        trading_buy(w, who, GREEN_PRIORITY, s);
        break;
    }
}

static size_t queue_remove(queue<trading_who>& queue, trading_who who) {
    size_t n = 0;
    auto removed = std::remove_if(queue.begin(), queue.end(), [&](auto w) {
        if (w.endpoint == who.endpoint) {
            n++;
            return true;
        }
        return false;
    });
    queue.erase_end(removed);
    return n;
}

void trading_rollback(world& w, trading_who who, container_slot& s) {
    if (s.item == 0) {
        return;
    }
    auto& q = w.tradings.queues[s.item];
    if (s.lock_item > 0) {
        size_t n = 0;
        switch (s.type) {
        case container_slot::slot_type::red:
            n = queue_remove(q.sell[RED_PRIORITY], who);
            break;
        case container_slot::slot_type::green:
            n = queue_remove(q.sell[GREEN_PRIORITY], who);
            break;
        default:
            break;
        }
        if (n < s.lock_item) {
            s.lock_item -= (uint16_t)n;
        }
        else {
            s.lock_item = 0;
        }
    }
    if (s.lock_space > 0) {
        size_t n = 0;
        switch (s.type) {
        case container_slot::slot_type::blue:
            n = queue_remove(q.buy[BLUE_PRIORITY], who);
            break;
        case container_slot::slot_type::green:
            n = queue_remove(q.buy[GREEN_PRIORITY], who);
            break;
        default:
            break;
        }
        if (n < s.lock_space) {
            s.lock_space -= (uint16_t)n;
        }
        else {
            s.lock_space = 0;
        }
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
    nearest_result(world& w)
        : w(w)
        , indices()
        , dists((std::numeric_limits<ElementType>::max)())
    {}
    bool hasLorry(const Dataset& dataset, AccessorType index) {
        ecs_api::entity<ecs::station> e {w.ecs};
        if (!e.init(dataset[index].cid)) {
            return false;
        }
        auto& station = e.get<ecs::station>();
        return !!roadnet::lorryid(station.lorry);
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
    world& w;
    AccessorType indices;
    ElementType  dists;
};

static bool GoHome(world& w, roadnet::lorryid lorryId, roadnet::endpointid current) {
    auto& kdtree = w.tradings.station_kdtree;
    nearest_result<false> result(w);
    auto loc = w.rw.Endpoint(current).loc;
    if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
        return false;
    }
    return w.rw.pushLorry(lorryId, current, kdtree.dataset[result.value()].ep);
}

static bool HasTask(world& w) {
    return !w.tradings.orders.empty();
}

static bool DoTask(world& w, roadnet::lorryid lorryId, roadnet::endpointid current) {
    assert(!w.tradings.orders.empty());
    auto& order = w.tradings.orders.front();
    roadnet::endpointid s{current};
    roadnet::endpointid e{order.sell.endpoint};
    if (!w.rw.pushLorry(lorryId, s, e)) {
        return false;
    }
    auto& l = w.rw.Lorry(lorryId);
    l.gameplay = {
        order.item,
        {order.sell.endpoint},
        {order.buy.endpoint},
        roadnet::lorry_status::go_sell,
    };
    w.tradings.orders.pop();
    return true;
}

static bool UpdateChest(world& w, ecs::chest& c) {
    if (!roadnet::lorryid{ c.lorry }) {
        return false;
    }
    auto& l = w.rw.Lorry(c.lorry);
    for (;;) {
        switch (l.gameplay.status) {
        case roadnet::lorry_status::go_buy: {
            assert(c.endpoint == l.gameplay.buy.endpoint);
            auto& chest = chest::query(c);
            chest::place_force(w, chest.index, c.endpoint, l.gameplay.item, 1, true);
            l.gameplay.status = roadnet::lorry_status::want_home;
            break;
        }
        case roadnet::lorry_status::go_sell: {
            assert(c.endpoint == l.gameplay.sell.endpoint);
            auto& chest = chest::query(c);
            if (chest::pickup_force(w, chest.index, c.endpoint, l.gameplay.item, 1, true)) {
                l.gameplay.status = roadnet::lorry_status::want_buy;
            }
            else {
                //TODO unlock chest slot
                l.gameplay.status = roadnet::lorry_status::want_home;
            }
            break;
        }
        case roadnet::lorry_status::want_home: {
            if (HasTask(w)) {
                if (DoTask(w, c.lorry, c.endpoint)) {
                    l.gameplay.status = roadnet::lorry_status::go_sell;
                    return true;
                }
            }
            else {
                if (GoHome(w, c.lorry, c.endpoint)) {
                    l.gameplay.status = roadnet::lorry_status::go_home;
                    return true;
                }
            }
            return false;
        }
        case roadnet::lorry_status::want_buy: {
            if (w.rw.pushLorry(c.lorry, c.endpoint, l.gameplay.buy.endpoint)) {
                l.gameplay.status = roadnet::lorry_status::go_buy;
                return true;
            }
            return false;
        }
        default:
            return false;
        }
    }
}

static int
lbuild(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& rw = w.rw;
    auto& kdtree = w.tradings.station_kdtree;
    kdtree.dataset.clear();
    for (auto& v : ecs_api::select<ecs::station>(w.ecs)) {
        auto& s = v.get<ecs::station>();
        if (s.endpoint != 0xffff) {
            assert(s.endpoint >= 0);
            auto loc = rw.Endpoint(s.endpoint).loc;
            kdtree.dataset.emplace_back(loc.x, loc.y, s.endpoint, v.getid());
        }
    }
    kdtree.tree.build();
    return 0;
}

static int
lupdate(lua_State *L) {
    auto& w = *(world*)lua_touserdata(L, 1);
    auto& kdtree = w.tradings.station_kdtree;
    for (auto& [item, q] : w.tradings.queues) {
        trading_match(w, item, q);
    }
    while (!w.tradings.orders.empty()) {
        auto& order = w.tradings.orders.front();
        nearest_result<true> result(w);
        auto loc = w.rw.Endpoint(order.sell.endpoint).loc;
        if (!kdtree.tree.nearest(result, {loc.x, loc.y})) {
            break;
        }
        
        ecs_api::entity<ecs::station> e {w.ecs};
        if (!e.init(kdtree.dataset[result.value()].cid)) {
            break;
        }
        roadnet::endpointid s{kdtree.dataset[result.value()].ep};
        auto& station = e.get<ecs::station>();
        DoTask(w, station.lorry, s);
    }
    for (auto& v : ecs_api::select<ecs::chest>(w.ecs)) {
        auto& c = v.get<ecs::chest>();
        if (UpdateChest(w, c)) {
            c.lorry = roadnet::lorryid::invalid().id;
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
