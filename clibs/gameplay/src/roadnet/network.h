#pragma once

#include <stdint.h>
#include "roadnet/road_cross.h"
#include "roadnet/road_straight.h"
#include "roadnet/endpoint.h"
#include "roadnet/lorry.h"
#include "util/dynarray.h"
#include "flatmap.h"

struct world;

namespace roadnet {
    struct route_key {
        straightid S;
        straightid E;
        bool operator==(const route_key& rhs) const {
            return S == rhs.S && E == rhs.E;
        }
    };
    struct route_value {
        uint16_t dir : 2;
        uint16_t n : 14;
    };

    using lorry_entity = ecs_api::entity<ecs::lorry, ecs::lorry_removed(ecs_api::flags::absent)>;

    class network {
    public:
        network() = default;
        void             init(world& w);
        void             refresh(world& w);
        void             rebuildMap(world& w, flatmap<loction, uint8_t> const& map);
        lorryid          createLorry(world& w, uint16_t classid);
        void             destroyLorry(world& w, lorry_entity& l);
        void             removeLorry(world& w, lorryid l);
        void             update(world& w, uint64_t ti);
        void             updateRemoveLorry(world& w, size_t n);
        road::straight&  StraightRoad(straightid id);
        road::cross&     CrossRoad(crossid id);
        ecs::lorry&      Lorry(world& w, lorryid id);
        lorryid&         LorryInRoad(uint32_t index);
        map_coord        LorryInCoord(uint32_t index) const;
        lorryid          getLorryId(ecs::lorry& l);

        dynarray<road::cross>           crossAry;
        dynarray<road::straight>        straightAry;
        dynarray<lorryid>               straightLorry;
        dynarray<map_coord>             straightCoord;
        ecs::lorry*                     lorryAry;
        flatmap<route_key, route_value> routeCached;
    };
}
