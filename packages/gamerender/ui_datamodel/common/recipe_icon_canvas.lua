local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.require "terrain"
local datalist = require "datalist"
local fs = require "filesystem"
local recipe_icon_canvas_cfg = datalist.parse(fs.open(fs.path("/pkg/vaststars.resources/textures/recipe_icon_canvas.cfg")):read "a")

local function get_recipe_canvas(recipe_name, x, y, w, h)
    local position = iterrain:get_begin_position_by_coord(x, y)
    if not position then
        return
    end

    if recipe_name == "" then
        local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
        return {
            {
                texture = {
                    path = "/pkg/vaststars.resources/ui/textures/assemble/setup2.texture",
                    rect = { -- -- TODO: remove this hard code
                        x = 0,
                        y = 0,
                        w = 64,
                        h = 64,
                    },
                },
                x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
                srt = {},
            }
        }
    end

    local cfg = recipe_icon_canvas_cfg[recipe_name]
    if not cfg then
        log.error(("can not found `%s`"):format(recipe_name))
        return
    end

    local item_x, item_y = position[1] + ((w / 2 - 0.5) * iterrain.tile_size), position[3] - ((h / 2 - 0.5) * iterrain.tile_size) - iterrain.tile_size
    return {
        {
            texture = {
                path = "/pkg/vaststars.resources/textures/recipe_icon.texture",
                rect = { -- -- TODO: remove this hard code
                    x = 0,
                    y = 0,
                    w = 90,
                    h = 90,
                },
            },
            x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            srt = {},
        },
        {
            texture = {
                path = "/pkg/vaststars.resources/textures/recipe_icon_canvas.texture",
                rect = {
                    x = cfg.x,
                    y = cfg.y,
                    w = cfg.width,
                    h = cfg.height,
                },
            },
            x = item_x, y = item_y, w = iterrain.tile_size, h = iterrain.tile_size,
            srt = {},
        }
    }
end
return {
    get_recipe_canvas = get_recipe_canvas,
}