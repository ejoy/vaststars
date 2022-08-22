#include "roadnet_world.h"
#include <assert.h>

namespace roadnet {
    template <typename T>
    static void ary_update(world& w, uint64_t ti, T& ary) {
        size_t N = ary.size();
        for (size_t i = 0; i < N; ++i) {
            ary[i].update(w, ti);
        }
    }
    void world::update(uint64_t ti) {
        marked = !marked;
        ary_update(*this, ti, crossAry);
        ary_update(*this, ti, straightAry);
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
    line& world::Line(lineid id) {
        assert(id.id < lineVec.size());
        return lineVec[id.id];
    }
}
