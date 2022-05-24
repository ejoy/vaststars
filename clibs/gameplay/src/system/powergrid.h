#pragma once

#define CONSUMER_PRIORITY 2
#define GENERATOR_PRIORITY 2
#define NORMAL_TEMPERATURE 15

struct powergrid {
	float consumer_power[CONSUMER_PRIORITY];
	float generator_power[GENERATOR_PRIORITY];
	float accumulator_output;
	float accumulator_input;
	float solar;
	float consumer_efficiency[CONSUMER_PRIORITY];
	float generator_efficiency[GENERATOR_PRIORITY];
	float accumulator_efficiency;
};
