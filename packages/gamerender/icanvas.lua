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

local function packCoord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y << 8)
end

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

local cache_id = {}
local cache_event = {}

function icanvas.add_items(name, x, y, srt, event)
    local pcoord = packCoord(x, y)
    if cache_id[pcoord] then
        log.warn(("coord(%s, %s) already has item"):format(x, y))
    end

    local e = w:singleton("canvas", "canvas:in")
    if not e then
        log.error("can not found canvas entity")
        return
    end

    local cfg = canvas_cfg[name]
    if not cfg then
        log.error(("can not found `%s`"):format(name))
        return
    end

    -- bounds checking
    local p = iterrain.get_begin_position_by_coord(x, y)
    if not p then
        return
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
        },
        x = p[1], y = p[3], w = 10, h = 10,
        srt = srt,
    }

    local item_id = icas.add_items(e, item)[1]
    if not item_id then
        log.error(("item_id is null (%s, %s)"):format(x, y))
        return
    end

    cache_id[pcoord] = {id = item_id, event = event}
    cache_event[item_id] = pcoord
    return item_id
end

function icanvas.remove_item(id)
    local e = w:singleton("canvas", "canvas:in")
    if not e then
        log.error("can not found canvas entity")
        return
    end

    local pcoord = cache_event[id]
    if not pcoord then
        log.error(("can not found item `%s`"):format(id))
        return
    end

    cache_event[id] = nil
    cache_id[pcoord] = nil

    return icas.remove_item(e, id)
end
