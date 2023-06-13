#pragma once

#include "roadnet/type.h"
#include <utility>

struct world;
struct lua_State;

namespace roadnet {
    class network;
    struct road_coord;
    struct lorry {
        enum class status: uint8_t {
            normal,
            error,
            fatal,
        };
        void init(world& w, uint16_t classid);
        void entry(roadtype type);
        void go(straightid ending, uint16_t item_classid, uint16_t item_amount);
        void reset(world& w);
        void update(network& w, uint64_t ti);
        bool next_direction(network& w, straightid C, direction& dir);
        bool ready();
        std::pair<uint8_t, uint8_t> get_progress() const { return {progress, maxprogress}; }
        uint16_t get_item_amount() const { return item_amount; }
        uint16_t get_classid() const { return classid; }
        std::pair<uint16_t, uint16_t> get_item() const { return {item_classid, item_amount}; }
    private:
        straightid ending;
        uint16_t classid;
        uint16_t item_classid;
        uint16_t item_amount;
        uint8_t progress;
        uint8_t maxprogress;
        uint8_t time;
        enum status status;
    };
}
