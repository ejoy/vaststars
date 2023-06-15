#include "roadnet/network.h"
#include <bee/nonstd/unreachable.h>
#include <cassert>
#include <cstdio>

namespace roadnet {
    enum class MapRoad: uint8_t {
        Left         = 1 << 0,
        Top          = 1 << 1,
        Right        = 1 << 2,
        Bottom       = 1 << 3,
        Endpoint     = 1 << 4,
        NoHorizontal = 1 << 5,
        NoVertical   = 1 << 6,
    };

    static bool operator&(uint8_t v, MapRoad m) {
        return v & (uint8_t)m;
    }

    template <typename T, typename F>
    static void ary_call(network& w, uint64_t ti, T& ary, F func) {
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
        case direction::l: loc.x -= 1; break;
        case direction::t: loc.y -= 1; break;
        case direction::r: loc.x += 1; break;
        case direction::b: loc.y += 1; break;
        default: std::unreachable();
        }
        return loc;
    }

    static constexpr uint8_t makeMask(const char* maskstr) {
        uint8_t m = 0;
        m |= maskstr[0] != '_'? (1 << (uint8_t)direction::l): 0;
        m |= maskstr[1] != '_'? (1 << (uint8_t)direction::t): 0;
        m |= maskstr[2] != '_'? (1 << (uint8_t)direction::r): 0;
        m |= maskstr[3] != '_'? (1 << (uint8_t)direction::b): 0;
        return m;
    }

    static constexpr uint8_t mask(wchar_t c) {
        switch (c) {
        case L'\0': case L' ': return makeMask("____");
        case L'║': return makeMask("_T_B");
        case L'═': return makeMask("L_R_");
        case L'╔': return makeMask("__RB");
        case L'╠': return makeMask("_TRB");
        case L'╚': return makeMask("_TR_");
        case L'╦': return makeMask("L_RB");
        case L'╬': return makeMask("LTRB");
        case L'╩': return makeMask("LTR_");
        case L'╗': return makeMask("L__B");
        case L'╣': return makeMask("LT_B");
        case L'╝': return makeMask("LT__");
        case L'>': return makeMask("L___");
        case L'v': return makeMask("_T__");
        case L'<': return makeMask("__R_");
        case L'^': return makeMask("___B");
        default: assert(false); return 0;
        }
    }

    static constexpr bool isCross(uint8_t m) {
        switch (m & 0xF) {
        case mask(L' '):
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
        default:
            return false;
        case mask(L'╠'):
        case mask(L'╦'):
        case mask(L'╬'):
        case mask(L'╩'):
        case mask(L'╣'):
            return true;
        }
    }

    static constexpr direction next_direction(loction l, uint8_t m, direction dir) {
        switch (m & 0xF) {
        case mask(L'║'):
            switch (dir) {
            case direction::t: return direction::b;
            case direction::b: return direction::t;
            default: break;
            }
            break;
        case mask(L'═'):
            switch (dir) {
            case direction::l: return direction::r;
            case direction::r: return direction::l;
            default: break;
            }
            break;
        case mask(L'>'):
            switch (dir) {
            case direction::l: return direction::l;
            default: break;
            }
            break;
        case mask(L'v'):
            switch (dir) {
            case direction::t: return direction::t;
            default: break;
            }
            break;
        case mask(L'<'):
            switch (dir) {
            case direction::r: return direction::r;
            default: break;
            }
            break;
        case mask(L'^'):
            switch (dir) {
            case direction::b: return direction::b;
            default: break;
            }
            break;
        case mask(L'╔'):
            switch (dir) {
            case direction::r: return direction::b;
            case direction::b: return direction::r;
            default: break;
            }
            break;
        case mask(L'╚'):
            switch (dir) {
            case direction::r: return direction::t;
            case direction::t: return direction::r;
            default: break;
            }
            break;
        case mask(L'╗'):
            switch (dir) {
            case direction::l: return direction::b;
            case direction::b: return direction::l;
            default: break;
            }
            break;
        case mask(L'╝'):
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

    struct NeighborResult {
        loction   l;
        direction dir;
        uint16_t  n;
        uint8_t   m;
    };
    static NeighborResult findNeighbor(const flatmap<loction, uint8_t>& map, loction l, direction dir) {
        uint16_t n = 0;
        loction ln = l;
        direction nd = dir;
        for (;;) {
            ln = move(ln, nd);
            uint8_t m = getMapBits(map, ln);
            if (isCross(m) || (m & MapRoad::Endpoint)) {
                return {ln, nd, n, m};
            }
            assert(ln != l);
            nd = reverse(nd);
            nd = next_direction(ln, m, nd);
            n++;
        }
    }

    static void walkToNeighbor(const flatmap<loction, uint8_t>& map, loction l, direction dir, std::function<void(map_coord)> func) {
        for (;;) {
            l = move(l, dir);
            uint8_t m = getMapBits(map, l);
            direction prev_dir = reverse(dir);
            if (isCross(m)) {
                cross_type type = road::crossType(prev_dir, dir);
                func({l, map_index::unset, type});
                return;
            }
            direction next_dir = next_direction(l, m, prev_dir);
            cross_type type = road::crossType(prev_dir, next_dir);
            func({l, map_index::unset, type});
            if (m & MapRoad::Endpoint) {
                func({}); //TODO: remove it
                return;
            }
            dir = next_dir;
        }
    }

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
        bool exist = false;
        map_coord coord;
        loction endpoint;
    };

    struct updateMapStatus {
        flatmap<loction, crossid> crossMap;
        flatmap<loction, straightGrid> straightMap;
        flatmap<loction, straightid> endpointMap;
        std::vector<straightData> straightVec;
        uint16_t genCrossId = 0;
        uint32_t genStraightLorryOffset = 0;
        uint32_t genStraightCoordOffset = 0;
        uint16_t genEndpoint = 0;
    };

    static void setEndpoint(network& w, flatmap<loction, uint8_t> const& map, updateMapStatus& status, loction loc, direction a, direction b, uint16_t endpointId) {
        auto na = findNeighbor(map, loc, a);
        auto nb = findNeighbor(map, loc, b);
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
        assert(na.n > 0);
        auto& ep = w.endpointAry[endpointId];
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
        w.Cross(*cross_b).setNeighbor(reverse(nb.dir), straight1.id);
        ep.rev_neighbor = straight1.id;
        straightData& straight2 = status.straightVec.emplace_back(
            straightid {(uint16_t)status.straightVec.size()},
            na.n * road::straight::N + 1,
            loc,
            a,
            na.dir,
            *cross_a
        );
        w.Cross(*cross_a).setRevNeighbor(reverse(na.dir), straight2.id);
        ep.neighbor = straight2.id;

        status.endpointMap.insert_or_assign(loc, ep.rev_neighbor);
    }

    static void insertLorry01(network& nw, world& w, straightGrid& grid, lorryid lorryId, uint8_t z) {
        assert(z == 0 || z == 1);
        if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, (map_index)z)) {
            if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, (map_index)(1-z))) {
                nw.destroyLorry(w, lorryId);
            }
        }
    }

    static void insertLorry10(network& nw, world& w, straightGrid& grid, lorryid lorryId, uint8_t z) {
        assert(z == 0 || z == 1);
        if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, (map_index)z)) {
            if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, (map_index)(1-z))) {
                nw.destroyLorry(w, lorryId);
            }
        }
    }

    void network::cleanMap(world& w) {
        routeCached.clear();

        crossAry.clear();
        straightAry.clear();
        endpointAry.clear();
        straightLorry.clear();
        straightCoord.clear();

        for (uint16_t i = 0; i < lorryVec.size(); ++i) {
            auto& lorry = lorryVec[i];
            if (lorry.invaild()) {
                continue;
            }
            destroyLorry(w, lorryid{i});
        }
    }

    void network::updateMap(world& w, flatmap<loction, uint8_t> const& map) {
        routeCached.clear();

        // step.1
        dynarray<lorryStatus> lorryStatusAry;
        lorryStatusAry.reset(lorryVec.size());
        for (uint16_t i = 0; i < crossAry.size(); ++i) {
            auto const& cross = crossAry[i];
            for (size_t j = 0; j < 2; ++j) {
                if (cross.cross_lorry[j]) {
                    map_coord coord {cross.getLoction(*this), map_index::w1, cross.cross_status[j]};
                    auto& s = lorryStatusAry[cross.cross_lorry[j].get_index()];
                    s.exist = true;
                    s.coord = coord;
                }
            }
        }
        uint16_t straightId = 0;
        for (size_t i = 0; i < straightLorry.size(); ++i) {
            auto id = straightLorry[i];
            if (id) {
                for (;;) {
                    auto& straight = straightAry[straightId];
                    uint32_t offset = (uint32_t)i - straight.lorryOffset;
                    if (offset >= straight.len) {
                        straightId++;
                        continue;
                    }
                    map_coord coord = straight.getCoord(*this, offset);
                    auto& status = lorryStatusAry[id.get_index()];
                    status.exist = true;
                    status.coord = coord;
                    break;
                }
            }
        }
        {
            flatmap<straightid, loction> endpointRevMap;
            for (uint16_t i = 0; i < endpointAry.size(); ++i) {
                auto& ep = endpointAry[i];
                endpointRevMap.insert_or_assign(ep.rev_neighbor, ep.getLoction(*this));
            }
            for (uint16_t i = 0; i < lorryStatusAry.size(); ++i) {
                auto& lorry = lorryVec[i];
                if (lorry.invaild()) {
                    continue;
                }
                assert(lorryStatusAry[i].exist);
                auto ending = lorry.get_ending();
                auto loc = endpointRevMap.find(ending);
                assert(loc);
                lorryStatusAry[i].endpoint = *loc;
            }
        }

        updateMapStatus status;
        // step.2
        for (auto const& [loc, m] : map) {
            if (isCross(m)) {
                assert(!(m & MapRoad::Endpoint));
                crossid id { status.genCrossId++ };
                bool ok = status.crossMap.insert(loc, id);
                assert(ok);
            }
            else if (m & MapRoad::Endpoint) {
                status.genEndpoint++;
            }
        }
        assert(status.crossMap.size() != 0);

        // step.3
        crossAry.reset(status.genCrossId);
        for (auto const& [loc, id]: status.crossMap) {
            road::cross& cross = Cross(id);
            cross.loc = loc;
            uint8_t m = getMapBits(map, loc);
            if (m & MapRoad::NoHorizontal) {
                cross.ban |= road::LeftTurn;
                cross.ban |= road::UTurn;
                cross.ban |= road::Horizontal;
            }
            if (m & MapRoad::NoVertical) {
                cross.ban |= road::LeftTurn;
                cross.ban |= road::UTurn;
                cross.ban |= road::Vertical;
            }
    
            for (uint8_t i = 0; i < 4; ++i) {
                direction dir = (direction)i;
                if (m & (1 << i) && !cross.hasNeighbor(dir)) {
                    auto result = findNeighbor(map, loc, dir);

                    if (loc == result.l && dir == reverse(result.dir)) {
                        assert(result.n > 0);
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
                    else {
                        auto neighbor_m = result.m;
                        if (!(neighbor_m & MapRoad::Endpoint)) {
                            auto res = status.crossMap.find(result.l);
                            assert(res);
                            crossid neighbor_id {*res};
                            road::cross& neighbor = Cross(neighbor_id);
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
        endpointAry.reset(status.genEndpoint);
        uint16_t endpointId = 0;
        for (auto const& [loc, m] : map) {
            if (m & MapRoad::Endpoint) {
                auto rawm = m & 0xF;
                switch (rawm) {
                case mask(L'║'): setEndpoint(*this, map, status, loc, direction::t, direction::b, endpointId); break;
                case mask(L'═'): setEndpoint(*this, map, status, loc, direction::l, direction::r, endpointId); break;
                case mask(L'╔'): setEndpoint(*this, map, status, loc, direction::r, direction::b, endpointId); break;
                case mask(L'╚'): setEndpoint(*this, map, status, loc, direction::r, direction::t, endpointId); break;
                case mask(L'╗'): setEndpoint(*this, map, status, loc, direction::l, direction::b, endpointId); break;
                case mask(L'╝'): setEndpoint(*this, map, status, loc, direction::l, direction::t, endpointId); break;
                default: assert(false); break;
                }
                endpointId++;
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
        size_t i = 0;
        for (auto& straight: status.straightVec) {
            uint16_t offset = 0;
            walkToNeighbor(map, straight.loc, straight.start_dir, [&](map_coord coord) {
                if (!status.crossMap.find(coord.get_loction())) {
                    direction from = road::crossFrom((cross_type)coord.w);
                    direction to = road::crossTo((cross_type)coord.w);
                    auto grid = status.straightMap.find(coord.get_loction());
                    if (grid) {
                        grid->id1 = straight.id;
                        grid->offset1 = offset;
                        assert(grid->direction0 == (uint16_t)to);
                        assert(grid->direction1 == (uint16_t)from);
                    }
                    else {
                        status.straightMap.insert_or_assign(coord.get_loction(), straightGrid {
                            straight.id,
                            {},
                            offset,
                            (uint16_t)from,
                            0,
                            (uint16_t)to,
                        });
                    }
                }
                straightCoord[i + offset++] = coord;
            });
            i += offset;
        }
        assert(i == straightCoord.size());
        straightLorry.reset(status.genStraightLorryOffset);

        // step.6
        for (uint16_t i = 0; i < lorryStatusAry.size(); ++i) {
            auto& lorry = lorryVec[i];
            if (lorry.invaild()) {
                continue;
            }
            auto& s = lorryStatusAry[i];
            assert(s.exist);
            if (auto ep = status.endpointMap.find(s.endpoint)) {
                //TODO: endpoint changed
                Lorry(lorryid{i}).set_ending(*ep);
            }
            else {
                destroyLorry(w, lorryid{i});
                continue;
            }
            auto loc = s.coord.get_loction();
            auto m = getMapBits(map, loc);
            if (m == 0) {
                destroyLorry(w, lorryid{i});
                continue;
            }
            if (isCross(m)) {
                auto roadId = status.crossMap.find(loc);
                assert(roadId);
                auto& cross = Cross(*roadId);
                if (!cross.insertLorry(*this, lorryid{i}, s.coord)) {
                    destroyLorry(w, lorryid{i});
                    continue;
                }
            }
            else {
                auto roadGrid = status.straightMap.find(loc);
                assert(roadGrid);
                if (!roadGrid->id1) {
                    auto& straight = StraightRoad(roadGrid->id0);
                    if (!straight.insertLorry(*this, lorryid{i}, roadGrid->offset0, (map_index)s.coord.z)) {
                        destroyLorry(w, lorryid{i});
                        continue;
                    }
                }
                else {
                    direction dir0 = direction(roadGrid->direction0);
                    direction dir1 = direction(roadGrid->direction1);
                    direction from = road::crossFrom((cross_type)s.coord.w);
                    direction to = road::crossTo((cross_type)s.coord.w);
                    if (to == dir1) {
                        insertLorry01(*this, w, *roadGrid, lorryid{i}, s.coord.z);
                    }
                    else if (to == dir0) {
                        insertLorry10(*this, w, *roadGrid, lorryid{i}, s.coord.z);
                    }
                    else if (from == dir0) {
                        insertLorry01(*this, w, *roadGrid, lorryid{i}, s.coord.z);
                    }
                    else if (from == dir1) {
                        insertLorry10(*this, w, *roadGrid, lorryid{i}, s.coord.z);
                    }
                    else {
                        insertLorry01(*this, w, *roadGrid, lorryid{i}, s.coord.z);
                    }
                }
            }
        }
    }

    lorryid network::createLorry(world& w, uint16_t classid) {
        if (!lorryFreeList.empty()) {
            auto lorryId = lorryFreeList.back();
            lorryFreeList.pop_back();
            Lorry(lorryId).init(w, classid);
            return lorryId;
        }
        lorryid lorryId((uint16_t)lorryVec.size());
        lorryVec.emplace_back();
        Lorry(lorryId).init(w, classid);
        return lorryId;
    }
    void network::destroyLorry(world& w, lorryid id) {
        auto& lorry = Lorry(id);
        lorry.reset(w);
        lorryWaitList.push_back(id);
    }
    void network::update(uint64_t ti) {
        lorryFreeList.insert(std::end(lorryFreeList), std::begin(lorryWaitList), std::end(lorryWaitList));
        lorryWaitList.clear();
        ary_call(*this, ti, lorryVec, &lorry::update);
        ary_call(*this, ti, crossAry, &road::cross::update);
        ary_call(*this, ti, straightAry, &road::straight::update);
    }
    road::straight& network::StraightRoad(straightid id) {
        assert(id != straightid::invalid());
        assert(id.get_index() < straightAry.size());
        return straightAry[id.get_index()];
    }
    road::cross& network::Cross(crossid id) {
        assert(id != crossid::invalid());
        assert(id.get_index() < crossAry.size());
        return crossAry[id.get_index()];
    }
    lorryid& network::LorryInRoad(uint32_t index) {
        return straightLorry[index];
    }
    map_coord network::LorryInCoord(uint32_t index) const {
        return straightCoord[index];
    }
    lorry& network::Lorry(lorryid id) {
        assert(id != lorryid::invalid());
        assert(id.get_index() < lorryVec.size());
        return lorryVec[id.get_index()];
    }
    road::endpoint& network::Endpoint(endpointid id) {
        assert(id != endpointid::invalid());
        assert(id.get_index() < endpointAry.size());
        return endpointAry[id.get_index()];
    }
}
