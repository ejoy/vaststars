local ecs = ...
local world = ecs.world
local w = world.w
local iefk = ecs.require "ant.efk|efk"
local fs = require "filesystem"

local function preload(path)
    local files = {}
    for file in fs.pairs(fs.path(path)) do
        local s = file:string()
        if s:match("%.texture$") then
            files[#files+1] = s
        end
    end
    iefk.preload(files)
end
return {
    preload = preload,
}