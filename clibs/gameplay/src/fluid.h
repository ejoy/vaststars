#pragma once

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    enum class change_type {
        Import,
        Export,
    };

    struct connectinfo {
        int from;
        int to;
    };

    fluidflow();
    ~fluidflow();
    uint16_t build(struct fluid_box *box);
    int teardown(int id);
    bool connect(int* IDs, size_t n);
    void dump();
    fluid_state* query(int id, fluid_state* output);
    void change(int id, change_type type, int fluid);
    void block(int id);
    void update();

    fluidflow_network* network;
    uint16_t maxid = 0;
};
