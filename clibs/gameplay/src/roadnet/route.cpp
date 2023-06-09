#include "roadnet/route.h"
#include "roadnet/network.h"
#include "flatmap.h"
#include <set>
#include <optional>
#include <queue>
#include <assert.h>

namespace roadnet {
    constexpr uint16_t kCrossDistance = 4;

    struct dijkstraContext {
        using dijkstraVisit = std::pair<uint16_t, roadid>;
        using dijkstraQueue = std::priority_queue<dijkstraVisit, std::vector<dijkstraVisit>, std::greater<>>;
        struct dijkstraNode {
            uint16_t  distance;
            roadid    prev;
            direction dir;
        };
        using dijkstraResult = flatmap<roadid, dijkstraNode>;
        dijkstraQueue  openlist;
        dijkstraResult results;

        uint16_t get_distance(roadid N) const {
            auto node = results.find(N);
            if (!node) {
                return (uint16_t)-1;
            }
            return node->distance;
        }
        std::optional<dijkstraNode> get(roadid N) const {
            auto node = results.find(N);
            if (!node) {
                return std::nullopt;
            }
            return *node;
        }
        void set(roadid N, roadid prev, direction dir, uint16_t distance) {
            auto node = results.find(N);
            if (!node) {
                results.insert_or_assign(N, dijkstraNode {
                    distance,
                    prev,
                    dir,
                });
                openlist.push({distance, N});
                return;
            }
            if (node->distance > distance) {
                node->distance = distance;
                node->dir = dir;
                node->prev = prev;
                openlist.push({distance, N});
                return;
            }
        }
    };

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        case direction::n: default: return direction::n;
        }
    }

    static roadid next_road(network& w, roadid C, direction dir) {
        assert(C.get_type() == roadtype::straight);
        roadid N = w.StraightRoad(C).neighbor;
        roadid Next = w.CrossRoad(N).neighbor[(uint8_t)dir];
        assert(Next.get_type() == roadtype::straight);
        return Next;
    }

    static bool buildResult(network& w, dijkstraContext& ctx, roadid S, roadid E, route_value& val) {
        for (auto C = E;;) {
            if (auto node = ctx.get(C)) {
                C = node->prev;
                w.routeMap.insert_or_assign(route_key { C, E }, route_value {
                    (uint16_t)node->dir,
                    (uint16_t)node->distance,
                });
                if (C == S) {
                    val = route_value {
                        (uint16_t)node->dir,
                        (uint16_t)node->distance,
                    };
                    return true;
                }
            }
            else {
                return false;
            }
        }
    }

    static bool dijkstra(network& w, roadid S, roadid E, route_value& val) {
        assert(S.get_type() == roadtype::straight && E.get_type() == roadtype::straight);
        dijkstraContext ctx;
        ctx.openlist.push({0, S});
        while (!ctx.openlist.empty()) {
            auto [distance, G] = ctx.openlist.top();
            ctx.openlist.pop();
            assert(G.get_type() == roadtype::straight);
            if (distance > ctx.get_distance(G)) {
                continue;
            }
            auto& straight = w.StraightRoad(G);
            roadid Cross = straight.neighbor;
            if (Cross) {
                assert(Cross.get_type() == roadtype::cross);
                direction prev = reverse(straight.dir);
                auto& cross = w.CrossRoad(Cross);
                for (uint8_t i = 0; i < 4; ++i) {
                    direction dir = (direction)i;
                    roadid Next = cross.neighbor[i];
                    if (Next && cross.allowed(prev, dir)) {
                        assert(Next.get_type() == roadtype::straight);
                        auto& straight = w.StraightRoad(Next);
                        ctx.set(Next, G, dir, distance + straight.len + kCrossDistance);
                    }
                }
            }
            if (G == E) {
                return buildResult(w, ctx, S, E, val);
            }
        }
        return false;
    }

    bool route(network& w, roadid S, roadid E, route_value& val) {
        route_key key { S, E };
        if (auto pval = w.routeMap.find(key)) {
            val = *pval;
            return true;
        }
        return dijkstra(w, S, E, val);
    }
}
