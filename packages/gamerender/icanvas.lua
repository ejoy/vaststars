local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local icanvas = ecs.interface "icanvas"
local canvas_items = {}

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
                    t={0.0, 1.0, 0.0}
                }
            },
            reference = true,
            canvas = {
                textures = {},
                texts = {},
            },
            on_ready = function (e)
                canvas_items.added_items =
                    icas.add_items(e,
                        {
                            texture = {
                                path = "/pkg/vaststars.resources/textures/canvas.texture",
                                rect = {
                                    x = 0, y = 0,
                                    w = 271, h = 203,
                                },
                            },
                            x = 0 * unit, y = 0 * unit,
                            w = 271 * unit, h = 203 * unit,
                        }
                    )
            end
        }
    }
end
