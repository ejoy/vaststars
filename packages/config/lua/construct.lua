local construct = {
    ["road"] = {building_type = "road", prefab_file_name = "road/O_road.prefab", test_func = "road", size = {1, 1}},
    ["goods_station"] = {building_type = "goods_station", prefab_file_name = "goods_station.prefab", test_func = "roadside", size = {1, 1}},
    ["logistics_center"] = {building_type = "logistics_center", prefab_file_name = "logistics_center.prefab", test_func = "roadside", size = {3, 3}},
    ["container"] = {building_type = "container", prefab_file_name = "container.prefab", test_func = nil, size = {1, 1}},
}
return construct
