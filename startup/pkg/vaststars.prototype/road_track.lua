local CROSS_TYPE <const> = {
    ll = 0, lt = 1, lr = 2, lb = 3,
    tl = 4, tt = 5, tr = 6, tb = 7,
    rl = 8, rt = 9, rr = 10, rb = 11,
    bl = 12, bt = 13, br = 14, bb = 15,
}

local road_track = {
    ['I'] = {
        [CROSS_TYPE.bt] = {
            [0] = {'path_r_1'},
            [1] = {'path_r_2'},
        },
        [CROSS_TYPE.tb] = {
            [0] = {'path_l_1'},
            [1] = {'path_l_2'},
        },
    },
    ['L'] = {
        [CROSS_TYPE.rt] = {
            [0] = {'path_r_1'},
            [1] = {'path_r_1', 'path_r_2', 'path_r_3'},
        },
        [CROSS_TYPE.tr] = {
            [0] = {'path_l_1'},
            [1] = {'path_l_1', 'path_l_2', 'path_l_3'},
        },
    },
    ['T'] = {
        [CROSS_TYPE.lr] = {
            [0] = {'path_l_1'},
            [1] = {'path_l_1', 'path_l_2'},
        },
        [CROSS_TYPE.lb] = {
            [1] = {'path_l2b_1', 'path_l2b_2', 'path_l2b_3'},
        },
        [CROSS_TYPE.rl] = {
            [0] = {'path_r_1'},
            [1] = {'path_r_1', 'path_r_2'},
        },
        [CROSS_TYPE.rb] = {
            [1] = {'path_r2b_1', 'path_r2b_2', 'path_r2b_3', 'path_r2b_4'},
        },
        [CROSS_TYPE.bt] = {
            [0] = {'path_b2r_1'},
        },
        [CROSS_TYPE.bl] = {
            [1] = {'path_b2l_1', 'path_b2l_2', 'path_b2l_3', 'path_b2l_4'},
        },
        [CROSS_TYPE.br] = {
            [1] = {'path_b2r_1', 'path_b2r_2', 'path_b2r_3'},
        },
        [CROSS_TYPE.ll] = {
            [0] = {'path_l2l_1'},
            [1] = {'path_l2l_1', 'path_l2l_2', 'path_l2l_3', 'path_l2l_4', 'path_l2l_5'},
        },
        [CROSS_TYPE.rr] = {
            [0] = {'path_r2r_1'},
            [1] = {'path_r2r_1', 'path_r2r_2', 'path_r2r_3', 'path_r2r_4', 'path_r2r_5'},
        },
        [CROSS_TYPE.bb] = {
            [0] = {'path_b2b_1'},
            [1] = {'path_b2b_1', 'path_b2b_2', 'path_b2b_3', 'path_b2b_4', 'path_b2b_5'},
        },
    },
    ['X'] = {
        [0] = {'path_b2t_1', 'path_b2t_1'}, -- left to left -- TODO
        [1] = {'path_l2t_1', 'path_l2t_2','path_l2t_3'}, -- left to top
        [2] = {'path_l2r_1', 'path_l2r_2'}, -- left to right
        [3] = {'path_l2b_1', 'path_l2b_2','path_l2b_3'}, -- left to bottom

        [4] = {'path_t2l_1', 'path_t2l_2','path_t2l_3'}, -- top to left
        [5] = {'path_t2l_1', 'path_t2l_1'}, -- top to top -- TODO
        [6] = {'path_t2r_1', 'path_t2r_2','path_t2r_3'}, -- top to right
        [7] = {'path_t2b_1', 'path_t2b_2'}, -- top to bottom

        [8]  = {'path_r2l_1', 'path_r2l_2'}, -- right to left
        [9] = {'path_r2t_1', 'path_r2t_2','path_r2t_3'}, -- right to top
        [10] = {'path_r2t_1', 'path_r2t_1'}, -- right to right -- TODO
        [11] = {'path_r2b_1', 'path_r2b_2','path_r2b_3'}, -- right to bottom

        [12] = {'path_b2l_1', 'path_b2l_2','path_b2l_3'}, -- bottom to left
        [13] = {'path_b2t_1', 'path_b2t_2'}, -- bottom to top
        [14] = {'path_b2r_1', 'path_b2r_2','path_b2r_3'}, -- bottom to right
        [15] = {'path_b2r_1', 'path_b2r_1'}, -- bottom to bottom -- TODO
    },
    ['U'] = {
        [0] = {'path_t2t_1', 'path_t2t_2', 'path_t2t_3', 'path_t2t_4', 'path_t2t_5'},
    },
}
return road_track