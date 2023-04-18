local ecs = ...
local world = ecs.world
local w = world.w

local iterrain = ecs.import.interface "mod.terrain|iterrain"
local iroad = ecs.require "engine.road"
local math_abs = math.abs

local function packcoord(x, y)
    local hi = (x < 0 and 1 or 0) << 8 | math_abs(x)
    local lo = (y < 0 and 1 or 0) << 8 | math_abs(y)
    return (hi << 9) | lo
end

local function unpackcoord(n)
    local hi = n >> 9
    local lo = n & 0x1FF
    local x = (hi & 0x100 == 0x100) and -(hi & 0xFF) or (hi & 0xFF)
    local y = (lo & 0x100 == 0x100) and -(lo & 0xFF) or (lo & 0xFF)
    return x, y
end

local WIDTH <const> = 256 -- coordinate value range: [0, WIDTH - 1]
local HEIGHT <const> = 256 -- coordinate value range: [0, HEIGHT - 1]
local function __convert_coord(x, y, offset_x, offset_y)
    x, y = x, HEIGHT - y - 1
    return x - offset_x, y - offset_y
end

local mt = {}
function mt:__index(k)
    local v = rawget(self, k)
    if not v then
        rawset(self, k, {})
    end
    return rawget(self, k)
end
local tiles = setmetatable({}, mt)

local gen_id; do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

local function __rotate_area(w, h, dir)
    if dir == 'N' or dir == 'S' then
        return w, h
    elseif dir == 'E' or dir == 'W' then
        return h, w
    end
end

local REMOVE <const> = {}
local modify = {}
local cache = {}
return function(x, y, w, h, dir, color)
    local w, h = __rotate_area(w, h, dir)
    local offset_x, offset_y = iroad:get_offset()
    local id = gen_id()
    local sprites = {}

    local function flush()
        local m = {}
        local d = {}
        for coord, color in pairs(modify) do
            if color == REMOVE then
                cache[coord] = nil
                local x, y = unpackcoord(coord)
                d[#d+1] = {x = x, y = y}
            elseif color ~= cache[coord] then
                cache[coord] = color
                local l = #tiles[coord]
                m[#m+1] = tiles[coord][l]
            end
        end
        if #m > 0 then
            iterrain.update_zone_entity(m)
        end
        if #d > 0 then
            iterrain.delete_zone_entity(d)
        end
        modify = {}
    end
    local function create(x, y, color)
        x, y = __convert_coord(x, y, offset_x, offset_y)
        local dx, dy, coord, zone
        for i = 0, w-1 do
            for j = 0, h-1 do
                dx, dy = x + i, y - j
                coord = packcoord(dx, dy)
                zone = {
                    id = id,
                    x = x + i,
                    y = y - j,
                    zone_rgba = color,
                }
                table.insert(tiles[coord], zone)
                modify[coord] = color.r | (color.g << 8) | (color.b << 16) | (color.a << 24)
                sprites[coord] = true
            end
        end
    end
    local function remove()
        for coord in pairs(sprites) do
            modify[coord] = REMOVE

            for i, v in ipairs(tiles[coord]) do
                if v.id == id then
                    table.remove(tiles[coord], i)
                    break
                end
            end
            local l = #tiles[coord]
            if tiles[coord][l] then
                local color = tiles[coord][l].zone_rgba
                modify[coord] = color.r | (color.g << 8) | (color.b << 16) | (color.a << 24)
            end
        end
        sprites = {}
    end
    local function move(_, x, y, color)
        remove()
        create(x, y, color)
    end

    create(x, y, color)
    flush()
    return {
        remove = function() remove() flush() end,
        move = function(...) move(...) flush() end,
    }
end