#pragma once

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    enum class change_type {
        Import,
        Export,
    };

    struct state {
        int volume;
        int flow;
        int multiple;
    };

    fluidflow();
    ~fluidflow();
    uint16_t build(struct fluid_box *box);
    int teardown(int id);
    bool connect(int* IDs, size_t n);
    void dump();
    bool query(int id, state& state);
    void change(int id, change_type type, int fluid);
    void block(int id);
    void update();

    fluidflow_network* network;
    uint16_t maxid = 0;
    static const int multiple = 100;
};
