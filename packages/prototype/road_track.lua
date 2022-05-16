local road_track = {
    ['L'] = {
        ['N'] = {
            ['E'] = {'path_l_1', 'path_l_2', 'path_l_3'},
        },
        ['E'] = {
            ['N'] = {'path_r_1', 'path_r_2', 'path_r_3'},
        },
    },
    ['I'] = {
        ['N'] = {
            ['S'] = {'path_l_1', 'path_l_2'},
        },
        ['S'] = {
            ['N'] = {'path_r_1', 'path_r_2'},
        },
    },
    ['T'] = {
        ['W'] = {
            ['S'] = {'path_l2b_1', 'path_l2b_2','path_l2b_3'},
            ['E'] = {'path_l_1', 'path_l_2'},
        },
        ['S'] = {
            ['W'] = {'path_b2l_1', 'path_b2l_2','path_b2l_3','path_b2l_4'},
            ['E'] = {'path_b2r_1', 'path_b2r_2','path_b2r_3'},
        },
        ['E'] = {
            ['W'] = {'path_r_1', 'path_r_2'},
            ['S'] = {'path_r2b_1', 'path_r2b_2','path_r2b_3','path_r2b_4'},
        },
    },
    ['X'] = {
        ['N'] = {
            ['S'] = {'path_t2b_1', 'path_t2b_2'},
            ['E'] = {'path_t2r_1', 'path_t2r_2','path_t2r_3'},
            ['W'] = {'path_t2l_1', 'path_t2l_2','path_t2l_3','path_t2l_4'},
        },
        ['S'] = {
            ['N'] = {'path_b2t_1', 'path_b2t_2'},
            ['E'] = {'path_b2r_1', 'path_b2r_2','path_b2r_3','path_b2r_4'},
            ['W'] = {'path_b2l_1', 'path_b2l_2','path_b2l_3'},
        },
        ['E'] = {
            ['N'] = {'path_r2t_1', 'path_r2t_2','path_r2t_3','path_r2t_4'},
            ['S'] = {'path_r2b_1', 'path_r2b_2','path_r2b_3'},
            ['W'] = {'path_r2l_1', 'path_r2l_2'},
        },
        ['W'] = {
            ['N'] = {'path_l2t_1', 'path_l2t_2','path_l2t_3'},
            ['S'] = {'path_l2b_1', 'path_l2b_2','path_l2b_3','path_l2b_4'},
            ['E'] = {'path_l2r_1', 'path_l2r_2'},
        },
    },
}
return road_track