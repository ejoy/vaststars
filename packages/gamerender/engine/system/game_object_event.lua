local ecs = ...
local world = ecs.world
local w = world.w

local ifs = ecs.import.interface "ant.scene|ifilter_state"
local iani = ecs.import.interface "ant.animation|ianimation"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
--local imotion = ecs.import.interface "ant.animation|imotion"
local imodifier = ecs.import.interface "ant.modifier|imodifier"

local events = {}
events["animation_play"] = function(prefab, binding, animation)
    for _, eid in ipairs(prefab.tag["*"]) do
        if world:entity(eid).anim_ctrl then
            iani.play(eid, animation)
        end
    end
end

events["animation_set_time"] = function(prefab, binding, animation_name, process)
    for _, eid in ipairs(prefab.tag["*"]) do
        if world:entity(eid).anim_ctrl then
            iani.set_time(eid, iani.get_duration(eid, animation_name) * process)
        end
    end
end

events["set_material_property"] = function(prefab, binding, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e.material then
            imaterial.set_property(e, ...)
        end
    end
end

events["set_filter_state"] = function(prefab, binding, ...)
    for _, eid in ipairs(prefab.tag["*"]) do
        ifs.set_state(world:entity(eid), ...)
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

local function detach_slot(binding, slot_name)
    if slot_name then
        local game_object = binding.slot_attach[slot_name]
        if game_object then
            world:pub {"game_object_system", "detach_slot", game_object}
        end
    else
        for _, game_object in pairs(binding.slot_attach) do
            world:pub {"game_object_system", "detach_slot", game_object}
        end
        binding.slot_attach = {}
    end
end

events["attach_slot"] = function(prefab, binding, slot_name, prefab_file_name)
    detach_slot(binding, slot_name)

    local game_object = assert(igame_object.create(prefab_file_name))
    binding.slot_attach[slot_name] = game_object
    ecs.method.set_parent(game_object.root, assert(get_slot_eid(prefab, slot_name), ("can not found slot `%s`"):format(slot_name)))
end

events["detach_slot"] = function(prefab, binding)
    detach_slot(binding)
end

events["normal_motion"] = function(prefab, binding, motions)
    -- if motions == "select" then
    --     imodifier.start(prefab.srt_modifier, "talk", true)
    -- elseif motions == "unselect" then
    --     imodifier.start(prefab.srt_modifier, "over", true)
    -- end
end

events["on_object_create"] = function(prefab, binding)
    --imodifier.start(prefab.srt_modifier, "confirm")
end

return events