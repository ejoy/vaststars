#include "roadnet/network.h"
#include "roadnet/bfs.h"
#include <cassert>
#include <cstdio>

namespace roadnet {
    enum class MapRoad: uint8_t {
        Left       = 1 << 0,
        Top        = 1 << 1,
        Right      = 1 << 2,
        Bottom     = 1 << 3,
        Endpoint   = 1 << 4,
        NoLeftTurn = 1 << 5,
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

    static constexpr bool isValidCrossType(uint8_t m, cross_type t) {
        if ((uint8_t)t < 16) {
            // cross
            return m & ((1 << ((uint8_t)t & 0x03)) | (1 << (((uint8_t)t >> 2) & 0x03)));
        }
        else {
            // in / out
            return m & (1 << ((uint8_t)t & 0x03));
        }
    }

    static constexpr bool isCross(uint8_t m) {
        switch (m) {
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
            case direction::t: return direction::t;
            case direction::b: return direction::b;
            default: break;
            }
            break;
        case mask(L'═'):
            switch (dir) {
            case direction::l: return direction::l;
            case direction::r: return direction::r;
            default: break;
            }
            break;
        case mask(L'>'):
            switch (dir) {
            case direction::r: return direction::l;
            case direction::l: return direction::l;
            default: break;
            }
            break;
        case mask(L'v'):
            switch (dir) {
            case direction::b: return direction::t;
            case direction::t: return direction::t;
            default: break;
            }
            break;
        case mask(L'<'):
            switch (dir) {
            case direction::l: return direction::r;
            case direction::r: return direction::r;
            default: break;
            }
            break;
        case mask(L'^'):
            switch (dir) {
            case direction::t: return direction::b;
            case direction::b: return direction::b;
            default: break;
            }
            break;
        case mask(L'╔'):
            switch (dir) {
            case direction::l: return direction::b;
            case direction::t: return direction::r;
            default: break;
            }
            break;
        case mask(L'╚'):
            switch (dir) {
            case direction::l: return direction::t;
            case direction::b: return direction::r;
            default: break;
            }
            break;
        case mask(L'╗'):
            switch (dir) {
            case direction::r: return direction::b;
            case direction::t: return direction::l;
            default: break;
            }
            break;
        case mask(L'╝'):
            switch (dir) {
            case direction::r: return direction::t;
            case direction::b: return direction::l;
            default: break;
            }
            break;
        case mask(L'╠'):
        case mask(L'╦'):
        case mask(L'╬'):
        case mask(L'╩'):
        case mask(L'╣'):
            return dir;
            break;
        }
        printf("Invalid road type: (%d,%d) %d\n", l.x, l.y, m);
        assert(false);
        return direction::n;
    }

    static constexpr direction straightDirection(uint8_t m, uint8_t z) {
        switch (m & 0xF) {
        case mask(L'║'):
            return (z & 0x10)
                ? direction::t
                : direction::b
                ;
        case mask(L'═'):
            return (z & 0x10)
                ? direction::r
                : direction::l
                ;
        case mask(L'>'):
            return direction::l;
        case mask(L'v'):
            return direction::t;
        case mask(L'<'):
            return direction::r;
        case mask(L'^'):
            return direction::b;
        case mask(L'╔'):
            return (z & 0x10)
                ? direction::r
                : direction::b
                ;
        case mask(L'╚'):
            return (z & 0x10)
                ? direction::t
                : direction::r
                ;
        case mask(L'╗'):
            return (z & 0x10)
                ? direction::b
                : direction::l
                ;
        case mask(L'╝'):
            return (z & 0x10)
                ? direction::l
                : direction::t
                ;
        default: break;
        }
        return direction::n;
    }

    static uint8_t getMapBits(const std::map<loction, uint8_t>& map, const loction& l) {
        auto iter = map.find(l);
        return (iter != map.end()) ? iter->second : 0;
    }

    struct NeighborResult {
        loction   l;
        direction dir;
        uint16_t  n;
    };
    static NeighborResult findNeighbor(const std::map<loction, uint8_t>& map, loction l, direction dir) {
        uint16_t n = 0;
        loction ln = l;

        uint8_t cm = getMapBits(map, ln);
        assert(cm != 0);
        direction nd = next_direction(ln, cm, dir);

        for (;;) {
            ln = move(ln, nd);
            uint8_t m = getMapBits(map, ln);
            if (isCross(m)) {
                break;
            }
            if (m & MapRoad::Endpoint) {
                break;
            }
            if (ln == l && nd == dir) {
                break;
            }
            nd = next_direction(ln, m, nd);
            n++;
        }
        return {ln, nd, n};
    }
    static std::optional<NeighborResult> moveToNeighbor(const std::map<loction, uint8_t>& map, loction l, direction dir, uint16_t n) {
        for (uint16_t i = 0; ; ++i) {
            l = move(l, dir);
            uint8_t m = getMapBits(map, l);
            if (isCross(m)) {
                return std::nullopt;
            }
            if (i >= n) {
                return NeighborResult {l, dir, n};
            }
            dir = next_direction(l, m, dir);
        }
    }

    static constexpr bool isRealNeighbor(loction a, loction b) {
        if (a.x == b.x) {
            return abs(a.y - b.y) == 1;
        }
        if (a.y == b.y) {
            return abs(a.x - b.x) == 1;
        }
        return false;
    }

    static constexpr direction getDirection(loction start, loction end) {
        assert(start != end);
        assert((start.x == end.x) || (start.y == end.y));
        if (start.y == end.y) {
            return start.x < end.x
                ? direction::r
                : direction::l
                ;
        }
        return start.y < end.y
            ? direction::b
            : direction::t
            ;
    }

    std::map<loction, uint8_t> network::getMap() const {
        return map;
    }

    void network::updateMap(const std::map<loction, uint8_t>& mapData) {
        dynarray<std::optional<map_coord>> lorryWhere;
        lorryWhere.reset(lorryVec.size());
        for (uint16_t i = 0; i < crossAry.size(); ++i) {
            auto const& cross = crossAry[i];
            for (size_t j = 0; j < 2; ++j) {
                if (cross.cross_lorry[j]) {
                    auto coord = coordConvert(road_coord {roadid {roadtype::cross, i}, cross.cross_status[j]});
                    lorryWhere[cross.cross_lorry[j].id] = coord;
                }
            }
        }
        uint16_t straight = 0;
        for (size_t i = 0; i < lorryAry.size(); ++i) {
            auto id = lorryAry[i];
            if (id) {
                while (i >= straightAry[straight].lorryOffset + straightAry[straight].len) {
                    straight++;
                }
                auto coord = coordConvert(road_coord {roadid {roadtype::straight, straight}, straight_type::straight, (uint16_t)(i - straightAry[straight].lorryOffset)});
                lorryWhere[id.id] = coord;
            }
        }

        map = mapData;
        uint32_t genLorryOffset = reloadMap();
        lorryAry.reset(genLorryOffset);

        lorryVec.clear();
        lorryFreeList.clear();
    }

    void network::setEndpoint(loction loc, direction a, direction b, uint16_t straightId) {
        auto na = findNeighbor(map, loc, a);
        auto nb = findNeighbor(map, loc, b);
        if (na.l.y == nb.l.y) {
            assert(loc.y != na.l.y);
            assert(na.l.x != nb.l.x);
            bool left_handled = loc.y > na.l.y;
            bool a_less_b = na.l.x < nb.l.x;
            if (left_handled != a_less_b) {
                std::swap(na, nb);
                std::swap(a, b);
            }
        }
        else if (na.l.x == nb.l.x) {
            assert(loc.x != nb.l.x);
            assert(na.l.y != nb.l.y);
            bool left_handled = loc.x < nb.l.x;
            bool a_less_b = na.l.y < nb.l.y;
            if (left_handled != a_less_b) {
                std::swap(na, nb);
                std::swap(a, b);
            }
        }
        else {
            assert(false);
        }
        assert(na.n > 0);

        endpointid id { (uint16_t)endpointVec.size() };
        auto& ep = endpointVec.emplace_back();
        endpointMap.emplace(loc, id);
        auto cross_a = crossMap[na.l];
        auto cross_b = crossMap[nb.l];

        straightData& straight1 = straightVec.emplace_back(
            roadid {roadtype::straight, straightId},
            nb.n + 1,
            nb.l,
            reverse(nb.dir),
            reverse(b),
            roadid::invalid()
        );
        CrossRoad(cross_b).setNeighbor(reverse(nb.dir), straight1.id);
        ep.rev_neighbor = straight1.id;
        straightData& straight2 = straightVec.emplace_back(
            roadid {roadtype::straight, ++straightId},
            na.n,
            loc,
            a,
            na.dir,
            cross_a
        );
        CrossRoad(cross_a).setRevNeighbor(na.dir, straight2.id);
        ep.neighbor = straight2.id;
    }

    uint32_t network::reloadMap() {
        straightVec.clear();
        crossMap.clear();
        crossMapR.clear();
        endpointVec.clear();
        endpointMap.clear();
        routeMap.clear();

        uint16_t genCrossId = 0;
        uint16_t genStraightId = 0;
        uint32_t genLorryOffset = 0;

        for (auto& [loc, m] : map) {
            if (isCross(m)) {
                roadid id { roadtype::cross, genCrossId++ };
                crossMap.emplace(loc, id);
                crossMapR.emplace(id, loc);
            }
        }

        if (crossMap.size() <= 0) {
            return 0;
        }

        crossAry.reset(genCrossId);
        for (auto const& [loc, id]: crossMap) {
            road::crossroad& crossroad = CrossRoad(id);
            uint8_t m = getMapBits(map, loc);
            if (m & MapRoad::NoLeftTurn) {
                crossroad.ban = road::NoLeftTurn;
            }
    
            for (uint8_t i = 0; i < 4; ++i) {
                direction dir = (direction)i;
                if (m & (1 << i) && !crossroad.hasNeighbor(dir)) {
                    auto result = findNeighbor(map, loc, dir);

                    if (loc == result.l) {
                        straightData& straight = straightVec.emplace_back(
                            roadid {roadtype::straight, genStraightId++},
                            result.n,
                            loc,
                            dir,
                            dir,
                            id
                        );
                        crossroad.setNeighbor(dir, straight.id);
                    }
                    else {
                        auto neighbor_m = getMapBits(map, result.l);
                        if (!(neighbor_m & MapRoad::Endpoint)) {
                            roadid neighbor_id = crossMap[result.l];
                            road::crossroad& neighbor = CrossRoad(neighbor_id);
                            straightData& straight1 = straightVec.emplace_back(
                                roadid {roadtype::straight, genStraightId++},
                                result.n,
                                loc,
                                dir,
                                reverse(result.dir),
                                neighbor_id
                            );
                            crossroad.setNeighbor(dir, straight1.id);
                            neighbor.setRevNeighbor(reverse(result.dir), straight1.id);
                            straightData& straight2 = straightVec.emplace_back(
                                roadid {roadtype::straight, genStraightId++},
                                result.n,
                                result.l,
                                reverse(result.dir),
                                dir,
                                id
                            );
                            neighbor.setNeighbor(reverse(result.dir), straight2.id);
                            crossroad.setRevNeighbor(dir, straight2.id);
                        }
                    }
                }
            }
        }

        for (auto& [loc, m] : map) {
            if (m & MapRoad::Endpoint) {
                auto rawm = m & 0xF;
                switch (rawm) {
                case mask(L'║'): setEndpoint(loc, direction::t, direction::b, genStraightId); break;
                case mask(L'═'): setEndpoint(loc, direction::l, direction::r, genStraightId); break;
                case mask(L'╔'): setEndpoint(loc, direction::r, direction::b, genStraightId); break;
                case mask(L'╚'): setEndpoint(loc, direction::r, direction::t, genStraightId); break;
                case mask(L'╗'): setEndpoint(loc, direction::l, direction::b, genStraightId); break;
                case mask(L'╝'): setEndpoint(loc, direction::l, direction::t, genStraightId); break;
                default: assert(false); break;
                }
                genStraightId += 2;
            }
        }

        straightAry.reset(genStraightId);
        for (auto& data: straightVec) {
            road::straight& straight = StraightRoad(data.id);
            size_t length = data.len * road::straight::N + 1;
            straight.init(data.id, (uint16_t)length, data.finish_dir, data.neighbor);
            straight.setLorryOffset(genLorryOffset);
            genLorryOffset += (uint16_t)length;
        }

        return genLorryOffset;
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
        lorryFreeList.push_back(id);
    }
    void network::update(uint64_t ti) {
        ary_call(*this, ti, lorryVec, &lorry::update);
        ary_call(*this, ti, crossAry, &road::crossroad::update);
        ary_call(*this, ti, straightAry, &road::straight::update);
    }
    road::straight& network::StraightRoad(roadid id) {
        assert(id != roadid::invalid());
        assert(id.get_type() == roadtype::straight);
        return straightAry[id.get_index()];
    }
    road::crossroad& network::CrossRoad(roadid id) {
        assert(id != roadid::invalid());
        assert(id.get_type() == roadtype::cross);
        return crossAry[id.get_index()];
    }
    lorryid& network::LorryInRoad(uint32_t index) {
        return lorryAry[index];
    }
    lorry& network::Lorry(lorryid id) {
        assert(id.id < lorryVec.size());
        return lorryVec[id.id];
    }
    road::endpoint& network::Endpoint(endpointid id) {
        assert(id.id < endpointVec.size());
        return endpointVec[id.id];
    }
    endpointid network::EndpointId(loction loc) {
        auto it = endpointMap.find(loc);
        if (it != endpointMap.end()) {
            return it->second;
        }
        return endpointid::invalid();
    }
    roadid network::findCrossRoad(loction l) {
        auto iter = crossMap.find(l);
        if (iter != crossMap.end()) {
            return iter->second;
        }
        return roadid::invalid();
    }

    std::optional<loction> network::whereCrossRoad(roadid id) {
        auto iter = crossMapR.find(id);
        if (iter != crossMapR.end()) {
            return iter->second;
        }
        return std::nullopt;
    }

    std::optional<road_coord> network::coordConvert(map_coord mc) {
        if (auto cross = findCrossRoad(mc); cross) {
            if (!isValidCrossType(getMapBits(map, loction{mc.x, mc.y}), cross_type(mc.z))) {
                return std::nullopt;
            }
            assert(cross.get_type() == roadtype::cross);
            return road_coord {cross, (cross_type)mc.z};
        }
 
        direction dir = straightDirection(getMapBits(map, loction{mc.x, mc.y}), mc.z);
        if (dir == direction::n) {
            return std::nullopt;
        }
        auto result = findNeighbor(map, mc, dir);
        if (auto cross = findCrossRoad(result.l); cross) {
            roadid id = CrossRoad(cross).neighbor[(uint8_t)reverse(result.dir)];
            assert(id && id.get_type() == roadtype::straight);
            uint16_t n = road::straight::N * result.n + (mc.z & 0x0Fu);
            uint16_t offset = StraightRoad(id).len - n - 1;
            return road_coord {id, straight_type::straight, offset};
        }
        return std::nullopt;
    }

    std::optional<map_coord> network::coordConvert(road_coord rc) {
        if (rc.id.get_type() == roadtype::cross) {
            if (auto loc = whereCrossRoad(rc.id); loc) {
                return map_coord {loc->x, loc->y, (uint8_t)rc.offset};
            }
            return std::nullopt;
        }
        if (rc.id.get_index() >= straightVec.size()) {
            return std::nullopt;
        }
        auto& straight = straightVec[rc.id.get_index()];
        uint16_t n = road::straight::N * straight.len + 1 - rc.offset - 1;
        uint8_t wait = 0x00;
        if (rc.offset == 0) {
            n -= 1;
            wait = 0x01;
        }

        if (auto res = moveToNeighbor(map, straight.loc, straight.start_dir, n / road::straight::N); res) {
            auto m = getMapBits(map, res->l);
            auto z = 0x00;
            if (m & MapRoad::Endpoint) {
                z = straight.start_dir == straight.finish_dir ? 0x00 : 0x01;
            }
            else {
                z = reverse(res->dir) == straightDirection(m, 0) ? 0x00 : 0x01;
            }
            return map_coord {res->l.x, res->l.y, (uint8_t)((wait << 5) | (z << 4) | (n % road::straight::N))};
        }
        return std::nullopt;
    }
}
