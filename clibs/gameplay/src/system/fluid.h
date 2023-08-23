#pragma once

struct fluidflow_network;
struct fluid_box;
struct fluid_state;

struct fluidflow {
    fluidflow();
    ~fluidflow();
    uint16_t create_id();
    void remove_id(uint16_t id);
    bool build(uint16_t id, struct fluid_box *box);
    bool teardown(int id);
    bool connect(int from, int to, bool oneway);
    void dump();
    uint16_t size() const;
    bool index(int idx, fluid_state& state);
    bool query(int id, fluid_state& state);
    void set(int id, int fluid);
    void set(int id, int fluid, int user_multiple);
    void block(int id);
    void update();

    static constexpr int multiple = 100;
    fluidflow_network* network;
    uint16_t maxid = 0;
    std::vector<uint16_t> freelist;
};
