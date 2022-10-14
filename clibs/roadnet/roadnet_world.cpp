#include "roadnet_world.h"
#include <assert.h>

namespace roadnet {
    template <typename T, typename F>
    void ary_call(world& w, uint64_t ti, T& ary, F func) {
        size_t N = ary.size();
        for (size_t i = 0; i < N; ++i) {
            (ary[i].*func)(w, ti);
        }
    }
    void world::update(uint64_t ti) {
        ary_call(*this, ti, lorryVec, &lorry::update);
        ary_call(*this, ti, crossAry, &road::crossroad::update);
        ary_call(*this, ti, straightAry, &road::straight::update);
    }
    basic_road& world::Road(roadid id) {
        assert(id != roadid::invalid());
        if (id.cross) {
            return crossAry[id.id];
        }
        return straightAry[id.id];
    }
    lorryid& world::LorryInRoad(uint32_t index) {
        return lorryAry[index];
    }
    lorry& world::Lorry(lorryid id) {
        assert(id.id < lorryVec.size());
        return lorryVec[id.id];
    }
    endpointid& world::EndpointInRoad(uint32_t index) {
        return endpointAry[index];
    }
    endpoint& world::Endpoint(endpointid id) {
        assert(id.id < endpointVec.size());
        return endpointVec[id.id];
    }
}
