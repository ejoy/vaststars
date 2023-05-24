local road_track = {
    ['I'] = {
        [0] = {'path_r_1', 'path_r_2'}, -- bottom to top
        [1] = {'path_l_1', 'path_l_2'}, -- top to bottom
    },
    ['L'] = {
        [0] = {'path_r_1', 'path_r_2', 'path_r_3'}, -- right to top
        [1] = {'path_l_1', 'path_l_2', 'path_l_3'}, -- top to right
    },
    ['T'] = {
        [2]  = {'path_l_1', 'path_l_2'}, -- left to right
        [3] = {'path_l2b_1', 'path_l2b_2','path_l2b_3'}, -- left to bottom
        [4] = {'path_b2l_1', 'path_b2l_2', 'path_b2l_3', 'path_b2l_4'}, -- bottom to left
        [6]  = {'path_b2r_1', 'path_b2r_2', 'path_b2r_3'}, -- bottom to right
        [8]  = {'path_r_1', 'path_r_2'}, -- right to left
        [11] = {'path_r2b_1', 'path_r2b_2', 'path_r2b_3', 'path_r2b_4'}, -- right to bottom
        [12] = {'path_b2l_1', 'path_b2l_2', 'path_b2l_3', 'path_b2l_4'}, -- bottom to left
        [14] = {'path_b2r_1', 'path_b2r_2', 'path_b2r_3'}, -- bottom to right

        -- [0] = {'path_l_1', 'path_l_2'}, -- left to right
        -- [1]  = {'path_r_1', 'path_r_2'}, -- right to left
        -- [2] = {'path_l_1', 'path_l_2'}, -- left to right
        -- [3] = {'path_l2b_1', 'path_l2b_2','path_l2b_3'}, -- left to bottom
        -- [11] = {'path_r2b_1', 'path_r2b_2', 'path_r2b_3', 'path_r2b_4'}, -- right to bottom
        -- [12] = {'path_b2l_1', 'path_b2l_2', 'path_b2l_3', 'path_b2l_4'}, -- bottom to left
        -- [14] = {'path_b2r_1', 'path_b2r_2', 'path_b2r_3'}, -- bottom to right
    },
    ['X'] = {
        [0] = {'path_b2t_1', 'path_b2t_1'}, -- left to left -- TODO
        [1] = {'path_l2t_1', 'path_l2t_2','path_l2t_3'}, -- left to top
        [2] = {'path_l2r_1', 'path_l2r_2'}, -- left to right
        [3] = {'path_l2b_1', 'path_l2b_2','path_l2b_3','path_l2b_4'}, -- left to bottom

        [4] = {'path_t2l_1', 'path_t2l_2','path_t2l_3','path_t2l_4'}, -- top to left
        [5] = {'path_t2l_1', 'path_t2l_1'}, -- top to top -- TODO
        [6] = {'path_t2r_1', 'path_t2r_2','path_t2r_3'}, -- top to right
        [7] = {'path_t2b_1', 'path_t2b_2'}, -- top to bottom

        [8]  = {'path_r2l_1', 'path_r2l_2'}, -- right to left
        [9] = {'path_r2t_1', 'path_r2t_2','path_r2t_3','path_r2t_4'}, -- right to top
        [10] = {'path_r2t_1', 'path_r2t_1'}, -- right to right -- TODO
        [11] = {'path_r2b_1', 'path_r2b_2','path_r2b_3'}, -- right to bottom

        [12] = {'path_b2l_1', 'path_b2l_2','path_b2l_3'}, -- bottom to left
        [13] = {'path_b2t_1', 'path_b2t_2'}, -- bottom to top
        [14] = {'path_b2r_1', 'path_b2r_2','path_b2r_3','path_b2r_4'}, -- bottom to right
        [15] = {'path_b2r_1', 'path_b2r_1'}, -- bottom to bottom -- TODO
    },
    ['U'] = {
        [0] = {'path_t2t_1', 'path_t2t_2', 'path_t2t_3', 'path_t2t_4', 'path_t2t_5'},
    },
}
return road_track