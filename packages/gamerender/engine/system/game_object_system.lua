local ecs = ...
local world = ecs.world
local w = world.w

local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"

local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"

local prefab_path <const> = "/pkg/vaststars.resources/%s"
local game_object_event = ecs.require "engine.system.game_object_event"

local detach_slot_mb = world:sub {"game_object_system", "detach_slot"}
local remove_mb = world:sub {"game_object_system", "remove"}
local DEBUG = false

function game_object_sys:component_init()
    for _, _, game_object in detach_slot_mb:unpack() do
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

--
local function remove(self)
    self.game_object:send("detach_slot")
    self.game_object:send("remove", self.game_object)
end

local function attach(self, slot_name, prefab_file_name)
    if self.attach_slot_name[slot_name] == prefab_file_name then
        return
    end

    self.game_object:send("attach_slot", slot_name, prefab_file_name)
    self.attach_slot_name[slot_name] = prefab_file_name
end

local function detach(self)
    if not next(self.attach_slot_name) then
        return
    end

    self.game_object:send("detach_slot")
    self.attach_slot_name = {}
end

local function animation_update(self, animation_name, process)
    local game_object = assert(self.game_object)
    if self.animation.name ~= animation_name then
        self.animation = {name = animation_name, process = process, loop = false, manual = true}
        game_object:send("animation_play", self.animation)
    end

    if self.animation.process ~= process then
        self.animation.process = process
        game_object:send("animation_set_time", animation_name, process)
    end
end

local function send(self, ...)
    self.game_object:send(...)
end

-- state: translucent
function igame_object.create(prefab_file_name, group_id, state, color, pickup_binding)
    local f = prefab_path:format(prefab_file_name)
    local template

    if DEBUG then
        template = serialize.parse(f, cr.read_file(f))
        for _, node in ipairs(template) do
            if not node.data.slot then
                node.data.name = prefab_file_name .. "." .. node.data.name
            end
            node.policy[#node.policy+1] = 'ant.general|name'
        end
        if state == "translucent" then
            template = replace_material(template)
        else
            template = template
        end
    else
        if state == "translucent" then
            template = replace_material(serialize.parse(f, cr.read_file(f)))
        else
            template = f
        end
    end

    local binding = {
        pause_animation = true,
        slot_attach = {}, -- = {[name] = game_object, ...}
        pickup_binding = pickup_binding,
        group_id = group_id,
    }

    local g = ecs.group(group_id)
    local prefab = g:create_instance(template)
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
    outer.game_object = game_object
    outer.tag = prefab.tag
    outer.slot_name = ""
    outer.prefab_file_name = ""
    outer.animation = {}
    outer.attach_slot_name = {}

    outer.remove = remove
    outer.attach = attach
    outer.detach = detach
    outer.send   = send
    outer.animation_update = animation_update
    return setmetatable(outer, {__index = game_object})
end
