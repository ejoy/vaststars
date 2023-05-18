#pragma once

#include <util/component.h>
#include <map>
#include <vector>

struct station_ref {
    ecs::station* ptr;
};

using station_vector = std::vector<station_ref>;
using station_map = std::map<uint16_t, station_vector>;

struct station_mgr {
    station_vector producers;
    station_map consumers;
};
