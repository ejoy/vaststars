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
                        },
                        data = {
                            name = "vaststars.road",
                            area = {1, 1},
                            building_type = "road",
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
                        },
                        data = {
                            name = "vaststars.goods_station",
                            area = {1, 1},
                            building_type = "goods_station",
                            pause_animation = true,
                            set_road_entry = true,
                            pickup_show_remove = false,
                        },
                    },
                },
                drapdrop = false,
                pause_animation = true,
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
                        },
                        data = {
                            name = "",
                            area = {3, 3},
                            building_type = "logistics_center",
                            pause_animation = true,
                            set_road_entry = true,
                            pickup_show_ui = {url = "route.rml"},
                            route_endpoint = true,
                            random_name = true,
                            pickup_show_remove = false,
                        },
                    },
                },
                drapdrop = false,
                pause_animation = true,
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
                        },
                        data = {
                            name = "vaststars.container",
                            area = {1, 1},
                            building_type = "container",
                            pause_animation = true,
                            pickup_show_remove = false,
                        },
                    },
                },
                drapdrop = false,
                pause_animation = true,
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
                        },
                        data = {
                            name = "vaststars.rock",
                            area = {1, 1},
                            building_type = "rock",
                            pause_animation = true,
                            pickup_show_remove = false,
                        },
                    },
                },
                drapdrop = false,
                pause_animation = true,
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
                        },
                        data = {
                            name = "vaststars.pipe",
                            area = {1, 1},
                            building_type = "pipe",
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
