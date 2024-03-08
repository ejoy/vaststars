local ecs = ...
local world = ecs.world
local w = world.w

local CONSTANT <const> = require "gameplay.interface.constant"
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local itp = ecs.require "engine.translucent_plane"
local icoord = require "coord"

local cache = {}

local function add(x, y, w, h, color)
    local pos = assert(icoord.lefttop_position(x, y))
    local id = #cache + 1
    cache[id] = {x = pos[1], y = pos[3] - TILE_SIZE * h, w = TILE_SIZE * w, h = TILE_SIZE * h, gid = 0, color = color}
    return id
end

local mt = {}
function mt:move(x, y, color)
    self.x, self.y, self.color = x, y, color
    cache[self.id] = nil
    self.id = add(self.x, self.y, self.w, self.h, self.color)
end

function mt:remove()
    cache[self.id] = nil
end

local function create(x, y, w, h, color)
    local m = setmetatable({}, {__index = mt})
    m.x, m.y, m.w, m.h, m.color = x, y, w, h, color
    m.id = add(m.x, m.y, m.w, m.h, m.color)
    return m
end

local function flush()
    itp.clear()

    local t = {}
    for _, v in pairs(cache) do
        t[#t+1] = v
    end
    itp.update(t, RENDER_LAYER.TRANSLUCENT_PLANE)
end

return {
    create = create,
    flush = flush,
}