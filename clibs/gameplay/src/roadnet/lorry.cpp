#include "roadnet/lorry.h"
#include "roadnet/network.h"
#include "roadnet/bfs.h"
#include "core/world.h"
#include "util/prototype.h"
#include <bee/nonstd/unreachable.h>

namespace roadnet {
    void lorry::init(world& w, uint16_t classid) {
        auto speed = prototype::get<"speed">(w, classid);
        this->classid = classid;
        this->item_classid = 0;
        this->item_amount = 0;
        this->status = status::normal;
        this->straightTime = 1000 / speed;
        this->crossTime = 1500 / speed;
    }
    void lorry::entry(roadtype type) {
        switch (type) {
        case roadtype::cross:
            maxprogress = progress = crossTime;
            break;
        case roadtype::straight:
            maxprogress = progress = straightTime;
            break;
        default:
            std::unreachable();
        }
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
        if (progress != 0) {
            --progress;
        }
    }
    bool lorry::next_direction(network& w, roadid C, direction& dir) {
        if (status != status::normal) {
            return false;
        }
        route_info info;
        if (route(w, C, ending, info)) {
            dir = (direction)info.dir;
            return true;
        }
        status = status::error;
        return false;
    }
    bool lorry::ready() {
        if (status != status::normal) {
            return false;
        }
        return progress == 0;
    }
}
