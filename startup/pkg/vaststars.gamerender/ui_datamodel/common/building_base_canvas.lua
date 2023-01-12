local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local building_base_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/building_base.cfg")):read "a")
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER

local function get_building_base_canvas_items(srt, w, h)
    local t = {}
    local cfg = building_base_cfg[("%dx%d"):format(w, h)]
    if not cfg then
        log.error(("can not found `%s`"):format(("%dx%d"):format(w, h)))
        assert(false)
        return
    end

    local item_x, item_y = srt.t[1] - (w/2 * iterrain.tile_size), srt.t[3] - (h/2 * iterrain.tile_size)
    local x, y, w, h = item_x, item_y, w * iterrain.tile_size, h * iterrain.tile_size

    t[#t + 1] ={
        "/pkg/vaststars.resources/textures/canvas_texture.material",
        RENDER_LAYER.BUILDING_BASE,
        {
            texture = {
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = x, y = y, w = w, h = h,
            srt = {},
        }
    }
    return t
end
return {
    get_building_base_canvas_items = get_building_base_canvas_items,
}