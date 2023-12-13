#include "roadnet/network.h"
#include "core/world.h"
#include "roadnet/lorry.h"
#include "util/prototype.h"
#include <bee/nonstd/unreachable.h>
#include <cassert>

namespace roadnet {
    constexpr uint8_t kRoadSize = 2;

    enum class MapRoad: uint8_t {
        Left    = 1 << 0,
        Top     = 1 << 1,
        Right   = 1 << 2,
        Bottom  = 1 << 3,
        NoNorth = 1 << 4,
        NoEast  = 1 << 5,
        NoSouth = 1 << 6,
        NoWest  = 1 << 7,
    };

    static bool operator&(uint8_t v, MapRoad m) {
        return v & (uint8_t)m;
    }

    template <typename T, typename F>
        requires (std::is_member_function_pointer_v<F>)
    static void array_call(world& w, uint64_t ti, T& ary, F func) {
        size_t N = ary.size();
        for (size_t i = 0; i < N; ++i) {
            (ary[i].*func)(w, ti);
        }
    }

    static constexpr direction reverse(direction dir) {
        switch (dir) {
        case direction::l: return direction::r;
        case direction::t: return direction::b;
        case direction::r: return direction::l;
        case direction::b: return direction::t;
        default: std::unreachable();
        }
    }

    static constexpr loction move(loction loc, direction dir) {
        switch (dir) {
        case direction::l: loc.x -= kRoadSize; break;
        case direction::t: loc.y -= kRoadSize; break;
        case direction::r: loc.x += kRoadSize; break;
        case direction::b: loc.y += kRoadSize; break;
        default: std::unreachable();
        }
        return loc;
    }

    static constexpr bool hasDirection(uint8_t m, direction dir) {
        return (m & (1 << (uint8_t)dir)) != 0;
    }

    static constexpr uint8_t makeMask(const char* maskstr) {
        uint8_t m = 0;
        m |= maskstr[0] != '_'? (1 << 0): 0;
        m |= maskstr[1] != '_'? (1 << 1): 0;
        m |= maskstr[2] != '_'? (1 << 2): 0;
        m |= maskstr[3] != '_'? (1 << 3): 0;
        m |= maskstr[4] != '_'? (1 << 4): 0;
        m |= maskstr[5] != '_'? (1 << 5): 0;
        m |= maskstr[6] != '_'? (1 << 6): 0;
        m |= maskstr[7] != '_'? (1 << 7): 0;
        return m;
    }

    static constexpr uint8_t mask(wchar_t c) {
        switch (c) {
        case L' ': return makeMask("________");
        case L'║': return makeMask("_T_BN_S_");
        case L'═': return makeMask("L_R__E_W");
        case L'╔': return makeMask("__RB_ES_");
        case L'╠': return makeMask("_TRB____");
        case L'╚': return makeMask("_TR_NE__");
        case L'╦': return makeMask("L_RB____");
        case L'╬': return makeMask("LTRB____");
        case L'╩': return makeMask("LTR_____");
        case L'╗': return makeMask("L__B__SW");
        case L'╣': return makeMask("LT_B____");
        case L'╝': return makeMask("LT__N__W");
        case L'>': return makeMask("L___NES_");
        case L'v': return makeMask("_T___ESW");
        case L'<': return makeMask("__R_N_SW");
        case L'^': return makeMask("___B_ESW");
        default: assert(false); return 0;
        }
    }

    static constexpr uint8_t maskl(wchar_t c) {
        return mask(c) & 0xF;
    }

    enum class road_type {
        invalid,
        cross,
        straight,
    };

    static constexpr road_type getRoadType(uint8_t m) {
        switch (m) {
        case mask(L'║'):
        case mask(L'═'):
        case mask(L'>'):
        case mask(L'v'):
        case mask(L'<'):
        case mask(L'^'):
        case mask(L'╔'):
        case mask(L'╚'):
        case mask(L'╗'):
        case mask(L'╝'):
            return road_type::straight;
        case mask(L' '):
            return road_type::invalid;
        default:
            return road_type::cross;
        }
    }

    static constexpr bool isCross(uint8_t m) {
        return getRoadType(m) == road_type::cross;
    }

    static constexpr direction next_direction(loction l, uint8_t m, direction dir) {
        switch (m & 0xF) {
        case maskl(L'║'):
            switch (dir) {
            case direction::t: return direction::b;
            case direction::b: return direction::t;
            default: break;
            }
            break;
        case maskl(L'═'):
            switch (dir) {
            case direction::l: return direction::r;
            case direction::r: return direction::l;
            default: break;
            }
            break;
        case maskl(L'>'):
            switch (dir) {
            case direction::l: return direction::l;
            default: break;
            }
            break;
        case maskl(L'v'):
            switch (dir) {
            case direction::t: return direction::t;
            default: break;
            }
            break;
        case maskl(L'<'):
            switch (dir) {
            case direction::r: return direction::r;
            default: break;
            }
            break;
        case maskl(L'^'):
            switch (dir) {
            case direction::b: return direction::b;
            default: break;
            }
            break;
        case maskl(L'╔'):
            switch (dir) {
            case direction::r: return direction::b;
            case direction::b: return direction::r;
            default: break;
            }
            break;
        case maskl(L'╚'):
            switch (dir) {
            case direction::r: return direction::t;
            case direction::t: return direction::r;
            default: break;
            }
            break;
        case maskl(L'╗'):
            switch (dir) {
            case direction::l: return direction::b;
            case direction::b: return direction::l;
            default: break;
            }
            break;
        case maskl(L'╝'):
            switch (dir) {
            case direction::l: return direction::t;
            case direction::t: return direction::l;
            default: break;
            }
            break;
        }
        printf("Invalid road type: (%d,%d) %d\n", l.x, l.y, m);
        assert(false);
        return dir;
    }

    static uint8_t getMapBits(const flatmap<loction, uint8_t>& map, const loction& l) {
        auto res = map.find(l);
        return res ? *res : 0;
    }

    enum class NeighborType {
        Cross,
        Starting,
        Endpoint,
    };

    struct NeighborResult {
        loction      l;
        direction    dir;
        uint16_t     n;
        uint8_t      m;
        NeighborType type;
    };

    struct straightData {
        straightid id;
        uint16_t   len;
        loction    loc;
        direction  start_dir;
        direction  finish_dir;
        crossid neighbor; // the next cross along this straight road
        straightData(straightid id, uint16_t len, loction loc, direction start_dir, direction finish_dir, crossid neighbor)
            : id(id)
            , len(len)
            , loc(loc)
            , start_dir(start_dir)
            , finish_dir(finish_dir)
            , neighbor(neighbor)
        {}
    };

    struct straightGrid {
        straightid id0;
        straightid id1;
        uint16_t   offset0:    14;
        uint16_t   direction0:  2;
        uint16_t   offset1:    14;
        uint16_t   direction1:  2;
    };
    static_assert(sizeof(straightGrid) == sizeof(uint64_t));

    struct lorryStatus {
        loction ending;
        loction mov2;
    };
    struct startingStatus {
        ecs::starting* starting;
    };
    struct endpointStatus {
        ecs::endpoint* endpoint;
        bool changed;
    };

    struct updateMapStatus {
        flatmap<loction, uint8_t> map;
        flatmap<loction, crossid> crossMap;
        flatmap<loction, straightGrid> straightMap;
        flatmap<loction, startingStatus> startingMap;
        flatmap<loction, endpointStatus> endpointMap;
        dynarray<lorryStatus> lorryStatusAry;
        std::vector<straightData> straightVec;
        uint16_t genCrossId = 0;
        uint32_t genStraightLorryOffset = 0;
        uint32_t genStraightCoordOffset = 0;
    };

    static bool isStarting(updateMapStatus& status, loction loc) {
        return status.startingMap.contains(loc);
    }

    static bool isEndpoint(updateMapStatus& status, loction loc) {
        return status.endpointMap.contains(loc);
    }

    static NeighborResult findNeighbor(updateMapStatus& status, loction l, direction dir) {
        uint16_t n = 0;
        for (;;) {
            loction next = move(l, dir);
            uint8_t m = getMapBits(status.map, next);
            direction prev_dir = reverse(dir);
            if (!hasDirection(m, prev_dir)) {
                uint8_t curm = getMapBits(status.map, l);
                if (isCross(curm)) {
                    assert(n == 0);
                    return {l, dir, n, curm, NeighborType::Cross};
                }
                if (isEndpoint(status, l)) {
                    assert(n == 0);
                    return {l, dir, n, curm, NeighborType::Endpoint};
                }
                if (isStarting(status, next)) {
                    assert(n == 0);
                    return {l, dir, n, m, NeighborType::Starting};
                }
                dir = next_direction(l, curm, dir);
                continue;
            }
            if (isCross(m)) {
                return {next, dir, n, m, NeighborType::Cross};
            }
            if (isEndpoint(status, next)) {
                return {next, dir, n, m, NeighborType::Endpoint};
            }
            if (isStarting(status, next)) {
                return {next, dir, n, m, NeighborType::Starting};
            }
            assert(next != l);
            l = next;
            dir = reverse(dir);
            dir = next_direction(next, m, dir);
            n++;
        }
    }

    static void walkToNeighbor(updateMapStatus& status, loction l, direction dir, std::function<void(loction, map_index, cross_type)> func) {
        for (;;) {
            loction next = move(l, dir);
            uint8_t m = getMapBits(status.map, next);
            direction prev_dir = reverse(dir);
            if (!hasDirection(m, prev_dir)) {
                uint8_t curm = getMapBits(status.map, l);
                if (isCross(curm) || isStarting(status, l) || isEndpoint(status, l)) {
                    return;
                }
                dir = next_direction(l, curm, dir);
                func(l, map_index::invaild, road::crossType(dir, dir));
                continue;
            }
            if (isCross(m)) {
                func(next, map_index::unset, road::crossType(prev_dir, dir));
                return;
            }
            direction next_dir = next_direction(next, m, prev_dir);
            func(next, map_index::unset, road::crossType(prev_dir, next_dir));
            if (isStarting(status, next) || isEndpoint(status, next)) {
                func({}, map_index::unset, cross_type::ll); //TODO: remove it
                return;
            }
            l = next;
            dir = next_dir;
        }
    }

    static void setStarting(network& w, updateMapStatus& status, loction loc, direction a, direction b) {
        auto na = findNeighbor(status, loc, a);
        auto nb = findNeighbor(status, loc, b);
        if (na.type == NeighborType::Starting || nb.type == NeighborType::Starting) {
            if (na.l == loc) {
                std::swap(na, nb);
                std::swap(a, b);
            }
            if (na.type != NeighborType::Cross) {
                return;
            }
            assert(nb.l == loc && na.n != loc);
        }
        else if (na.type == NeighborType::Cross && nb.type == NeighborType::Cross) {
            assert(na.l == nb.l);
            assert(na.n == nb.n);
            if (nb.dir == b) {
                std::swap(na, nb);
                std::swap(a, b);
            }
            assert(na.dir == a);
        }
        else {
            assert(false);
        }
        auto stInfo = status.startingMap.find(loc);
        assert(stInfo);
        auto cross_a = status.crossMap.find(na.l);
        assert(cross_a);

        straightData& straight = status.straightVec.emplace_back(
            straightid {(uint16_t)status.straightVec.size()},
            na.n * road::straight::N + 1,
            loc,
            a,
            na.dir,
            *cross_a
        );
        w.CrossRoad(*cross_a).setRevNeighbor(reverse(na.dir), straight.id);
        stInfo->starting->neighbor = straight.id;
    }

    static void setEndpoint(network& w, updateMapStatus& status, loction loc, direction a, direction b) {
        auto na = findNeighbor(status, loc, a);
        auto nb = findNeighbor(status, loc, b);
        if (na.type != NeighborType::Cross || nb.type != NeighborType::Cross) {
            return;
        }
        assert (loc != na.l && loc != nb.l);
        if (na.l == nb.l) {
            assert(false);
        }
        else if (na.l.y == nb.l.y) {
            assert(loc.y != na.l.y);
            bool left_handled = loc.y > na.l.y;
            bool a_less_b = na.l.x > nb.l.x;
            if (left_handled != a_less_b) {
                std::swap(na, nb);
                std::swap(a, b);
            }
        }
        else if (na.l.x == nb.l.x) {
            assert(loc.x != nb.l.x);
            bool left_handled = loc.x < nb.l.x;
            bool a_less_b = na.l.y > nb.l.y;
            if (left_handled != a_less_b) {
                std::swap(na, nb);
                std::swap(a, b);
            }
        }
        else {
            assert(false);
        }
        auto epInfo = status.endpointMap.find(loc);
        assert(epInfo);
        auto cross_a = status.crossMap.find(na.l);
        auto cross_b = status.crossMap.find(nb.l);
        assert(cross_a);
        assert(cross_b);

        straightData& straight1 = status.straightVec.emplace_back(
            straightid {(uint16_t)status.straightVec.size()},
            (nb.n + 1) * road::straight::N,
            nb.l,
            reverse(nb.dir),
            reverse(b),
            crossid::invalid()
        );
        w.CrossRoad(*cross_b).setNeighbor(reverse(nb.dir), straight1.id);
        epInfo->endpoint->rev_neighbor = straight1.id;
        straightData& straight2 = status.straightVec.emplace_back(
            straightid {(uint16_t)status.straightVec.size()},
            na.n * road::straight::N + 1,
            loc,
            a,
            na.dir,
            *cross_a
        );
        w.CrossRoad(*cross_a).setRevNeighbor(reverse(na.dir), straight2.id);
        epInfo->endpoint->neighbor = straight2.id;
    }

    static void insertLorry01(network& nw, world& w, straightGrid& grid, lorry_entity& l, map_index z) {
        assert(z == map_index::w0 || z == map_index::w1);
        lorryid lorryId {uint16_t(l.get_index<ecs::lorry>())};
        if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, z)) {
            if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, (map_index)(1-(uint8_t)z))) {
                nw.destroyLorry(w, l);
            }
        }
    }

    static void insertLorry10(network& nw, world& w, straightGrid& grid, lorry_entity& l, map_index z) {
        assert(z == map_index::w0 || z == map_index::w1);
        lorryid lorryId {uint16_t(l.get_index<ecs::lorry>())};
        if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, z)) {
            if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, (map_index)(1-(uint8_t)z))) {
                nw.destroyLorry(w, l);
            }
        }
    }

    lorryid network::getLorryId(ecs::lorry& l) {
        return lorryid {uint16_t(&l - lorryAry)};
    }

    void network::refresh(world& w, bool check) {
        if (check && ecs_api::count<ecs::lorry>(w.ecs) == 0) {
            auto e = ecs_api::create_entity<ecs::lorry>(w.ecs);
            assert(!e.invalid());
            lorryInit(e.get<ecs::lorry>());
            e.enable_tag<ecs::lorry_free>();
        }
        auto view = ecs_api::array<ecs::lorry>(w.ecs);
        assert(!view.empty());
        lorryAry = view.data();
    }

    static loction buildingLoction(world& world, ecs::building& b, loction l) {
        uint16_t area = prototype::get<"area">(world, b.prototype);
        uint8_t w = area >> 8;
        uint8_t h = area & 0xFF;
        assert(w > 0 && h > 0);
        w--;
        h--;
        uint8_t x;
        uint8_t y;
        switch (b.direction) {
        case 0: // N
            x = uint8_t(b.x + l.x);
            y = uint8_t(b.y + l.y);
            break;
        case 1: // E
            x = uint8_t(b.x + (h - l.y - 1));
            y = uint8_t(b.y + l.x);
            break;
        case 2: // S
            x = uint8_t(b.x + (w - l.x - 1));
            y = uint8_t(b.y + (h - l.y - 1));
            break;
        case 3: // W
            x = uint8_t(b.x + l.y);
            y = uint8_t(b.y + (w - l.x - 1));
            break;
        default:
            assert(false);
            return {};
        }
        assert(x % 2 == 0 && y % 2 == 0);
        return { x, y };
    }

    struct road_prototype {
        uint8_t x;
        uint8_t y;
        uint8_t mask;
    };

    static uint8_t rotateMask(uint8_t m, direction dir) {
        uint8_t v1 = (m >> 0) & 0xF;
        uint8_t v2 = (m >> 4) & 0xF;
        uint8_t shift = (uint8_t)dir;
        v1 = ((v1 << shift) & 0xF) | ((v1 >> (4 - shift)) & 0xF);
        v2 = ((v2 << shift) & 0xF) | ((v2 >> (4 - shift)) & 0xF);
        return v1 | (v2 << 4);
    }

    void network::build(world& w) {
        routeCached.clear();

        // step.1
        updateMapStatus status;
        for (auto& e : ecs_api::select<ecs::road, ecs::building>(w.ecs)) {
            auto& building = e.get<ecs::building>();
            for (auto const& pt : prototype::get_span<"road", road_prototype>(w, building.prototype)) {
                auto loc = buildingLoction(w, building, {pt.x, pt.y});
                uint8_t mask = rotateMask(pt.mask, (direction)building.direction);
                auto [found, slot] = status.map.find_or_insert(loc);
                assert(!found);
                *slot = mask;
            }
        }
        for (auto& e : ecs_api::select<ecs::starting, ecs::building>(w.ecs)) {
            auto& starting = e.get<ecs::starting>();
            auto& building = e.get<ecs::building>();
            starting.neighbor = 0xffff;
            {
                uint16_t l = prototype::get<"starting">(w, building.prototype);
                auto loc = buildingLoction(w, building, std::bit_cast<loction>(l));
                auto [found, slot] = status.startingMap.find_or_insert(loc);
                assert(!found);
                slot->starting = &starting;
            }
            for (auto const& pt : prototype::get_span<"road", road_prototype>(w, building.prototype)) {
                auto loc = buildingLoction(w, building, {pt.x, pt.y});
                uint8_t mask = rotateMask(pt.mask, (direction)building.direction);
                auto [found, slot] = status.map.find_or_insert(loc);
                if (found) {
                    *slot |= mask;
                }
                else {
                    *slot = mask;
                }
            }
        }
        for (auto& e : ecs_api::select<ecs::endpoint, ecs::building>(w.ecs)) {
            auto& endpoint = e.get<ecs::endpoint>();
            auto& building = e.get<ecs::building>();
            endpoint.neighbor = 0xffff;
            endpoint.rev_neighbor = 0xffff;
            {
                uint16_t l = prototype::get<"endpoint">(w, building.prototype);
                auto loc = buildingLoction(w, building, std::bit_cast<loction>(l));
                auto [found, slot] = status.endpointMap.find_or_insert(loc);
                assert(!found);
                slot->endpoint = &endpoint;
                if (e.component<ecs::building_new>()) {
                    slot->changed = true;
                }
                else if (e.component<ecs::building_changed>()) {
                    slot->changed = true;
                }
                else if (e.component<ecs::station_changed>()) {
                    slot->changed = true;
                }
            }
            for (auto const& pt : prototype::get_span<"road", road_prototype>(w, building.prototype)) {
                auto loc = buildingLoction(w, building, {pt.x, pt.y});
                uint8_t mask = rotateMask(pt.mask, (direction)building.direction);
                auto [found, slot] = status.map.find_or_insert(loc);
                if (found) {
                    *slot |= mask;
                }
                else {
                    *slot = mask;
                }
            }
        }
        status.lorryStatusAry.reset(ecs_api::count<ecs::lorry>(w.ecs));
        for (auto& lorry : ecs_api::array<ecs::lorry>(w.ecs)) {
            if (lorryInvalid(lorry)) {
                continue;
            }
            auto& s = status.lorryStatusAry[getLorryId(lorry).get_index()];
            s.ending = StraightRoad(lorry.ending).waitingLoction(*this);
            if (lorry.target == lorry_target::mov1) {
                s.mov2 = StraightRoad(lorry.mov2).waitingLoction(*this);
            }
        }

        // step.2
        for (auto const& [loc, m] : status.map) {
            if (isCross(m)) {
                assert(!isStarting(status, loc) && !isEndpoint(status, loc));
                crossid id { status.genCrossId++ };
                bool ok = status.crossMap.insert(loc, id);
                assert(ok); (void)ok;
            }
        }

        // step.3
        crossAry.reset(status.genCrossId);
        for (auto const& [loc, id]: status.crossMap) {
            road::cross& cross = CrossRoad(id);
            cross.loc = loc;
            uint8_t m = getMapBits(status.map, loc);
            if (m & MapRoad::NoNorth) {
                cross.ban |= road::NoNorth;
            }
            if (m & MapRoad::NoEast) {
                cross.ban |= road::NoEast;
            }
            if (m & MapRoad::NoSouth) {
                cross.ban |= road::NoSouth;
            }
            if (m & MapRoad::NoWest) {
                cross.ban |= road::NoWest;
            }
    
            for (uint8_t i = 0; i < 4; ++i) {
                direction dir = (direction)i;
                if (m & (1 << i) && !cross.hasNeighbor(dir)) {
                    auto result = findNeighbor(status, loc, dir);
                    if (loc == result.l) {
                        if (result.n == 0) {
                            // nothing to do
                        }
                        else {
                            assert(result.n > 0);
                            assert(dir == reverse(result.dir));
                            straightData& straight = status.straightVec.emplace_back(
                                straightid {(uint16_t)status.straightVec.size()},
                                result.n * road::straight::N + 1,
                                loc,
                                dir,
                                result.dir,
                                id
                            );
                            cross.setNeighbor(dir, straight.id);
                            cross.setRevNeighbor(reverse(result.dir), straight.id);
                        }
                    }
                    else {
                        if (result.type == NeighborType::Cross) {
                            auto res = status.crossMap.find(result.l);
                            assert(res);
                            crossid neighbor_id {*res};
                            road::cross& neighbor = CrossRoad(neighbor_id);
                            straightData& straight1 = status.straightVec.emplace_back(
                                straightid {(uint16_t)status.straightVec.size()},
                                result.n * road::straight::N + 1,
                                loc,
                                dir,
                                result.dir,
                                neighbor_id
                            );
                            cross.setNeighbor(dir, straight1.id);
                            neighbor.setRevNeighbor(reverse(result.dir), straight1.id);
                            straightData& straight2 = status.straightVec.emplace_back(
                                straightid {(uint16_t)status.straightVec.size()},
                                result.n * road::straight::N + 1,
                                result.l,
                                reverse(result.dir),
                                reverse(dir),
                                id
                            );
                            neighbor.setNeighbor(reverse(result.dir), straight2.id);
                            cross.setRevNeighbor(dir, straight2.id);
                        }
                    }
                }
            }
        }

        // step.4
        for (auto const& [loc, _] : status.startingMap) {
            auto m = status.map.find(loc);
            assert(m);
            switch (*m & 0xF) {
            case maskl(L'║'): setStarting(*this, status, loc, direction::t, direction::b); break;
            case maskl(L'═'): setStarting(*this, status, loc, direction::l, direction::r); break;
            case maskl(L'╔'): setStarting(*this, status, loc, direction::r, direction::b); break;
            case maskl(L'╚'): setStarting(*this, status, loc, direction::r, direction::t); break;
            case maskl(L'╗'): setStarting(*this, status, loc, direction::l, direction::b); break;
            case maskl(L'╝'): setStarting(*this, status, loc, direction::l, direction::t); break;
            default: assert(false); break;
            }
        }
        for (auto const& [loc, _] : status.endpointMap) {
            auto m = status.map.find(loc);
            assert(m);
            switch (*m & 0xF) {
            case maskl(L'║'): setEndpoint(*this, status, loc, direction::t, direction::b); break;
            case maskl(L'═'): setEndpoint(*this, status, loc, direction::l, direction::r); break;
            case maskl(L'╔'): setEndpoint(*this, status, loc, direction::r, direction::b); break;
            case maskl(L'╚'): setEndpoint(*this, status, loc, direction::r, direction::t); break;
            case maskl(L'╗'): setEndpoint(*this, status, loc, direction::l, direction::b); break;
            case maskl(L'╝'): setEndpoint(*this, status, loc, direction::l, direction::t); break;
            default: assert(false); break;
            }
        }

        // step.5
        straightAry.reset(status.straightVec.size());
        for (auto& data: status.straightVec) {
            road::straight& straight = StraightRoad(data.id);
            size_t length = data.len;
            straight.init(data.id, (uint16_t)length, data.finish_dir, data.neighbor);
            straight.setLorryOffset(status.genStraightLorryOffset);
            straight.setCoordOffset(status.genStraightCoordOffset);
            status.genStraightLorryOffset += (uint16_t)length;
            status.genStraightCoordOffset += (uint16_t)(length / road::straight::N + 1);
        }
        straightCoord.reset(status.genStraightCoordOffset);
        size_t straightCoordOffset = 0;
        for (auto& data: status.straightVec) {
            assert(StraightRoad(data.id).coordOffset == straightCoordOffset);
            uint16_t offset = 0;
            walkToNeighbor(status, data.loc, data.start_dir, [&](loction l, map_index i, cross_type ct) {
                if (i == map_index::invaild) {
                    i = map_index::unset;
                    offset--;
                    direction from = road::crossFrom(ct);
                    direction to = road::crossTo(ct);
                    auto [found, grid] = status.straightMap.find_or_insert(l);
                    assert(found);
                    grid->id0 = data.id;
                    grid->offset0 = offset;
                    grid->direction0 = (uint16_t)from;
                    grid->direction1 = (uint16_t)to;
                }
                else if (!status.crossMap.find(l)) {
                    direction from = road::crossFrom(ct);
                    direction to = road::crossTo(ct);
                    auto [found, grid] = status.straightMap.find_or_insert(l);
                    if (found) {
                        grid->id1 = data.id;
                        grid->offset1 = offset;
                        assert(grid->direction0 == (uint16_t)to);
                        assert(grid->direction1 == (uint16_t)from);
                    }
                    else {
                        *grid = straightGrid {
                            data.id,
                            {},
                            offset,
                            (uint16_t)from,
                            0,
                            (uint16_t)to,
                        };
                    }
                }
                straightCoord[straightCoordOffset + offset++] = {l, i, ct};
            });
            straightCoordOffset += offset;
        }
        assert(straightCoordOffset == straightCoord.size());
        straightLorry.reset(status.genStraightLorryOffset);

        // step.6
        for (auto& e : ecs_api::select<ecs::lorry>(w.ecs)) {
            auto& lorry = e.get<ecs::lorry>();
            if (lorryInvalid(lorry)) {
                continue;
            }
            switch (lorry.target) {
            case lorry_target::mov1: {
                auto& s = status.lorryStatusAry[getLorryId(lorry).get_index()];
                if (auto ep1 = status.endpointMap.find(s.ending); ep1 && !ep1->changed) {
                    if (auto ep2 = status.endpointMap.find(s.mov2); ep2 && !ep2->changed) {
                        lorryGoMov1(lorry, lorry.item_prototype, *ep1->endpoint, *ep2->endpoint);
                    }
                }
                else {
                    destroyLorry(w, e);
                    continue;
                }
                break;
            }
            case lorry_target::mov2: {
                auto& s = status.lorryStatusAry[getLorryId(lorry).get_index()];
                if (auto ep = status.endpointMap.find(s.ending); ep && !ep->changed) {
                    lorryGoMov2(lorry, ep->endpoint->rev_neighbor, lorry.item_amount);
                }
                else {
                    destroyLorry(w, e);
                    continue;
                }
                break;
            }
            case lorry_target::home: {
                auto& s = status.lorryStatusAry[getLorryId(lorry).get_index()];
                if (auto ep = status.endpointMap.find(s.ending); ep && !ep->changed) {
                    lorryGoHome(lorry, *ep->endpoint);
                }
                else {
                    destroyLorry(w, e);
                    continue;
                }
                break;
            }
            default:
                std::unreachable();
            }
            loction loc {lorry.x, lorry.y};
            auto m = getMapBits(status.map, loc);
            switch (getRoadType(m)) {
            case road_type::invalid:
                destroyLorry(w, e);
                break;
            case road_type::cross: {
                auto roadId = status.crossMap.find(loc);
                assert(roadId);
                auto& cross = CrossRoad(*roadId);
                if (!cross.insertLorry(*this, getLorryId(lorry), map_coord::get_map_index(lorry.z), map_coord::get_cross_type(lorry.z))) {
                    destroyLorry(w, e);
                }
                break;
            }
            case road_type::straight: {
                if (auto roadGrid = status.straightMap.find(loc)) {
                    if (!roadGrid->id1) {
                        auto& straight = StraightRoad(roadGrid->id0);
                        if (!straight.insertLorry(*this, getLorryId(lorry), roadGrid->offset0, map_coord::get_map_index(lorry.z))) {
                            destroyLorry(w, e);
                        }
                    }
                    else {
                        direction dir0 = direction(roadGrid->direction0);
                        direction dir1 = direction(roadGrid->direction1);
                        direction from = road::crossFrom(map_coord::get_cross_type(lorry.z));
                        direction to = road::crossTo(map_coord::get_cross_type(lorry.z));
                        if (to == dir1) {
                            insertLorry01(*this, w, *roadGrid, e, map_coord::get_map_index(lorry.z));
                        }
                        else if (to == dir0) {
                            insertLorry10(*this, w, *roadGrid, e, map_coord::get_map_index(lorry.z));
                        }
                        else if (from == dir0) {
                            insertLorry01(*this, w, *roadGrid, e, map_coord::get_map_index(lorry.z));
                        }
                        else if (from == dir1) {
                            insertLorry10(*this, w, *roadGrid, e, map_coord::get_map_index(lorry.z));
                        }
                        else {
                            insertLorry01(*this, w, *roadGrid, e, map_coord::get_map_index(lorry.z));
                        }
                    }
                }
                else {
                    destroyLorry(w, e);
                }
                break;
            }
            }
        }
    }

    lorryid network::createLorry(world& w, uint16_t classid) {
        {
            auto e = ecs_api::first_entity<ecs::lorry_free, ecs::lorry>(w.ecs);
            if (!e.invalid()) {
                auto& l = e.get<ecs::lorry>();
                e.disable_tag<ecs::lorry_free>();
                lorryInit(l, w, classid);
                return getLorryId(l);
            }
        }
        {
            auto e = ecs_api::create_entity<ecs::lorry>(w.ecs);
            assert(!e.invalid());
            auto& l = e.get<ecs::lorry>();
            lorryInit(l, w, classid);
            refresh(w, false);
            return getLorryId(l);
        }
    }
    void network::destroyLorry(world& w, lorry_entity& l) {
        l.enable_tag<ecs::lorry_changed>();
        l.enable_tag<ecs::lorry_removed>();
        lorryDestroy(l.get<ecs::lorry>(), w);
    }
    void network::updateRemoveLorry(world& w, size_t n) {
        flatset<lorryid> lorryWillRemove;
        flatmap<straightid, uint8_t> endpointWillReset;
        lorryWillRemove.reserve(n);
        endpointWillReset.reserve(n);
        for (auto& e : ecs_api::select<ecs::lorry_willremove, ecs::lorry>(w.ecs)) {
            auto& lorry = e.get<ecs::lorry>();
            e.enable_tag<ecs::lorry_changed>();
            e.enable_tag<ecs::lorry_removed>();
            lorryDestroy(lorry, w);
            lorryWillRemove.insert(getLorryId(lorry));
            auto [found, slot] = endpointWillReset.find_or_insert(lorry.ending);
            if (found) {
                *slot += 1;
            }
            else {
                *slot = 1;
            }
        }

        for (auto& endpoint : ecs_api::array<ecs::endpoint>(w.ecs)) {
            if (endpoint.rev_neighbor) {
                endpointWillReset.erase(endpoint.rev_neighbor);
            }
        }

        for (size_t i = 0; i < straightLorry.size(); ++i) {
            if (straightLorry[i] && lorryWillRemove.contains(straightLorry[i])) {
                straightLorry[i] = {};
                lorryWillRemove.erase(straightLorry[i]);
            }
        }

        for (size_t i = 0; i < crossAry.size(); ++i) {
            auto& cross = crossAry[i];
            if (cross.cross_lorry[0] && lorryWillRemove.contains(cross.cross_lorry[0])) {
                cross.cross_lorry[0] = {};
                lorryWillRemove.erase(cross.cross_lorry[0]);
            }
            if (cross.cross_lorry[1] && lorryWillRemove.contains(cross.cross_lorry[1])) {
                cross.cross_lorry[1] = {};
                lorryWillRemove.erase(cross.cross_lorry[1]);
            }
        }

        ecs_api::clear_type<ecs::lorry_willremove>(w.ecs);
    }
    void network::update(world& w, uint64_t ti) {
        for (auto& e : ecs_api::select<ecs::lorry_removed>(w.ecs)) {
            e.enable_tag<ecs::lorry_free>();
        }
        ecs_api::clear_type<ecs::lorry_removed>(w.ecs);
        auto n = ecs_api::count<ecs::lorry_willremove>(w.ecs);
        if (n > 0) {
            updateRemoveLorry(w, n);
        }
        for (auto& e : ecs_api::select<ecs::lorry>(w.ecs)) {
            auto& lorry = e.get<ecs::lorry>();
            if (lorryInvalid(lorry)) {
                continue;
            }
            lorryUpdate(e, lorry);
        }
        array_call(w, ti, crossAry, &road::cross::update);
        array_call(w, ti, straightAry, &road::straight::update);
    }
    road::straight& network::StraightRoad(straightid id) {
        assert(id != straightid::invalid());
        assert(id.get_index() < straightAry.size());
        return straightAry[id.get_index()];
    }
    road::cross& network::CrossRoad(crossid id) {
        assert(id != crossid::invalid());
        assert(id.get_index() < crossAry.size());
        return crossAry[id.get_index()];
    }
    ecs::lorry& network::Lorry(world& w, lorryid id) {
        assert(id != lorryid::invalid());
        assert(id.get_index() < ecs_api::count<ecs::lorry>(w.ecs));
        return lorryAry[id.get_index()];
    }
    lorry_entity network::LorryEntity(world& w, ecs::lorry& lorry) {
        return ecs_api::index_entity<ecs::lorry>(w.ecs, uint16_t(&lorry - lorryAry));
    }
    lorryid& network::LorryInRoad(uint32_t index) {
        return straightLorry[index];
    }
    map_coord network::LorryInCoord(uint32_t index) const {
        return straightCoord[index];
    }
}
