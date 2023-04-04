#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/bfs.h"
#include "core/world.h"
#include "util/prototype.h"

namespace roadnet {
    void lorry::init(world& w, uint16_t classid) {
        //auto capacitance = prototype::get<"capacitance">(w, classid);
        this->classid = classid;
        this->item_classid = 0;
        this->item_amount = 0;
        this->status = status::normal;
    }
    void lorry::init_tick(uint8_t v) {
        tick = v;
    }
    void lorry::go(roadid ending, uint16_t item_classid, uint16_t item_amount) {
        this->status = status::normal;
        this->ending = ending;
        this->item_classid = item_classid;
        this->item_amount = item_amount;
    }
    void lorry::reset(world& w) {
    }
    void lorry::update(network& w, uint64_t ti) {
        if (tick != 0) {
            --tick;
        }
    }
    bool lorry::next_direction(network& w, roadid C, direction& dir) {
        if (status != status::normal) {
            return false;
        }
        if (route(w, C, ending, dir)) {
            return true;
        }
        status = status::error;
        return false;
    }
    bool lorry::ready() {
        if (status != status::normal) {
            return false;
        }
        return tick == 0;
    }
}
