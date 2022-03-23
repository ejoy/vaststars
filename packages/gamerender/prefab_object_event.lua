local ecs = ...
local world = ecs.world
local w = world.w

local iani = ecs.import.interface "ant.animation|ianimation"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"

local events = {}
events["animation_play"] = function(prefab, binding, animation)
    for _, eid in ipairs(prefab.tag["*"]) do
        if world:entity(eid)._animation then
            iani.play(eid, animation)
        end
    end
end

events["animation_set_time"] = function(prefab, binding, animation_name, process)
    for _, eid in ipairs(prefab.tag["*"]) do
        if world:entity(eid)._animation then
            iani.set_time(eid, iani.get_duration(eid, animation_name) * process)
        end
    end
end

events["update_basecolor"] = function(prefab, binding, basecolor_factor)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
    end
end

local function get_slot_eid(prefab, slot_name)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e.slot and e.name == slot_name then
            return eid
        end
    end
end

events["attach_slot"] = function(prefab, binding, slot_name, prefab_file_name)
    local prefab_object = assert(iprefab_object.create(prefab_file_name))
    binding.slot_attach[slot_name] = prefab_object
    ecs.method.set_parent(prefab_object.root, assert(get_slot_eid(prefab, slot_name)))
end

events["detach_slot"] = function(prefab, binding)
    for _, prefab_object in pairs(binding.slot_attach) do
        world:pub {"prefab_object_system", "detach_slot", prefab_object}
    end
end

return events