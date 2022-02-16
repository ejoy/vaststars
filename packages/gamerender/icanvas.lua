local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local icanvas = ecs.interface "icanvas"
local canvas = {}

function icanvas.create()
    local unit = 1
    return ecs.create_entity {
        policy = {
            "ant.scene|scene_object",
            "ant.terrain|canvas",
            "ant.general|name",
        },
        data = {
            name = "canvas",
            scene = {
                srt = {
                    t={0.0, 5.0, 0.0}
                }
            },
            reference = true,
            canvas = {
                textures = {},
                texts = {},
            },
            on_ready = function (e)
                canvas.added_items =
                    icas.add_items(e,
                        {
                            texture = {
                                path = "/pkg/ant.resources/textures/white.texture",
                                size = {
                                    w = 1, h = 1,
                                },
                                rect = {
                                    x = 0, y = 0,
                                    w = 1, h = 1,
                                },
                            },
                            x = 0 * unit, y = 0 * unit,
                            w = 2 * unit, h = 2 * unit,
                        },
                        {
                            texture = {
                                path = "/pkg/ant.resources/textures/white.texture",
                                size = {
                                    w = 1, h = 1,
                                },
                                rect = {
                                    x = 0, y = 0,
                                    w = 1, h = 1,
                                },
                            },
                            x = 0 * unit, y = 0 * unit,
                            w = 2 * unit, h = 2 * unit,
                        }
                    )
            end
        }
    }
end
