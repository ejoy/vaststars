#pragma once

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    struct state {
        int volume;
        int flow;
        int multiple;
    };

    fluidflow();
    ~fluidflow();
    uint16_t build(struct fluid_box *box);
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
