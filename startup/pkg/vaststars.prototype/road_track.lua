local CROSS_TYPE <const> = {
    ll = 0, lt = 1, lr = 2, lb = 3,
    tl = 4, tt = 5, tr = 6, tb = 7,
    rl = 8, rt = 9, rr = 10, rb = 11,
    bl = 12, bt = 13, br = 14, bb = 15,
}

return {
    ROAD_MODEL = "/pkg/vaststars.resources/glbs/road/X.glb|mesh.prefab",

    START = {
        [CROSS_TYPE.ll] = "path_start_l",
        [CROSS_TYPE.lt] = "path_start_l",
        [CROSS_TYPE.lr] = "path_start_l",
        [CROSS_TYPE.lb] = "path_start_l",
        [CROSS_TYPE.tl] = "path_start_t",
        [CROSS_TYPE.tt] = "path_start_t",
        [CROSS_TYPE.tr] = "path_start_t",
        [CROSS_TYPE.tb] = "path_start_t",
        [CROSS_TYPE.rl] = "path_start_r",
        [CROSS_TYPE.rt] = "path_start_r",
        [CROSS_TYPE.rr] = "path_start_r",
        [CROSS_TYPE.rb] = "path_start_r",
        [CROSS_TYPE.bl] = "path_start_b",
        [CROSS_TYPE.bt] = "path_start_b",
        [CROSS_TYPE.br] = "path_start_b",
        [CROSS_TYPE.bb] = "path_start_b",
    },

    TRACKS = {
        [CROSS_TYPE.bt] = {
            [0] = {'path_b2t_1'},
            [1] = {'path_b2t_2'},
        },
        [CROSS_TYPE.tb] = {
            [0] = {'path_t2b_1'},
            [1] = {'path_t2b_2'},
        },
        [CROSS_TYPE.rl] = {
            [0] = {'path_r2l_1'},
            [1] = {'path_r2l_2'},
        },
        [CROSS_TYPE.lr] = {
            [0] = {'path_l2r_1'},
            [1] = {'path_l2r_2'},
        },
        [CROSS_TYPE.br] = {
            [0] = {'path_b2r_2'},
            [1] = {'path_b2r_3'},
        },
        [CROSS_TYPE.bl] = {
            [0] = {'path_b2l_2'},
            [1] = {'path_b2l_3'},
        },
        [CROSS_TYPE.tr] = {
            [0] = {'path_t2r_2'},
            [1] = {'path_t2r_3'},
        },
        [CROSS_TYPE.tl] = {
            [0] = {'path_t2l_2'},
            [1] = {'path_t2l_3'},
        },
        [CROSS_TYPE.rb] = {
            [0] = {'path_r2b_2'},
            [1] = {'path_r2b_3'},
        },
        [CROSS_TYPE.rt] = {
            [0] = {'path_r2t_2'},
            [1] = {'path_r2t_3'},
        },
        [CROSS_TYPE.lb] = {
            [0] = {'path_l2b_2'},
            [1] = {'path_l2b_3'},
        },
        [CROSS_TYPE.lt] = {
            [0] = {'path_l2t_2'},
            [1] = {'path_l2t_3'},
        },
        [CROSS_TYPE.bb] = {
            [0] = {'path_b2b_2'},
            [1] = {'path_b2b_3', 'path_b2b_4', 'path_b2b_5'},
        },
        [CROSS_TYPE.tt] = {
            [0] = {'path_t2t_2'},
            [1] = {'path_t2t_3', 'path_t2t_4', 'path_t2t_5'},
        },
        [CROSS_TYPE.ll] = {
            [0] = {'path_l2l_2'},
            [1] = {'path_l2l_3', 'path_l2l_4', 'path_l2l_5'},
        },
        [CROSS_TYPE.rr] = {
            [0] = {'path_r2r_2'},
            [1] = {'path_r2r_3', 'path_r2r_4', 'path_r2r_5'},
        },
    },

    SPEC = {
        ["station"] = {
            model = "/pkg/vaststars.resources/glbs/goods-station-1.glb|mesh.prefab",
            tracks = {
                N = {
                    [CROSS_TYPE.bl] = {
                        [0] = {'path_b2l_1', 'path_b2l_2'},
                        [1] = {'path_b2l_3'},
                    },
                    [CROSS_TYPE.rb] = {
                        [0] = {'path_b2l_3'},
                        [1] = {'path_r2b_2'},
                    },
                },
                W = {
                    [CROSS_TYPE.rb] = {
                        [0] = {'path_b2l_1', 'path_b2l_2'},
                        [1] = {'path_b2l_3'},
                    },
                    [CROSS_TYPE.tr] = {
                        [0] = {'path_b2l_3'},
                        [1] = {'path_r2b_2'},
                    },
                },
                S = {
                    [CROSS_TYPE.tr] = {
                        [0] = {'path_b2l_1', 'path_b2l_2'},
                        [1] = {'path_b2l_3'},
                    },
                    [CROSS_TYPE.lt] = {
                        [0] = {'path_b2l_3'},
                        [1] = {'path_r2b_2'},
                    },
                },
                E = {
                    [CROSS_TYPE.lt] = {
                        [0] = {'path_b2l_1', 'path_b2l_2'},
                        [1] = {'path_b2l_3'},
                    },
                    [CROSS_TYPE.bl] = {
                        [0] = {'path_b2l_3'},
                        [1] = {'path_r2b_2'},
                    },
                },
            },
        },
        ["factory"] = {
            model = "/pkg/vaststars.resources/glbs/factory-1.glb|mesh.prefab",
            tracks = {
                N = {
                    [CROSS_TYPE.tr] = {
                        [0] = {'path_t2r_1', 'path_t2r_2'},
                        [1] = {'path_t2r_3'},
                    },
                    [CROSS_TYPE.lt] = {
                        [0] = {'path_t2r_3'},
                        [1] = {'path_l2t_2'},
                    },
                },
                W = {
                    [CROSS_TYPE.rb] = {
                        [0] = {'path_t2r_1', 'path_t2r_2'},
                        [1] = {'path_t2r_3'},
                    },
                    [CROSS_TYPE.tr] = {
                        [0] = {'path_t2r_3'},
                        [1] = {'path_l2t_2'},
                    },
                },
                S = {
                    [CROSS_TYPE.tr] = {
                        [0] = {'path_t2r_1', 'path_t2r_2'},
                        [1] = {'path_t2r_3'},
                    },
                    [CROSS_TYPE.lt] = {
                        [0] = {'path_t2r_3'},
                        [1] = {'path_l2t_2'},
                    },
                },
                E = {
                    [CROSS_TYPE.lt] = {
                        [0] = {'path_t2r_1', 'path_t2r_2'},
                        [1] = {'path_t2r_3'},
                    },
                    [CROSS_TYPE.bl] = {
                        [0] = {'path_t2r_3'},
                        [1] = {'path_l2t_2'},
                    },
                },
            },
        },
    },
}