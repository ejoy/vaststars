#include "core/mining.h"
#include <assert.h>

void mining_network::addgrid(mining_position pt, uint16_t count) {
    auto iter = map.find(pt);
    if (iter == map.end()) {
        size_t n = grids.size();
        assert(n <= 0xFFFF);
        grids.emplace_back(count);
        map.emplace(pt, (gridid)n);
    }
    else {
        grids[iter->second] = count;
    }
}

bool mining_network::dig(uint16_t navvy_id) {
    auto& ny = navvies[navvy_id];
    for (;;) {
        if (ny.id.size() == 0) {
            return false;
        }
        auto& grid = grids[ny.id[ny.next]];
        if (grid != 0) {
            grid--;
            ny.next = (ny.next+1) % ny.id.size();
            return true;
        }
        ny.id.erase(ny.id.begin() + ny.next);
    }
}

uint16_t mining_network::addnavvy(mining_position pt, mining_position area) {
    std::vector<uint16_t> ids;
    for (int w = 0; w < area.x; ++w) {
        for (int h = 0; h < area.y; ++h) {
            mining_position s = {
                (uint8_t)std::min(pt.x + w, 255),
                (uint8_t)std::min(pt.y + h, 255)
            };
            auto it = map.find(s);
            if (it != map.end()) {
                ids.emplace_back(it->second);
            }
        }
    }
    size_t n = navvies.size();
    assert(n <= 0xFFFF);
    navvies.emplace_back(ids, 0);
    return (uint16_t)n;
}

uint16_t mining_world::addnavvy(uint16_t item, mining_position pt, mining_position area) {
    auto& network = networks[item];
    return network.addnavvy(pt, area);
}
