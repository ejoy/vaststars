local iprototype = require "gameplay.interface.prototype"

-- define in packages\gameplay\type\assembling.lua
local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function get_percent(progress, total)
    assert(progress <= total)
    if progress < 0 then
        progress = 0
    end
    return (total - progress) / total -- the progress of inserter is decreasing from total to 0
end

local function update_world(world, get_object_func)
    local t = {}
    for e in world.ecs:select "inserter:in entity:in" do
        local vsobject = get_object_func(e.entity.x, e.entity.y)

        local inserter = e.inserter
        if inserter.hold_item ~= 0 then
            local hold_item_typeobject = assert(iprototype.queryById(inserter.hold_item), ("can not found hold_item `%s`"):format(inserter.hold_item))
            local hold_item_typeobject = assert(iprototype.queryByName("item", hold_item_typeobject.name), ("can not found item `%s`"):format(hold_item_typeobject.name))
            assert(hold_item_typeobject.model, ("can not found item model `%s`"):format(hold_item_typeobject.name))
            vsobject:attach("empty9", hold_item_typeobject.model)
        else
            vsobject:detach()
        end

        if inserter.progress > 0 then
            local animation_name
            if inserter.status == STATUS_DONE then
                animation_name = "DownToUp"
            else
                animation_name = "UpToDown"
            end
            local typeobject = assert(iprototype.queryById(e.entity.prototype))
            vsobject:animation_update(animation_name, get_percent(inserter.progress, assert(typeobject.speed)))
        end

    end
    return t
end
return update_world