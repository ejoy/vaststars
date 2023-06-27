local m = {}

local DirtyUnknown   <const> = 1 << 1;
local DirtyRoadnet   <const> = 1 << 2;
local DirtyFluidflow <const> = 1 << 3;
local DirtyHub       <const> = 1 << 4;
local DirtyTech      <const> = 1 << 5;

local function dirty_entity(world, e)
    if e.road or e.endpoint or e.starting then
        world:dirty(DirtyRoadnet)
    else
        world:dirty(DirtyUnknown)
    end
end

local DIRECTION <const> = {
    N = 0, North = 0,
    E = 1, East  = 1,
    S = 2, South = 2,
    W = 3, West  = 3,
}

function m.move(world, e, x, y)
    local building = e.building
    if building.x ~= x or building.y ~= y then
        building.x = x
        building.y = y
        dirty_entity(world, e)
    end
end

function m.rotate(world, e, dir)
    local building = e.building
    local d = assert(DIRECTION[dir])
    if building.direction ~= d then
        building.direction = d
        if e.fluidbox or e.fluidboxes then
            e.fluidbox_changed = true
        end
        dirty_entity(world, e)
    end
end

function m.destroy(world, e)
    dirty_entity(world, e)
    -- ecs:remove 无法处理entity visitor
    e.REMOVED = true
end

return m
