#include "roadnet/network.h"
#include "core/world.h"
#include "roadnet/lorry.h"
#include "util/prototype.h"
#include <bee/nonstd/unreachable.h>
#include <cassert>

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

    static void walkToNeighbor(const flatmap<loction, uint8_t>& map, loction l, direction dir, std::function<void(loction, map_index, cross_type)> func) {
        for (;;) {
            l = move(l, dir);
            uint8_t m = getMapBits(map, l);
            direction prev_dir = reverse(dir);
            if (isCross(m)) {
                cross_type type = road::crossType(prev_dir, dir);
                func(l, map_index::unset, type);
                return;
            }
            direction next_dir = next_direction(l, m, prev_dir);
            cross_type type = road::crossType(prev_dir, next_dir);
            func(l, map_index::unset, type);
            if (m & MapRoad::Endpoint) {
                func({}, map_index::invaild, cross_type::ll); //TODO: remove it
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
        loction endpoint;
    };

    struct updateMapStatus {
        flatmap<loction, crossid> crossMap;
        flatmap<loction, straightGrid> straightMap;
        flatmap<loction, ecs::endpoint*> endpointMap;
        dynarray<lorryStatus> lorryStatusAry;
        std::vector<straightData> straightVec;
        uint16_t genCrossId = 0;
        uint32_t genStraightLorryOffset = 0;
        uint32_t genStraightCoordOffset = 0;
    };

    static void setEndpoint(network& w, flatmap<loction, uint8_t> const& map, updateMapStatus& status, loction loc, direction a, direction b) {
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
        auto ep = status.endpointMap.find(loc);
        assert(ep);
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
        (*ep)->rev_neighbor = straight1.id;
        straightData& straight2 = status.straightVec.emplace_back(
            straightid {(uint16_t)status.straightVec.size()},
            na.n * road::straight::N + 1,
            loc,
            a,
            na.dir,
            *cross_a
        );
        w.CrossRoad(*cross_a).setRevNeighbor(reverse(na.dir), straight2.id);
        (*ep)->neighbor = straight2.id;
    }

    static void insertLorry01(network& nw, world& w, straightGrid& grid, lorry_entity& l, map_index z) {
        assert(z == map_index::w0 || z == map_index::w1);
        lorryid lorryId {uint16_t(l.getid())};
        if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, z)) {
            if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, (map_index)(1-(uint8_t)z))) {
                nw.destroyLorry(w, l);
            }
        }
    }

    static void insertLorry10(network& nw, world& w, straightGrid& grid, lorry_entity& l, map_index z) {
        assert(z == map_index::w0 || z == map_index::w1);
        lorryid lorryId {uint16_t(l.getid())};
        if (!nw.StraightRoad(grid.id1).insertLorry(nw, lorryId, grid.offset1, z)) {
            if (!nw.StraightRoad(grid.id0).insertLorry(nw, lorryId, grid.offset0, (map_index)(1-(uint8_t)z))) {
                nw.destroyLorry(w, l);
            }
        }
    }

    void network::init(world& w) {
        bool create = ecs_api::count<ecs::lorry>(w.ecs) == 0;
        if (create) {
            int id = entity_new(w.ecs, ecs_api::component_id<ecs::lorry>, NULL);
            assert(id == 0);
            entity_enable_tag(w.ecs, ecs_api::component_id<ecs::lorry>, id, ecs_api::component_id<ecs::lorry_removed>);
            entity_enable_tag(w.ecs, ecs_api::component_id<ecs::lorry>, id, ecs_api::component_id<ecs::lorry_free>);
        }
        refresh(w);
    }

    void network::refresh(world& w) {
        ecs_api::entity<ecs::lorry> e(*w.ecs);
        bool ok = e.init(0);
        assert(ok);
        lorryAry = &e.get<ecs::lorry>();
    }

    static loction buildingLoction(world& world, ecs::building& b, loction l) {
        constexpr int kRoadScale = 2;
        uint16_t area = prototype::get<"area">(world, b.prototype);
        uint8_t w = area >> 8;
        uint8_t h = area & 0xFF;
        assert(w > 0 && h > 0);
        w--;
        h--;
        
        switch (b.direction) {
        case 0: // N
            return { uint8_t((b.x + l.x) / kRoadScale),       uint8_t((b.y + l.y) / kRoadScale) };
        case 1: // E
            return { uint8_t((b.x + (h - l.y)) / kRoadScale), uint8_t((b.y + l.x) / kRoadScale) };
        case 2: // S
            return { uint8_t((b.x + (w - l.x)) / kRoadScale), uint8_t((b.y + (h - l.y)) / kRoadScale) };
        case 3: // W
            return { uint8_t((b.x + l.y) / kRoadScale),       uint8_t((b.y + (w - l.x)) / kRoadScale) };
        default:
            assert(false);
            return {};
        }
    }

    void network::rebuildMap(world& w, flatmap<loction, uint8_t> const& map) {
        init(w);

        using namespace ecs_api::flags;
        routeCached.clear();

        if (map.empty()) {
            for (auto& e : ecs_api::select<ecs::endpoint>(w.ecs)) {
                auto& endpoint = e.get<ecs::endpoint>();
                endpoint.neighbor = 0xffff;
                endpoint.rev_neighbor = 0xffff;
                endpoint.lorry = 0;
            }
            for (auto& e : ecs_api::select<ecs::lorry, ecs::lorry_removed(absent)>(w.ecs)) {
                destroyLorry(w, e);
            }
            crossAry.clear();
            straightAry.clear();
            straightLorry.clear();
            straightCoord.clear();
            return;
        }

        // step.1
        updateMapStatus status;
        for (auto& e : ecs_api::select<ecs::endpoint, ecs::building>(w.ecs)) {
            auto& endpoint = e.get<ecs::endpoint>();
            auto& building = e.get<ecs::building>();
            uint16_t l = prototype::get<"endpoint">(w, building.prototype);
            auto loc = buildingLoction(w, building, std::bit_cast<loction>(l));
            endpoint.neighbor = 0xffff;
            endpoint.rev_neighbor = 0xffff;
            endpoint.lorry = 0;
            status.endpointMap.insert_or_assign(loc, &endpoint);
        }

        status.lorryStatusAry.reset(ecs_api::count<ecs::lorry>(w.ecs));
        for (auto& e : ecs_api::select<ecs::lorry, ecs::lorry_removed(absent)>(w.ecs)) {
            auto& lorry = e.get<ecs::lorry>();
            status.lorryStatusAry[e.getid()].endpoint = StraightRoad(lorry.ending).waitingLoction(*this);
        }

        // step.2
        for (auto const& [loc, m] : map) {
            if (isCross(m)) {
                assert(!(m & MapRoad::Endpoint));
                crossid id { status.genCrossId++ };
                bool ok = status.crossMap.insert(loc, id);
                assert(ok);
            }
        }
        assert(status.crossMap.size() != 0);

        // step.3
        crossAry.reset(status.genCrossId);
        for (auto const& [loc, id]: status.crossMap) {
            road::cross& cross = CrossRoad(id);
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
        for (auto const& [loc, m] : map) {
            if (m & MapRoad::Endpoint) {
                auto rawm = m & 0xF;
                switch (rawm) {
                case mask(L'║'): setEndpoint(*this, map, status, loc, direction::t, direction::b); break;
                case mask(L'═'): setEndpoint(*this, map, status, loc, direction::l, direction::r); break;
                case mask(L'╔'): setEndpoint(*this, map, status, loc, direction::r, direction::b); break;
                case mask(L'╚'): setEndpoint(*this, map, status, loc, direction::r, direction::t); break;
                case mask(L'╗'): setEndpoint(*this, map, status, loc, direction::l, direction::b); break;
                case mask(L'╝'): setEndpoint(*this, map, status, loc, direction::l, direction::t); break;
                default: assert(false); break;
                }
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
        for (auto& straight: status.straightVec) {
            uint16_t offset = 0;
            walkToNeighbor(map, straight.loc, straight.start_dir, [&](loction l, map_index i, cross_type ct) {
                if (!status.crossMap.find(l)) {
                    direction from = road::crossFrom(ct);
                    direction to = road::crossTo(ct);
                    auto grid = status.straightMap.find(l);
                    if (grid) {
                        grid->id1 = straight.id;
                        grid->offset1 = offset;
                        assert(grid->direction0 == (uint16_t)to);
                        assert(grid->direction1 == (uint16_t)from);
                    }
                    else {
                        status.straightMap.insert_or_assign(l, straightGrid {
                            straight.id,
                            {},
                            offset,
                            (uint16_t)from,
                            0,
                            (uint16_t)to,
                        });
                    }
                }
                straightCoord[straightCoordOffset + offset++] = {l, i, ct};
            });
            straightCoordOffset += offset;
        }
        assert(straightCoordOffset == straightCoord.size());
        straightLorry.reset(status.genStraightLorryOffset);

        // step.6
        for (auto& e : ecs_api::select<ecs::lorry, ecs::lorry_removed(absent)>(w.ecs)) {
            auto& lorry = e.get<ecs::lorry>();
            auto& s = status.lorryStatusAry[e.getid()];
            if (auto ep = status.endpointMap.find(s.endpoint)) {
                //TODO: endpoint changed
                lorryGo(lorry, **ep, lorry.item_classid, lorry.item_amount);
            }
            else {
                destroyLorry(w, e);
                continue;
            }
            loction loc {lorry.x, lorry.y};
            auto m = getMapBits(map, loc);
            if (m == 0) {
                destroyLorry(w, e);
                continue;
            }
            if (isCross(m)) {
                auto roadId = status.crossMap.find(loc);
                assert(roadId);
                auto& cross = CrossRoad(*roadId);
                if (!cross.insertLorry(*this, lorryid{(uint16_t)e.getid()}, map_coord::get_map_index(lorry.z), map_coord::get_cross_type(lorry.z))) {
                    destroyLorry(w, e);
                    continue;
                }
            }
            else {
                auto roadGrid = status.straightMap.find(loc);
                assert(roadGrid);
                if (!roadGrid->id1) {
                    auto& straight = StraightRoad(roadGrid->id0);
                    if (!straight.insertLorry(*this, lorryid{(uint16_t)e.getid()}, roadGrid->offset0, map_coord::get_map_index(lorry.z))) {
                        destroyLorry(w, e);
                        continue;
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
        }
    }

    lorryid network::getLorryId(ecs::lorry& l) {
        return lorryid {uint16_t(&l - lorryAry)};
    }

    lorryid network::createLorry(world& w, uint16_t classid) {
        ecs_api::entity<ecs::lorry_free, ecs::lorry> e(*w.ecs);
        e.next();
        if (!e.invalid()) {
            auto& l = e.get<ecs::lorry>();
            e.disable_tag<ecs::lorry_removed>();
            e.disable_tag<ecs::lorry_free>();
            lorryInit(l, w, classid);
            return getLorryId(l);
        }
        int id = entity_new(w.ecs, ecs_api::component_id<ecs::lorry>, NULL);
        assert(id >= 0);
        refresh(w);
        lorryid lorryId {(uint16_t)id};
        lorryInit(Lorry(w, lorryId), w, classid);
        return lorryId;
    }
    void network::destroyLorry(world& w, lorry_entity& l) {
        l.enable_tag<ecs::lorry_removed>();
    }
    void network::updateRemoveLorry(world& w, size_t n) {
        flatset<lorryid> lorryWillRemove;
        flatmap<straightid, uint8_t> endpointWillReset;
        lorryWillRemove.reserve(n);
        endpointWillReset.reserve(n);
        size_t sz = 0;
        for (auto& e : ecs_api::select<ecs::lorry_willremove, ecs::lorry>(w.ecs)) {
            e.enable_tag<ecs::lorry_removed>();
            auto& lorry = e.get<ecs::lorry>();
            lorryWillRemove.insert(getLorryId(lorry));
            if (auto res = endpointWillReset.find(lorry.ending)) {
                *res++;
            }
            else {
                endpointWillReset.insert_or_assign(lorry.ending, 1);
            }
        }

        for (auto& e : ecs_api::select<ecs::endpoint>(w.ecs)) {
            auto& endpoint = e.get<ecs::endpoint>();
            if (auto res = endpointWillReset.find(endpoint.rev_neighbor)) {
                assert(endpoint.lorry >= *res);
                endpoint.lorry -= *res;
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
        using namespace ecs_api::flags;
        for (auto& e : ecs_api::select<ecs::lorry_removed, ecs::lorry_free(absent)>(w.ecs)) {
            e.enable_tag<ecs::lorry_free>();
        }
        auto n = ecs_api::count<ecs::lorry_willremove>(w.ecs);
        if (n > 0) {
            updateRemoveLorry(w, n);
        }
        for (auto& e : ecs_api::select<ecs::lorry, ecs::lorry_removed(absent)>(w.ecs)) {
            lorryUpdate(e.get<ecs::lorry>(), *this, ti);
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
    lorryid& network::LorryInRoad(uint32_t index) {
        return straightLorry[index];
    }
    map_coord network::LorryInCoord(uint32_t index) const {
        return straightCoord[index];
    }
}
