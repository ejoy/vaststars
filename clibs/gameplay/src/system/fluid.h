#pragma once

extern "C" {
#include "../fluidflow.h"
}

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    struct state {
        int multiple;
        fluid_state state;
    };

    fluidflow();
    ~fluidflow();
    uint16_t build(struct fluid_box *box);
    bool restore(uint16_t id, struct fluid_box *box);
    bool teardown(int id);
    bool connect(int from, int to, bool oneway);
    void dump();
    bool query(int id, state& state);
    void set(int id, int fluid);
    void block(int id);
    void update();

    fluidflow_network* network;
    uint16_t maxid = 0;
    static const int multiple = 100;
    std::vector<uint16_t> freelist;
};
