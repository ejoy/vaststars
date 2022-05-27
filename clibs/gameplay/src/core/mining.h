#pragma once

#include <stdint.h>
#include <map>
#include <vector>

struct mining_position {
    uint8_t x;
    uint8_t y;
    auto operator <=>(const mining_position& o) const = default;
};

struct mining_network {
    using gridid = uint16_t;
    struct navvy {
        std::vector<gridid> id;
        gridid next;
    };
    std::map<mining_position, gridid> map;
    std::vector<uint16_t>  grids;
    std::vector<navvy> navvies;

    void     addgrid(mining_position pt, uint16_t count);
    uint16_t addnavvy(mining_position pt, mining_position area);
    bool     dig(uint16_t navvy_id);
};

struct mining_world {
    std::map<uint16_t, mining_network> networks;
    uint16_t addnavvy(uint16_t item, mining_position pt, mining_position area);
};
