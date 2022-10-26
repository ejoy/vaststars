#include "roadnet_bfs.h"
#include "roadnet_world.h"
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

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        case direction::n: default: return direction::n;
        }
    }

    static constexpr loction move(loction loc, direction dir) {
        switch (dir) {
        case direction::l: loc.x -= 1; break;
        case direction::t: loc.y -= 1; break;
        case direction::r: loc.x += 1; break;
        case direction::b: loc.y += 1; break;
        case direction::n: default: break;
        }
        return loc;
    }

    static constexpr char directionName(direction dir) {
        switch (dir) {
        case direction::l: return 'L';
        case direction::t: return 'T';
        case direction::r: return 'R';
        case direction::b: return 'B';
        default:
        case direction::n: return 'N';
        }
    }

    template <typename T>
    static T pop(std::set<T>& s) {
        T r = *s.begin();
        s.erase(s.begin());
        return r;
    }

    static bool buildPath(bfsContext& ctx, bfsRoad S, bfsRoad E, std::vector<direction>& path) {
        std::vector<direction> r;
        bfsRoad C = E;
        while (C != S) {
            auto iter = ctx.results.find(C);
            if (iter == ctx.results.end()) {
                return false;
            }
            C = iter->second;
            auto& [road, dir] = iter->second;
            if (road.cross) {
                assert(dir != direction::n);
                r.push_back(dir);
            }
            else {
                C.dir = direction::n;
            }
        }
        for (size_t i = 0; i < r.size(); ++i) {
            path.push_back(r[r.size()-i-1]);
        }
        return true;
    }

    static std::optional<direction> applyResult(world& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E);

    static std::optional<direction> applyStraight(world& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E) {
        if (!ctx.results.contains({N, direction::n})) {
            ctx.openlist.insert(N);
            ctx.results.emplace(bfsRoad{N, direction::n}, G);
            if (N == E) {
                return direction::n;
            }
        }
        return std::nullopt;
    }

    static std::optional<direction> applyCross(world& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E) {
        direction prev = G.dir;
        direction dirAry[] = { direction::l, direction::t, direction::r, direction::b };
        if (prev != direction::n && prev != direction::b) {
            dirAry[(uint8_t)prev] = direction::b;
            dirAry[(uint8_t)direction::b] = prev;
        }
        for (uint8_t i = 0; i < 4; ++i) {
            direction dir = dirAry[i];
            roadid Next = w.crossAry[N.id].neighbor[i];
            if (Next) {
                if (!ctx.results.contains({N, dir})) {
                    ctx.results.emplace(bfsRoad{N, dir}, G);
                    if (N == E) {
                        return dir;
                    }
                    if (auto res = applyResult(w, ctx, {N, dir}, Next, E); res) {
                        return res;
                    }
                }
            }
        }
        return std::nullopt;
    }

    static std::optional<direction> applyResult(world& w, bfsContext& ctx, bfsRoad G, roadid N, roadid E) {
        if (N.cross) {
            return applyCross(w, ctx, G, N, E);
        }
        else {
            return applyStraight(w, ctx, G, N, E);
        }
    }

    bool bfs(world& w, roadid S, roadid E, std::vector<direction>& path) {
        bfsContext ctx;
        if (auto res = applyResult(w, ctx, {S, direction::n}, S, E); res) {
            return buildPath(ctx, {S, direction::n}, {E, *res}, path);
        }
        while (!ctx.openlist.empty()) {
            roadid G = pop(ctx.openlist);
            assert(!G.cross);
            auto& straight = w.straightAry[G.id];
            roadid N = straight.neighbor;
            if (auto res = applyResult(w, ctx, {G, straight.dir}, N, E); res) {
                return buildPath(ctx, {S, direction::n}, {E, *res}, path);
            }
        }
        return false;
    }
}
