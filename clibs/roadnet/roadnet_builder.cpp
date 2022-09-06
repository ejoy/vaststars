#include "roadnet_builder.h"
#include <assert.h>
#include <stdint.h>
#include <memory.h>
#include <vector>
#include <set>

namespace roadnet {

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

    builder::builder() {
        memset(map, 0, sizeof(map));
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

    static constexpr bool isValidRoadType(uint8_t m, RoadType t) {
        if (t < 16) {
            // cross
            return m & ((1 << (t & 0x03)) | (1 << ((t >> 2) & 0x03)));
        }
        else {
            // in / out
            return m & (1 << (t & 0x03));
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

    static constexpr direction nextDirection(uint8_t m, direction dir) {
        switch (m) {
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
            default: break;
            }
            break;
        case mask(L'v'):
            switch (dir) {
            case direction::b: return direction::t;
            default: break;
            }
            break;
        case mask(L'<'):
            switch (dir) {
            case direction::l: return direction::r;
            default: break;
            }
            break;
        case mask(L'^'):
            switch (dir) {
            case direction::t: return direction::b;
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
        default: break;
        }
        assert(false);
        return direction::n;
    }

    static constexpr direction straightDirection(uint8_t m, uint8_t z) {
        switch (m) {
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
                ? direction::l
                : direction::b
                ;
        case mask(L'╝'):
            return (z & 0x10)
                ? direction::t
                : direction::l
                ;
        default: break;
        }
        return direction::n;
    }

    struct NeighborResult {
        loction   l;
        direction dir;
        uint16_t  n;
    };
    static constexpr NeighborResult findNeighbor(const uint8_t map[256][256], loction l, direction dir) {
        uint16_t n = 0;
        for (;;) {
            l = move(l, dir);
            uint8_t m = map[l.y][l.x];
            if (isCross(m)) {
                break;
            }
            dir = nextDirection(m, dir);
            n++;
        }
        return {l, dir, n};
    }
    static constexpr NeighborResult findNeighbor2(const uint8_t map[256][256], loction l, direction dir) {
        uint8_t m = map[l.y][l.x];
        auto r = findNeighbor(map, l, straightDirection(m, 0));
        if (r.dir == dir) {
            return r;
        }
        return findNeighbor(map, l, straightDirection(m, 0x10));
    }
    static constexpr std::optional<NeighborResult> moveToNeighbor(const uint8_t map[256][256], loction l, direction dir, uint16_t n) {
        for (uint16_t i = 0; ; ++i) {
            l = move(l, dir);
            uint8_t m = map[l.y][l.x];
            if (isCross(m)) {
                return std::nullopt;
            }
            if (i >= n) {
                return NeighborResult {l, dir, n};
            }
            dir = nextDirection(m, dir);
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

    void builder::loadMap(world& w, const std::map<loction, uint8_t>& mapData) {
        for (auto& [l, v] : mapData) {
             map[l.y][l.x] = v;
        }

        uint16_t genCrossId = 0;
        uint16_t genStraightId = 0;
        uint32_t genLorryOffset = 0;

        for (size_t i = 0; i < 256; ++i) {
            for (size_t j = 0; j < 256; ++j) {
                if (isCross(map[j][i])) {
                    roadid  id  { true, genCrossId++ };
                    loction loc {(uint8_t)i, (uint8_t)j};
                    crossMap.emplace(loc, id);
                    crossMapR.emplace(id, loc);
                }
            }
        }

        w.crossAry.reset(genCrossId);
        for (auto const& [loc, id]: crossMap) {
            road::crossroad& crossroad = w.crossAry[id.id];
            uint8_t m = map[loc.y][loc.x];

            for (uint8_t i = 0; i < 4; ++i) {
                direction dir = (direction)i;
                if (m & (1 << i) && !crossroad.hasNeighbor(dir)) {
                    auto result = findNeighbor(map, loc, dir);
                    roadid neighbor_id = crossMap[result.l];
                    road::crossroad& neighbor = w.crossAry[neighbor_id.id];
                    if (isRealNeighbor(loc, result.l)) {
                        crossroad.setNeighbor(dir, neighbor_id);
                        neighbor.setNeighbor(reverse(result.dir), id);
                    }
                    else if (loc == result.l) {
                        straightData& straight = straightVec.emplace_back(
                            genStraightId++,
                            result.n,
                            loc,
                            dir,
                            dir,
                            id
                        );
                        crossroad.setNeighbor(dir, {false, straight.id});
                    }
                    else {
                        straightData& straight1 = straightVec.emplace_back(
                            genStraightId++,
                            result.n,
                            loc,
                            dir,
                            reverse(result.dir),
                            neighbor_id
                        );
                        crossroad.setNeighbor(dir, {false, straight1.id});

                        straightData& straight2 = straightVec.emplace_back(
                            genStraightId++,
                            result.n,
                            result.l,
                            reverse(result.dir),
                            dir,
                            id
                        );
                        neighbor.setNeighbor(reverse(result.dir), {false, straight2.id});
                    }
                }
            }
        }

        w.straightAry.reset(genStraightId);
        for (auto& data: straightVec) {
            road::straight& straight = w.straightAry[data.id];
            straight.init(data.len * road::straight::N, data.finish_dir);
            straight.setLorryOffset(genLorryOffset);
            straight.setNeighbor(data.neighbor);
            genLorryOffset += data.len * road::straight::N;
        }

        w.lorryAry.reset(genLorryOffset);
    }

    lineid builder::addLine(world& w, std::string_view strpath) {
        line line;
        line.path.reset(strpath.size());
        for (size_t i = 0; i < strpath.size(); ++i) {
            switch (strpath[i]) {
            case L'L': line.path[i] = direction::l; break;
            case L'T': line.path[i] = direction::t; break;
            case L'R': line.path[i] = direction::r; break;
            case L'B': line.path[i] = direction::b; break;
            default:   line.path[i] = direction::n; break;
            }
        }
        lineid lineId((uint16_t)w.lineVec.size());
        w.lineVec.emplace_back(std::move(line));
        return lineId;
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

    static lorryid createLorry(world& w, lineid lineId, uint8_t lineIdx) {
        lorryid lorryId((uint16_t)w.lorryVec.size());
        roadnet::lorry lorry;
        lorry.initLine(lineId, lineIdx);
        w.lorryVec.push_back(lorry);
        return lorryId;
    }

    lorryid builder::addLorry(world& w, lineid lineId, uint8_t lineIdx, road_coord where) {
        line& line = w.lineVec[lineId.id];
        if (lineIdx >= line.path.size()) {
            return lorryid::invalid();
        }
        if (w.lorryVec.size() >= (size_t)(uint16_t)-1) {
            return lorryid::invalid();
        }
        if (!where) {
            return lorryid::invalid();
        }
        if (where.id.cross) {
            road::crossroad& road = w.crossAry[where.id.id];
            if (road.hasLorry(w, where.offset)) {
                return lorryid::invalid();
            }
            lorryid lorryId = createLorry(w, lineId, lineIdx);
            road.addLorry(w, lorryId, where.offset);
            return lorryId;
        }
        else {
            road::straight& road = w.straightAry[where.id.id];
            if (road.hasLorry(w, where.offset)) {
                return lorryid::invalid();
            }
            lorryid lorryId = createLorry(w, lineId, lineIdx);
            road.addLorry(w, lorryId, where.offset);
            return lorryId;
        }
    }

    lorryid builder::addLorry(world& w, lineid lineId, uint8_t lineIdx, loction l, uint8_t z) {
        line&  line = w.lineVec[lineId.id];
        size_t N    = line.path.size();
        if (lineIdx >= N) {
            return lorryid::invalid();
        }
        direction from = line.path[(lineIdx+N-1) % N];
        direction to   = line.path[lineIdx];
        auto rc = coordConvert(w, l, from, to, z);
        if (!rc) {
            return lorryid::invalid();
        }
        return addLorry(w, lineId, lineIdx, rc);
    }

    roadid builder::findCrossRoad(loction l) {
        auto iter = crossMap.find(l);
        if (iter != crossMap.end()) {
            return iter->second;
        }
        return roadid::invalid();
    }

    std::optional<loction> builder::whereCrossRoad(roadid id) {
        auto iter = crossMapR.find(id);
        if (iter != crossMapR.end()) {
            return iter->second;
        }
        return std::nullopt;
    }

    road_coord builder::coordConvert(world& w, loction l, direction from, direction to, uint8_t z) {
        if (auto cross = findCrossRoad(l); cross) {
            if (z == 0) {
                RoadType z = RoadType(0x10 | (uint8_t)from);
                return {cross, z};
            }
            RoadType z = RoadType(((uint8_t)from << 2) | (uint8_t)to);
            if (!isValidRoadType(map[l.y][l.x], z)) {
                return road_coord::invalid();
            }
            return {cross, z};
        }
        direction dir = reverse(from);
        auto result = findNeighbor2(map, l, dir);
        if (auto cross = findCrossRoad(result.l); cross) {
            roadid id = w.crossAry[cross.id].neighbor[(uint8_t)reverse(result.dir)];
            assert(id);
            uint16_t n = road::straight::N * result.n + z;
            uint16_t offset = w.straightAry[id.id].len - n - 1;
            return {id, offset};
        }
        return road_coord::invalid();
    }

    road_coord builder::coordConvert(world& w, map_coord mc) {
        if (auto cross = findCrossRoad(mc); cross) {
            if (!isValidRoadType(map[mc.y][mc.x], RoadType(mc.z))) {
                return road_coord::invalid();
            }
            return {cross, mc.z};
        }

        direction dir = straightDirection(map[mc.y][mc.x], mc.z);
        if (dir == direction::n) {
            return road_coord::invalid();
        }
        auto result = findNeighbor(map, mc, dir);
        if (auto cross = findCrossRoad(result.l); cross) {
            roadid id = w.crossAry[cross.id].neighbor[(uint8_t)reverse(result.dir)];
            assert(id);
            uint16_t n = road::straight::N * result.n + (mc.z & 0x0Fu);
            uint16_t offset = w.straightAry[id.id].len - n - 1;
            return {id, offset};
        }
        return road_coord::invalid();
    }

    map_coord builder::coordConvert(world& w, road_coord rc) {
        if (rc.id.cross) {
            if (auto loc = whereCrossRoad(rc.id); loc) {
                return {loc->x, loc->y, (uint8_t)rc.offset};
            }
            return map_coord::invalid();
        }
        if (rc.id.id >= straightVec.size()) {
            return map_coord::invalid();
        }
        auto& straight = straightVec[rc.id.id];
        uint16_t n = road::straight::N * straight.len - rc.offset - 1;
        if (auto res = moveToNeighbor(map, straight.loc, straight.start_dir, n / road::straight::N); res) {
            bool z = reverse(res->dir) == straightDirection(map[res->l.y][res->l.x], 0);
            return {res->l.x, res->l.y, (uint8_t)((n % road::straight::N) + (z? 0x00u: 0x10u))};
        }
        return map_coord::invalid();
    }
}
