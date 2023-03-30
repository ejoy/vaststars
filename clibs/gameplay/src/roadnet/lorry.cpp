#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/bfs.h"
#include "core/world.h"
#include "util/prototype.h"

namespace roadnet {
    bool lorry::nextDirection(network& w, roadid C, direction& dir) {
        if (ending == roadid::invalid()) {
            return false;
        }
        return route(w, C, ending, dir);
    }
    void lorry::initTick(uint8_t v) {
        tick = v;
    }
    void lorry::update(network& w, uint64_t ti) {
        if (capacitance != 0) {
            --capacitance;
        }
        if (tick != 0) {
            --tick;
        }
    }
    bool lorry::ready() {
        return tick == 0;
    }
    void lorry::reset(world& w) {
    }
    void lorry::init(world& w, uint16_t classid) {
        auto capacitance = prototype::get<"capacitance">(w, classid);
        this->classid = classid;
        this->capacitance = capacitance;
        this->item_classid = 0;
        this->item_amount = 0;
    }
}
