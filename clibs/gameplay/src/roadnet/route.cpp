#include "roadnet/route.h"
#include "roadnet/network.h"
#include "flatmap.h"
#include <bee/nonstd/unreachable.h>
#include <optional>
#include <queue>
#include <assert.h>

namespace roadnet {
    constexpr uint16_t kCrossDistance = 4;

    struct dijkstraContext {
        using dijkstraVisit = std::pair<uint16_t, straightid>;
        using dijkstraQueue = std::priority_queue<dijkstraVisit, std::vector<dijkstraVisit>, std::greater<>>;
        struct dijkstraNode {
            uint16_t   distance;
            straightid prev;
            direction  dir;
        };
        using dijkstraResult = flatmap<straightid, dijkstraNode>;
        dijkstraQueue  openlist;
        dijkstraResult results;

        uint16_t get_distance(straightid N) const {
            auto node = results.find(N);
            if (!node) {
                return (uint16_t)-1;
            }
            return node->distance;
        }
        std::optional<dijkstraNode> get(straightid N) const {
            auto node = results.find(N);
            if (!node) {
                return std::nullopt;
            }
            return *node;
        }
        void set(straightid N, straightid prev, direction dir, uint16_t distance) {
            auto [found, node] = results.find_or_insert(N);
            if (!found || node->distance > distance) {
                *node = dijkstraNode { distance, prev, dir };
                openlist.push({distance, N});
            }
        }
    };

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        default: std::unreachable();
        }
    }

    static bool buildResult(network& w, dijkstraContext& ctx, straightid S, straightid E, route_value& val) {
        for (auto C = E;;) {
            if (auto node = ctx.get(C)) {
                C = node->prev;
                w.routeCached.insert_or_assign(route_key { C, E }, route_value {
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

    static bool dijkstra(network& w, straightid S, straightid E, route_value& val) {
        dijkstraContext ctx;
        ctx.openlist.push({0, S});
        while (!ctx.openlist.empty()) {
            auto [distance, G] = ctx.openlist.top();
            ctx.openlist.pop();
            if (distance > ctx.get_distance(G)) {
                continue;
            }
            auto& straight = w.StraightRoad(G);
            crossid Cross = straight.neighbor;
            if (Cross) {
                direction prev = reverse(straight.dir);
                auto& cross = w.CrossRoad(Cross);
                for (uint8_t i = 0; i < 4; ++i) {
                    direction dir = (direction)i;
                    straightid Next = cross.neighbor[i];
                    if (Next && cross.allowed(prev, dir)) {
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

    bool route(network& w, straightid S, straightid E, route_value& val) {
        route_key key { S, E };
        if (auto pval = w.routeCached.find(key)) {
            val = *pval;
            return true;
        }
        return dijkstra(w, S, E, val);
    }
}
