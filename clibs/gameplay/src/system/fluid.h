#pragma once

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    fluidflow();
    ~fluidflow();
    uint16_t build(struct fluid_box *box);
    bool rebuild(uint16_t id);
    bool restore(uint16_t id, struct fluid_box *box);
    bool teardown(int id);
    bool connect(int from, int to, bool oneway);
    void dump();
    bool query(int id, fluid_state& state);
    void set(int id, int fluid);
    void set(int id, int fluid, int user_multiple);
    void block(int id);
    void update();

    fluidflow_network* network;
    uint16_t maxid = 0;
    static constexpr int multiple = 100;
    std::vector<uint16_t> freelist;
};
