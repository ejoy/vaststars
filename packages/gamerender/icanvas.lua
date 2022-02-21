local ecs   = ...
local world = ecs.world
local w     = world.w

local fs = require "filesystem"
local icas   = ecs.import.interface "ant.terrain|icanvas"
local icanvas = ecs.interface "icanvas"
local canvas_sys = ecs.system "canvas_system"
local canvas_new_entity_mb = world:sub {"canvas_update", "new_entity"}
local ipickup_mapping = ecs.import.interface "vaststars.input|ipickup_mapping"
local iterrain = ecs.import.interface "vaststars.gamerender|iterrain"
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

-- item = {name = xx, x = xx, y = xx, srt = {s = xx, r = xx, t = xx}}
function icanvas.add_items(...)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    local items = {}
    for _, i in ipairs({...}) do
        local cfg = canvas_cfg[i.name]
        if not cfg then
            error(("can not found `%s`"):format(i.name))
        end

        -- bounds checking
        local p = iterrain.get_begin_position_by_coord(i.x, i.y)
        if not p then
            goto continue
        end

        local item = {
            texture = {
                path = "/pkg/vaststars.resources/textures/canvas.texture",
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
                -- srt = {},
            },
            x = p[1], y = p[2], w = 10, h = 10,
            srt = i.srt,
        }
        items[#items+1] = item

        ::continue::
    end

    return icas.add_items(e, table.unpack(items))
end

function icanvas.remove_item(...)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        return
    end

    for _, id in ipairs({...}) do
        return icas.remove_item(e, id)
    end
end
