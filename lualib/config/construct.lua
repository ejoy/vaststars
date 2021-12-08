local construct = {
    ["road"] = {building_type = "road", prefab_file_name = "res/road/O_road.prefab", test_func = "world.construct_test.road", size = {1, 1}},
    ["goods_station"] = {building_type = "goods_station", prefab_file_name = "res/goods_station.prefab", test_func = "world.construct_test.roadside", size = {1, 1}},
    ["logistics_center"] = {building_type = "logistics_center", prefab_file_name = "res/logistics_center.prefab", test_func = "world.construct_test.roadside", size = {3, 3}},
}
return construct
