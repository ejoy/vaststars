local ecs = ...
local world = ecs.world
local w = world.w

local icanvas = ecs.import.interface "vaststars.gamerender|icanvas"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"
local terrain = ecs.require "terrain"
local vector2 = require "vector2"
local prototype = ecs.require "prototype"
local construct_button_sys = ecs.system "construct_button_system"
local iconstruct_button = ecs.interface "iconstruct_button"
local pickup_mapping_canvas_mb = world:sub {"pickup_mapping", "canvas"}

local UP_LEFT <const> = vector2.UP_LEFT
local UP_RIGHT <const> = vector2.UP_RIGHT
local DOWN <const> = vector2.DOWN
local RIGHT <const> = vector2.RIGHT
local construct_button_canvas_items = {}

function construct_button_sys:pickup_mapping()
    for _, _, _, x, y in pickup_mapping_canvas_mb:unpack() do
        local coord = terrain.get_coord_by_position(iinput.screen_to_world(x, y))
        local k = prototype.pack_coord(coord[1], coord[2])
        local v = construct_button_canvas_items[k]
        if v then
            v.event()
        end
    end
end

local coord_offset = {
    {
        name = "confirm.png",
        coord_func = function(x, y, area)
            return x + UP_LEFT[1], y + UP_LEFT[2]
        end,
        event = function()
            world:pub {"construct_button", "confirm"}
        end
    },
    {
        name = "cancel.png",
        coord_func = function(x, y, area)
            local width = prototype.unpack_area(area)
            return x + UP_RIGHT[1] * width, y + UP_RIGHT[2]
        end,
        event = function()
            world:pub {"construct_button", "cancel"}
        end,
    },
    {
        name = "rotate.png",
        coord_func = function(x, y, area)
            local dx, dy
            local width, height = prototype.unpack_area(area)
            -- 针对建筑宽度大于 1 的特殊处理
            if width > 1 then
                if width % 2 == 0 then
                    x = x + RIGHT[1] * ((width - 1) // 2)
                    y = y + DOWN[2] * height
                    dx = x + RIGHT[1]
                    dy = y + DOWN[2] * height
                    return x, y, dx, dy
                else
                    dx = x + RIGHT[1] * (width // 2)
                    dy = y + DOWN[2] * height
                    return dx, dy
                end
            else
                return x + DOWN[1], y + DOWN[2]
            end
        end,
        event = function()
            world:pub {"construct_button", "rotate"}
        end,
    },
}

function iconstruct_button.hide()
    for _, v in pairs(construct_button_canvas_items) do
        icanvas.remove_item(v.id)
    end
    construct_button_canvas_items = {}
end

function iconstruct_button.show(prototype_name, x, y)
    iconstruct_button.hide()

    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    for _, v in ipairs(coord_offset) do
        local cx, cy, dx, dy = v.coord_func(x, y, area)
        if not terrain.verify_coord(cx, cy) then
            goto continue
        end

        local pcoord = prototype.pack_coord(cx, cy)
        local id
        if dx and dy then
            id = icanvas.add_items(v.name, cx, cy, {t = {5, 0}})
        else
            id = icanvas.add_items(v.name, cx, cy)
        end
        construct_button_canvas_items[pcoord] = {id = id, event = v.event}

        if dx and dy then
            local pcoord = prototype.pack_coord(dx, dy)
            construct_button_canvas_items[pcoord] = {id = id, event = v.event}
        end
        ::continue::
    end
end
