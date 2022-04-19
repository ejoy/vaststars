local ecs = ...
local world = ecs.world
local w = world.w

local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local iani = ecs.import.interface "ant.animation|ianimation"
local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"

local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"

local prefab_path <const> = "/pkg/vaststars.resources/%s"
local game_object_event = ecs.require "engine.system.game_object_event"

local detach_slot_mb = world:sub {"game_object_system", "detach_slot"}
local remove_mb = world:sub {"game_object_system", "remove"}

function game_object_sys:component_init()
    for _, _, game_object in detach_slot_mb:unpack() do
        game_object:send("set_filter_state", "main_view", false)
        ecs.method.set_parent(game_object.root, nil) --TODO 如果没有先去除 parent 再 remove, remove parent 时会出现死循环
        game_object:remove()
    end

    for _, _, game_object in remove_mb:unpack() do
        game_object:remove()
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

        ipickup_mapping.mapping(eid, binding.pickup_binding)
    end
end

local function on_prefab_message(prefab, binding, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, binding, ...)
    else
        log.error(("game_object unknown event `%s`"):format(cmd))
    end
end

-- state: translucent
function igame_object.create(prefab_file_name, state, color, pickup_binding)
    local f = prefab_path:format(prefab_file_name)
    local template

    if state == "translucent" then
        template = replace_material(serialize.parse(f, cr.read_file(f)))
    else
        template = f
    end

    local binding = {
        pause_animation = true,
        slot_attach = {}, -- = {[name] = game_object, ...}
        pickup_binding = pickup_binding,
    }

    local prefab = ecs.create_instance(template)
    prefab.on_ready = function(prefab)
        on_prefab_ready(prefab, binding)
    end
    prefab.on_message = function(prefab, ...)
        on_prefab_message(prefab, binding, ...)
    end

    local game_object = world:create_object(prefab)
    if state == "translucent" and color then
        game_object:send("set_material_property", "u_basecolor_factor", color)
    end

    local outer = {}
    outer.tag = prefab.tag
    function outer:remove()
        self:send("detach_slot")
        world:pub {"game_object_system", "remove", game_object}
    end
    return setmetatable(outer, {__index = world:create_object(prefab)})
end
