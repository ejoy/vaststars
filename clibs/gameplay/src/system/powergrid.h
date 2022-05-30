#pragma once

#include <stdint.h>

#define CONSUMER_PRIORITY 2
#define GENERATOR_PRIORITY 2

struct powergrid {
    uint64_t consumer_power[CONSUMER_PRIORITY];
    uint64_t generator_power[GENERATOR_PRIORITY];
    uint64_t accumulator_output;
    uint64_t accumulator_input;
    uint64_t generate_power;
    uint64_t consume_power;
    float consumer_efficiency[CONSUMER_PRIORITY];
    float generator_efficiency[GENERATOR_PRIORITY];
    float accumulator_efficiency;
};
