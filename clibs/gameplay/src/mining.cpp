#pragma once

#include <map>
#include <vector>
#include <stdint.h>
#include <assert.h>

struct vs_size {
    uint8_t x;
    uint8_t y;
    auto operator <=>(const vs_size& o) const = default;
};

struct mining_network {
    struct grid {
        uint16_t count;
    };
    struct navvy {
        std::vector<uint16_t> id;
        uint16_t next;
    };
    std::vector<grid>  grids;
    std::vector<navvy> navvies;

    uint16_t addgrid(uint16_t count);
    uint16_t addnavvy(const std::vector<uint16_t>& ids);
    bool     dig(uint16_t navvy_id);
};

uint16_t mining_network::addgrid(uint16_t count) {
    size_t n = grids.size();
    assert(n <= 0xFFFF);
    grids.emplace_back(count);
    return (uint16_t)n;
}

uint16_t mining_network::addnavvy(const std::vector<uint16_t>& ids) {
    size_t n = navvies.size();
    assert(n <= 0xFFFF);
    navvies.emplace_back(ids, 0);
    return (uint16_t)n;
}

bool mining_network::dig(uint16_t navvy_id) {
    auto& ny = navvies[navvy_id];
    for (;;) {
        if (ny.id.size() == 0) {
            return false;
        }
        auto& grid = grids[ny.id[ny.next]];
        if (grid.count != 0) {
            grid.count--;
            ny.next = (ny.next+1) % ny.id.size();
            return true;
        }
        ny.id.erase(ny.id.begin() + ny.next);
    }
}

struct mining_world {
    struct mapgrid {
        uint16_t item;
        uint16_t count;
        uint16_t id = 0xFFFF;
    };
    std::map<vs_size, mapgrid> map;
    std::map<uint16_t, mining_network> networks;

    uint16_t addnavvy(uint16_t item, vs_size position, vs_size area);
};

uint16_t mining_world::addnavvy(uint16_t item, vs_size position, vs_size area) {
    std::vector<uint16_t> ids;
    auto& network = networks[item];
    for (int w = 0; w < area.x; ++w) {
        for (int h = 0; h < area.y; ++h) {
            vs_size s = {
                (uint8_t)std::min(position.x + w, 255),
                (uint8_t)std::min(position.y + h, 255)
            };
            auto it = map.find(s);
            if (it != map.end()) {
                mapgrid& grid = it->second;
                if (grid.item == item) {
                    if (grid.id == 0xFFFF) {
                        grid.id = network.addgrid(grid.count);
                    }
                    ids.emplace_back(grid.id);
                }
            }
        }
    }
    return network.addnavvy(ids);
}
