local ecs = ...
local world = ecs.world
local w = world.w
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local entity_cfg = import_package "vaststars.config".entity
local terrain = ecs.require "terrain"

local prototype = {}
function prototype.pack_coord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y << 8)
end

function prototype.unpack_area(v)
    return v >> 8, v & 0xFF
end

function prototype.query(prototype)
    local pt = gameplay.query(prototype)
    if not pt then
        log.error(("can not found prototype(%s)"):format(prototype))
        return
    end
    return pt
end

function prototype.query_by_name(main_type, prototype_name)
    local pt = gameplay.queryByName(main_type, prototype_name)
    if not pt then
        log.error(("can not found prototype_name(%s)"):format(prototype_name))
        return
    end
    return pt
end

function prototype.get_prototype_name(prototype)
    local pt = gameplay.query(prototype)
    if not pt then
        log.error(("can not found prototype(%s)"):format(prototype))
        return
    end
    return pt.name
end

function prototype.get_area(prototype_name)
    assert(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end
    return pt.area
end

function prototype.get_prefab_file(prototype_name)
    assert(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end

    return pt.model
end

function prototype.get_construct_detector(prototype_name)
    assert(prototype_name)
    local cfg = entity_cfg[prototype_name]
    if not cfg then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end

    return cfg.construct_detector
end

function prototype.get_fluid_id(prototype_name)
    assert(prototype_name)
    local pt = gameplay.queryByName("fluid", prototype_name)
    if not pt then
        log.error(("can not found fluid `%s`"):format(prototype_name))
        return 0
    end
    return pt.id
end

local function check_entity_type(prototype_name, types)
    assert(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end

    for _, st in ipairs(pt.type) do
        for _, dt in ipairs(types) do
            if st == dt then
                return true
            end
        end
    end
    return false
end

function prototype.is_fluidbox(prototype_name)
    return check_entity_type(prototype_name, {"fluidbox"})
end

function prototype.is_fluidboxes(prototype_name)
    return check_entity_type(prototype_name, {"fluidboxes"})
end

function prototype.is_pipe(prototype_name)
    assert(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end
    return pt.pipe
end

return prototype