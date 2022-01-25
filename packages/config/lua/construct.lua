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
                    dir = 'N',
                    building_type = "road",
                    detector = "exclusive",
                    prefab = "road/road_O.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.road",
                            area = {1, 1},
                            building = {
                                building_type = "road",
                            },
                            pickup_show_set_road_arrow = true,
                            pickup_show_remove = false,
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
                    dir = 'N',
                    building_type = "goods_station",
                    detector = "roadside",
                    prefab = "goods_station.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.goods_station",
                            area = {1, 1},
                            building = {
                                building_type = "goods_station",
                            },
                            stop_ani_during_init = true,
                            set_road_entry_during_init = true,
                            pickup_show_remove = false,
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
                name = "",
                construct_entity = {
                    dir = 'N',
                    building_type = "logistics_center",
                    detector = "roadside",
                    prefab = "logistics_center.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "",
                            area = {3, 3},
                            building = {
                                building_type = "logistics_center",
                            },
                            stop_ani_during_init = true,
                            set_road_entry_during_init = true,
                            pickup_show_ui = {url = "route.rml"},
                            route_endpoint = true,
                            named = true,
                            pickup_show_remove = false,
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
                    dir = 'N',
                    building_type = "container",
                    prefab = "container.prefab",
                    entity = {
                        policy = {
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.container",
                            area = {1, 1},
                            building = {
                                building_type = "container",
                            },
                            stop_ani_during_init = true,
                            pickup_show_remove = false,
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
                    dir = 'N',
                    building_type = "rock",
                    prefab = "rock.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.rock",
                            area = {1, 1},
                            building = {
                                building_type = "rock",
                            },
                            stop_ani_during_init = true,
                            pickup_show_remove = false,
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
                    dir = 'N',
                    building_type = "pipe",
                    detector = "exclusive",
                    prefab = "pipe/pipe_O.prefab",
                    entity = {
                        policy = {
                            "ant.general|name",
                            "vaststars.gamerender|building",
                        },
                        data = {
                            name = "vaststars.pipe",
                            area = {1, 1},
                            building = {
                                building_type = "pipe",
                            },
                            pickup_show_set_pipe_arrow = true,
                            pickup_show_remove = false,
                        },
                    },
                },
                drapdrop = false,
            },
        },
    },
}
return construct
