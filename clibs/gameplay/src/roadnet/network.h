#pragma once

#include <stdint.h>
#include "roadnet/road_cross.h"
#include "roadnet/road_straight.h"
#include "util/component.h"
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
        bool      vaild;
        direction direction;
        uint16_t  distance;
    };
    static_assert(sizeof(route_value) == sizeof(uint32_t));

    using lorry_entity = ecs::entity<component::lorry>;

    class network {
    public:
        network() = default;
        void             refresh(world& w, bool check);
        void             build(world& w);
        lorryid          createLorry(world& w, uint16_t classid);
        void             destroyLorry(world& w, lorry_entity& l);
        void             update(world& w, uint64_t ti);
        void             updateRemoveLorry(world& w, size_t n);
        road::straight&  StraightRoad(straightid id);
        road::cross&     CrossRoad(crossid id);
        component::lorry&      Lorry(world& w, lorryid id);
        lorry_entity     LorryEntity(world& w, component::lorry& lorry);
        lorryid&         LorryInRoad(uint32_t index);
        map_coord        LorryInCoord(uint32_t index) const;
        lorryid          getLorryId(component::lorry& l);

        dynarray<road::cross>           crossAry;
        dynarray<road::straight>        straightAry;
        dynarray<lorryid>               straightLorry;
        dynarray<map_coord>             straightCoord;
        component::lorry*                     lorryAry;
        flatmap<route_key, route_value> routeCached;
    };
}
