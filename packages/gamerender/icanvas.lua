local ecs   = ...
local world = ecs.world
local w     = world.w

local icas   = ecs.import.interface "ant.terrain|icanvas"
local icanvas = ecs.interface "icanvas"

function icanvas.create()
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
        }
    }
end

function icanvas.add_items(items)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    return icas.add_items(e, items)
end

function icanvas.remove_item(itemid)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    return icas.remove_item(e, itemid)
end
