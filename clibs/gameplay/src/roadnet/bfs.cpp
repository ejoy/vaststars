#include "roadnet/bfs.h"
#include "roadnet/network.h"
#include <map>
#include <set>
#include <optional>
#include <assert.h>

namespace roadnet {
    struct bfsRoad {
        roadid    road;
        direction dir;
        bool operator==(const bfsRoad& rhs) const {
            return (road == rhs.road) && (dir == rhs.dir);
        }
        bool operator<(const bfsRoad& rhs) const {
            if (road == rhs.road) {
                return dir < rhs.dir;
            }
            return road < rhs.road;
        }
    };

    struct bfsContext {
        std::set<roadid>           openlist;
        std::map<bfsRoad, bfsRoad> results;
    };

    template <typename T>
    static T pop(std::set<T>& s) {
        T r = *s.begin();
        s.erase(s.begin());
        return r;
    }

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        case direction::n: default: return direction::n;
        }
    }

    static bool buildPath(bfsContext& ctx, bfsRoad S, bfsRoad E, std::vector<direction>& path) {
        std::vector<direction> r;
        bfsRoad C = E;
        do {
            auto iter = ctx.results.find(C);
            if (iter == ctx.results.end()) {
                return false;
            }
            C = iter->second;
            auto& [road, dir] = iter->second;
            if (road.get_type() == roadtype::cross) {
                assert(dir != direction::n);
                r.push_back(dir);
            }
            else {
                C.dir = direction::n;
            }
        } while (C != S);
        for (size_t i = 0; i < r.size(); ++i) {
            path.push_back(r[r.size()-i-1]);
        }
        return true;
    }

    static std::optional<direction> applyStraight(network& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E) {
        assert(N.get_type() == roadtype::straight);
        if (!ctx.results.contains({N, direction::n})) {
            ctx.openlist.insert(N);
            ctx.results.emplace(bfsRoad{N, direction::n}, G);
            if (N == E) {
                return direction::n;
            }
        }
        return std::nullopt;
    }

    static std::optional<direction> applyCross(network& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E) {
        assert(N.get_type() == roadtype::cross);
        auto& cross = w.CrossRoad(N);
        direction prev = reverse(G.dir);
        for (uint8_t i = 0; i < 4; ++i) {
            direction dir = (direction)i;
            roadid Next = cross.neighbor[i];
            if (Next && cross.allowed(prev, dir)) {
                if (!ctx.results.contains({N, dir})) {
                    ctx.results.emplace(bfsRoad{N, dir}, G);
                    if (N == E) {
                        return dir;
                    }
                    if (auto res = applyStraight(w, ctx, {N, dir}, Next, E); res) {
                        return res;
                    }
                }
            }
        }
        return std::nullopt;
    }

    bool bfs(network& w, roadid S, roadid E, std::vector<direction>& path) {
        assert(S.get_type() == roadtype::straight && E.get_type() == roadtype::straight);
        bfsContext ctx;
        ctx.openlist.insert(S);
        while (!ctx.openlist.empty()) {
            roadid G = pop(ctx.openlist);
            assert(G.get_type() == roadtype::straight);
            auto& straight = w.StraightRoad(G);
            roadid Next = straight.neighbor;
            if (Next) {
                if (auto res = applyCross(w, ctx, {G, straight.dir}, Next, E); res) {
                    return buildPath(ctx, {S, direction::n}, {E, *res}, path);
                }
            }
        }
        return false;
    }

    static roadid next_road(network& w, roadid C, direction dir) {
        assert(C.get_type() == roadtype::straight);
        roadid N = w.StraightRoad(C).neighbor;
        roadid Next = w.CrossRoad(N).neighbor[(uint8_t)dir];
        assert(Next.get_type() == roadtype::straight);
        return Next;
    }

    bool route(network& w, roadid S, roadid E, direction& dir) {
        auto key = std::make_pair(S, E);
        auto it = w.routeMap.find(key);
        if (it != w.routeMap.end()) {
            dir = it->second;
            return true;
        }
        std::vector<direction> path;
        if (bfs(w, S, E, path)) {
            assert(!path.empty());
            dir = path[0];
            auto C = S;
            for (auto d : path) {
                w.routeMap.emplace(std::make_pair(C, E), d);
                C = next_road(w, C, d);
            }
            return true;
        }
        return false;
    }
}
