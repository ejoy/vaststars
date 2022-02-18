local ecs   = ...
local world = ecs.world
local w     = world.w

local fs = require "filesystem"
local icas   = ecs.import.interface "ant.terrain|icanvas"
local icanvas = ecs.interface "icanvas"
local canvas_sys = ecs.system "canvas_system"
local canvas_new_entity_mb = world:sub {"canvas_update", "new_entity"}
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local datalist = require "datalist"
local canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/canvas.cfg")):read "a")

function canvas_sys.data_changed()
    local canvas_entity = w:singleton("canvas", "canvas:in")
    if not canvas_entity then
        return
    end

    for _, _, e in canvas_new_entity_mb:unpack() do
        w:sync("scene:in", e)
        ipickup_mapping.mapping(e.scene.id, canvas_entity, {"canvas"})
    end
end

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

function icanvas.add_items(...)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    for _, item in ipairs({...}) do
        local cfg = canvas_cfg[item.texture.name]
        if not cfg then
            error(("can not found `%s`"):format(item.texture.name))
        end

        item.texture.path = "/pkg/vaststars.resources/textures/canvas.texture"
        item.texture.rect = {
            x = cfg.x,
            y = cfg.y,
            w = cfg.width,
            h = cfg.height,
        }
    end

    return icas.add_items(e, ...)
end

function icanvas.remove_item(itemid)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    return icas.remove_item(e, itemid)
end
