#pragma once

#include "roadnet_world.h"
#include "roadnet_coord.h"
#include <map>
#include <optional>
#include <string_view>

namespace roadnet {

    struct routeKey {
        roadid from;
        roadid to;

        routeKey(roadid from, roadid to) : from(from), to(to) {}
        bool operator<(const routeKey& other) const {
            return from < other.from || (from == other.from && to < other.to);
        }
    };

    class builder {
    public:
        builder();
        void    loadMap(world& w, const std::map<loction, uint8_t>& mapData);
        lineid  addLine(world& w, std::string_view strpath);
        lorryid pushLorry(world& w, lineid lineId, road_coord starting, road_coord ending);

        road_coord coordConvert(world& w, map_coord  mc);
        map_coord  coordConvert(world& w, road_coord rc);

        std::map<routeKey, uint16_t> getRouteCost();
        std::optional<roadid> getPrevRoadId(roadid id);
        std::optional<roadid> getNextRoadId(roadid id);
        std::optional<direction> getRouteDir(roadid from, roadid to);

    private:
        uint8_t map[256][256];
        
        struct straightData {
            uint16_t  id;
            uint16_t  len;
            loction   loc;
            direction start_dir;
            direction finish_dir;
            roadid neighbor; // the next crossroad along this straight road
            straightData(uint16_t id, uint16_t len, loction loc, direction start_dir, direction finish_dir, roadid neighbor)
                : id(id)
                , len(len)
                , loc(loc)
                , start_dir(start_dir)
                , finish_dir(finish_dir)
                , neighbor(neighbor)
            {}
        };

        std::vector<straightData>    straightVec;
        std::map<loction, roadid>    crossMap;
        std::map<roadid, loction>    crossMapR;

        std::map<routeKey, uint16_t> routeCost;
        std::map<roadid, roadid> routePrev;
        std::map<roadid, roadid> routeNext;
        std::map<routeKey, direction> routeDir;

        roadid   findCrossRoad(loction l);
        std::optional<loction> whereCrossRoad(roadid id);
    };
}
