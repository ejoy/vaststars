local ecs = ...
local world = ecs.world
local w = world.w
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local entity_cfg = import_package "vaststars.config".entity
local terrain = ecs.require "terrain"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"

local prototype = {}
function prototype.pack_coord(x, y)
    assert(x & 0xFF == x)
    assert(y & 0xFF == y)
    return x | (y << 8)
end

function prototype.unpack_coord(v)
    return v >> 8, v & 0xFF
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
    local cfg = entity_cfg[prototype_name]
    if not cfg then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end

    return cfg.prefab
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

function prototype.is_fluidbox(prototype_name)
    assert(prototype_name)
    local pt = gameplay.queryByName("entity", prototype_name)
    if not pt then
        log.error(("can not found entity `%s`"):format(prototype_name))
        return
    end

    for _, t in ipairs(pt.type) do
        if t == "fluidbox" then
            return true
        end
    end
    return false
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

function prototype.get_coord(prototype_name, mouse_x, mouse_y)
    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    local coord, position = terrain.adjust_position(iinput.screen_to_world(mouse_x, mouse_y), area)
    if not coord then
        return
    end
    return coord[1], coord[2], position
end

return prototype