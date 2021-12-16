local road_path = {
    ['C'] = {
        [0] = {
            [2] = {prefab = "road/arrow_turn_left.prefab", slot = "右转下"},
        },
        [3] = {
            [1] = {prefab = "road/arrow_turn_right.prefab", slot = "下转右"},
        },
    },
    ['I'] = {
        [1] = {
            [1] = {prefab = "road/arrow_straight.prefab", slot = "左至右"},
        },
        [0] = {
            [0] = {prefab = "road/arrow_straight.prefab", slot = "右至左"},
        },
    },
    ['T'] = {
        [1] = {
            [1] = {prefab = "road/arrow_straight.prefab",   slot = "左至右"},
            [2] = {prefab = "road/arrow_turn_right.prefab", slot = "左转下"},
        },
        [0] = {
            [0] = {prefab = "road/arrow_straight.prefab",   slot = "右至左"},
            [2] = {prefab = "road/arrow_turn_left.prefab", slot = "右转下"},
        },
        [3] = {
            [1] = {prefab = "road/arrow_turn_right.prefab", slot = "下转右"},
            [0] = {prefab = "road/arrow_turn_left.prefab", slot = "下转左"},
        },
    },
    ['X'] = {
        [1] = {
            [1] = {prefab = "road/arrow_straight.prefab",     slot = "左至右"},
            [3] = {prefab = "road/arrow_turn_left_x.prefab",  slot = "左转上"},
            [2] = {prefab = "road/arrow_turn_right_x.prefab", slot = "左转下"},
        },
        [0] = {
            [0] = {prefab = "road/arrow_straight.prefab",   slot = "右至左"},
            [3] = {prefab = "road/arrow_turn_right_x.prefab",   slot = "右转上"},
            [2] = {prefab = "road/arrow_turn_left_x.prefab",   slot = "右转下"},
        },
        [3] = {
            [1] = {prefab = "road/arrow_turn_right_x.prefab", slot = "下转右"},
            [0] = {prefab = "road/arrow_turn_left_x.prefab", slot = "下转左"},
            [3] = {prefab = "road/arrow_straight.prefab", slot = "下至上"},
        },
        [2] = {
            [1] = {prefab = "road/arrow_turn_left_x.prefab", slot = "上转右"},
            [0] = {prefab = "road/arrow_turn_right_x.prefab", slot = "上转左"},
            [2] = {prefab = "road/arrow_straight.prefab", slot = "上至下"},
        },
    },
}
return road_path
