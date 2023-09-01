#pragma once

#include "util/component.h"
#include "system/building.h"
#include "flatmap.h"
#include <bee/nonstd/bit.h>
#include <vector>
#include <map>

struct airport {
    struct item_market {
        std::vector<airport_berth> supply;
        std::vector<airport_berth> demand;
        std::vector<airport_berth> transit;
        bool active() const {
            auto supply_n = supply.size();
            auto demand_n = demand.size();
            auto transit_n = transit.size();
            switch (transit_n) {
            case 0:
                return supply_n > 0 && demand_n > 0;
            case 1:
                return supply_n > 0 || demand_n > 0;
            default:
                return true;
            }
        }
    };
    std::map<uint16_t, item_market> market;
    airport_berth homeBerth;
    uint8_t width;
    uint8_t height;
    uint16_t prototype;
    ecs::capacitance* capacitance;
};
