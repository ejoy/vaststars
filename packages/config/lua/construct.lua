local construct = {
    ["road"] = {
        construct_prefab = "road/road_O.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.road",
                construct_entity = {
                    building_type = "road",
                    detect = "exclusive",
                    prefab = "road/road_O.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.road",
                            building = {
                                building_type = "road",
                                area = {1, 1},
                            },
                            pickup_show_set_road_arrow = true,
                        },
                    },
                },
                drapdrop = false,
            },
        },
    },

    ["goods_station"] = {
        construct_prefab = "goods_station.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.goods_station",
                construct_entity = {
                    building_type = "road",
                    detect = "roadside",
                    prefab = "goods_station.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.goods_station",
                            building = {
                                building_type = "goods_station",
                                area = {1, 1},
                            },
                            stop_ani_during_init = true,
                            set_road_entry_during_init = true,
                        },
                    },
                },
                drapdrop = false,
                stop_ani_during_init = true,
            },
        },
    },

    ["logistics_center"] = {
        construct_prefab = "logistics_center.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.logistics_center",
                construct_entity = {
                    building_type = "road",
                    detect = "roadside",
                    prefab = "logistics_center.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.logistics_center",
                            building = {
                                building_type = "logistics_center",
                                area = {3, 3},
                            },
                            stop_ani_during_init = true,
                            set_road_entry_during_init = true,
                        },
                    },
                },
                drapdrop = false,
                stop_ani_during_init = true,
            },
        },
    },

    ["container"] = {
        construct_prefab = "container.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.container",
                construct_entity = {
                    building_type = "road",
                    prefab = "container.prefab",
                    entity = {
                        policy = {
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.container",
                            building = {
                                building_type = "container",
                                area = {1, 1},
                            },
                            stop_ani_during_init = true,
                        },
                    },
                },
                drapdrop = false,
                stop_ani_during_init = true,
            },
        },
    },

    ["rock"] = {
        construct_prefab = "rock.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.rock",
                construct_entity = {
                    building_type = "road",
                    prefab = "rock.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.rock",
                            building = {
                                building_type = "rock",
                                area = {1, 1},
                            },
                            stop_ani_during_init = true,
                        },
                    },
                },
                drapdrop = false,
                stop_ani_during_init = true,
            },
        },
    },

    ["pipe"] = {
        construct_prefab = "pipe/pipe_O.prefab",
        construct_entity = {
            policy = {
                "ant.general|name",
                "vaststars.gamerender|construct_entity",
            },
            data = {
                name = "vaststars.pipe",
                construct_entity = {
                    building_type = "pipe",
                    detect = "exclusive",
                    prefab = "pipe/pipe_O.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.pipe",
                            building = {
                                building_type = "pipe",
                                area = {1, 1},
                            },
                            pickup_show_set_pipe_arrow = true,
                        },
                    },
                },
                drapdrop = false,
            },
        },
    },
}
return construct
