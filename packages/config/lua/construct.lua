local construct = {
    ["road"] = {building_type = "road", prefab_file_name = "road/O_road.prefab", detect = "road", size = {1, 1}},
    ["goods_station"] = {building_type = "goods_station", prefab_file_name = "goods_station.prefab", detect = "roadside", size = {1, 1}},
    ["logistics_center"] = {building_type = "logistics_center", prefab_file_name = "logistics_center.prefab", detect = "roadside", size = {3, 3}},
    ["container"] = {building_type = "container", prefab_file_name = "container.prefab", detect = nil, size = {1, 1}},
    ["rock"] = {building_type = "rock", prefab_file_name = "rock.prefab", detect = nil, size = {1, 1}},
}
return construct
