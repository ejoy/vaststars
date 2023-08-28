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

    static route_value buildResult(network& w, dijkstraContext& ctx, straightid S, straightid E) {
        for (auto C = E;;) {
            auto node = ctx.get(C);
            assert(node);
            C = node->prev;
            w.routeCached.insert_or_assign(route_key { C, E }, route_value {
                true,
                node->dir,
                node->distance,
            });
            if (C == S) {
                return route_value {
                    true,
                    node->dir,
                    node->distance,
                };
            }
        }
    }

    static route_value dijkstra(network& w, straightid S, straightid E) {
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
                return buildResult(w, ctx, S, E);
            }
        }
        for (auto const& [id, node] : ctx.results) {
            w.routeCached.insert_or_assign(route_key { id, E }, route_value { false });
        }
        return { false };
    }

    std::optional<direction> route_direction(network& w, straightid S, straightid E) {
        route_key key { S, E };
        if (auto pval = w.routeCached.find(key)) {
            if (!pval->vaild) {
                return std::nullopt;
            }
            return pval->direction;
        }
        route_value val = dijkstra(w, S, E);
        if (!val.vaild) {
            return std::nullopt;
        }
        return val.direction;
    }
    std::optional<uint16_t> route_distance(network& w, straightid S, straightid E) {
        route_key key { S, E };
        if (auto pval = w.routeCached.find(key)) {
            if (!pval->vaild) {
                return std::nullopt;
            }
            return pval->distance;
        }
        route_value val = dijkstra(w, S, E);
        if (!val.vaild) {
            return std::nullopt;
        }
        return val.distance;
    }
}
