local ecs = ...
local world = ecs.world
local w = world.w

local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local iani = ecs.import.interface "ant.animation|ianimation"

local iprefab_object = ecs.interface "iprefab_object"
local prefab_object_sys = ecs.system "prefab_object_system"

local prefab_path <const> = "/pkg/vaststars.resources/%s"
local prefab_events = ecs.require "prefab_object_event"

local detach_slot_mb = world:sub {"prefab_object_system", "detach_slot"}
local remove_mb = world:sub {"prefab_object_system", "remove"}

function prefab_object_sys:component_init()
    for _, _, prefab_object in detach_slot_mb:unpack() do
        ecs.method.set_parent(prefab_object.root, nil)
        prefab_object:remove()
    end

    for _, _, prefab_object in remove_mb:unpack() do
        prefab_object:remove()
    end
end

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/materials/translucent.material"
            end
        end
    end

    return template
end

local function on_prefab_ready(prefab, binding)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = assert(world:entity(eid))
        if e._animation then
            if binding.pause_animation then
                iani.pause(eid, true)
            end
        end
    end
end

local function on_prefab_message(prefab, binding, cmd, ...)
    local event = prefab_events[cmd]
    if event then
        event(prefab, binding, ...)
    end
end

-- state: translucent
function iprefab_object.create(prefab_file_name, state, color)
    local f = prefab_path:format(prefab_file_name)
    local template

    if state == "translucent" then
        template = replace_material(serialize.parse(f, cr.read_file(f)))
    else
        template = f
    end

    local binding = {
        pause_animation = true,
        slot_attach = {}, -- = {[name] = prefab_object, ...}
    }

    local prefab = ecs.create_instance(template)
    prefab.on_ready = function(prefab)
        on_prefab_ready(prefab, binding)
    end
    prefab.on_message = function(prefab, ...)
        on_prefab_message(prefab, binding, ...)
    end

    local prefab_object = world:create_object(prefab)
    if color then
        prefab_object:send("update_basecolor", color)
    end

    local outer = {}
    outer.tag = prefab.tag
    function outer:remove()
        self:send("detach_slot")
        world:pub {"prefab_object_system", "remove", prefab_object}
    end
    return setmetatable(outer, {__index = world:create_object(prefab)})
end
