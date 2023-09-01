#pragma once

#include "roadnet/type.h"

struct airport_berth {
    uint8_t x;
    uint8_t y;
    uint8_t slot;
    bool operator==(const airport_berth& rhs) const {
        return x == rhs.x && y == rhs.y && slot == rhs.slot;
    }
};
