#pragma once

#include <util/component.h>
#include <map>
#include <vector>

struct station_producer_ref {
    ecs::station_producer* station;
    ecs::endpoint* endpoint;
};

struct station_consumer_ref {
    ecs::station_consumer* station;
    ecs::endpoint* endpoint;
};

using station_vector = std::vector<station_producer_ref>;
using station_map = std::map<uint16_t, std::vector<station_consumer_ref>>;

struct station_mgr {
    station_vector producers;
    station_map consumers;
};
