#pragma once

#include <util/component.h>
#include <map>
#include <vector>

using station_vector = std::vector<ecs::station*>;
using station_map = std::map<uint16_t, station_vector>;

struct station_mgr {
    station_vector producers;
    station_map consumers;
};
