local ecs = ...
local world = ecs.world
local w = world.w

local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local prefab_path <const> = "/pkg/vaststars.resources/%s"
local game_object_event = ecs.require "engine.game_object_event"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local iani = ecs.import.interface "ant.animation|ianimation"
local fs = require "filesystem"
local math3d = require "math3d"
local COLOR_INVALID <const> = math3d.constant "null"

local function _replace_material(template)
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
end

local function on_prefab_message(prefab, binding, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, binding, ...)
    else
        log.error(("game_object unknown event `%s`"):format(cmd))
    end
end

local _instance_hash ; do
    local get_hash_func; do
        function get_hash_func()
            local cache = {}
            local n = 0
            return function(s)
                if cache[s] then
                    return cache[s]
                else
                    n = n + 1
                    assert(n <= 0xff)
                    cache[s] = n
                    return n
                end
            end
        end
    end

    local prefab_name_hash = get_hash_func()
    local state_hash = get_hash_func()
    local color_hash = get_hash_func()
    local animation_hash = get_hash_func()
    local process_hash = get_hash_func()

    function _instance_hash(prefab_file_name, state, color, animation_name, process)
        local h1 = prefab_name_hash(prefab_file_name or 0)
        local h2 = state_hash(state or 0)
        local h3 = color_hash(color or 0)
        local h4 = animation_hash(animation_name or 0)
        local h5 = process_hash(process or 0)

        return h1 | (h2 << 8) | (h3 << 16) | (h4 << 24) | (h5 << 32) -- assuming 255 types of every parameter at most
    end
end

local _get_hitch_children ; do
    local cache = {} -- prefab_file_name + state + color -> object
    local hitch_group_id = 10000 -- see also: terrain.lua -> TERRAIN_MAX_GROUP_ID
    local pose_cache = {} -- prefab_file_name -> pose

    local function _get_pose(param)
        if not pose_cache[param] then
            pose_cache[param] = iani.create_pose()
        end
        return pose_cache[param]
    end

    local function _create_animation(group_id, prefab_file_name, pose, animation_name, process)
        local g = ecs.group(group_id)
        local animation_inst = g:create_instance(prefab_file_name:string())
        animation_inst.on_ready = function(prefab)
            iani.set_pose_to_prefab(prefab, pose)

            if not animation_name and not process then
                for _, eid in ipairs(prefab.tag["*"]) do
                    local e = assert(world:entity(eid))
                    if e.animation_birth then
                        animation_name, process = e.animation_birth, 0
                    end
                end
            end

            assert(animation_name and process) -- animation_name and process are required, otherwise the initial pose of entity will be wrong
            iani.play(prefab, {name = animation_name, loop = false, manual = true})
            iani.set_time(prefab, iani.get_duration(prefab, animation_name) * process)
        end
        animation_inst.on_message = function (_prefab, cmd, ...)
        end
        world:create_object(animation_inst)
    end

    function _get_hitch_children(prefab_file_name, state, color, animation_name, process)
        local param = _instance_hash(prefab_file_name, state, tostring(color), animation_name, process)
        if cache[param] then
            return cache[param].hitch_group_id, cache[param].binding
        end

        local f = prefab_path:format(prefab_file_name)
        local template

        if state == "translucent" then -- translucent or opaque
            template = _replace_material(serialize.parse(f, cr.read_file(f)))
        else
            template = serialize.parse(f, cr.read_file(f))
        end

        -- cache all slots of the prefab
        local slots = {}
        for _, v in ipairs(template) do
            if v.data.slot then
                slots[v.data.name] = v.data
            end
        end

        local pose = _get_pose(param)
        local binding = {
            prefab_file_name = prefab_file_name, -- for debug
            slots = slots,
            pose = pose,
        }

        hitch_group_id = hitch_group_id + 1
        ecs.group(hitch_group_id):enable "scene_update"
        log.info(("game_object.new_instance: %s"):format(table.concat({hitch_group_id, prefab_file_name, state, require("math3d").tostring(color), animation_name, process}, " "))) -- TODO: remove this line

        local g = ecs.group(hitch_group_id)
        local prefab = g:create_instance(template)
        prefab.on_ready = function(prefab)
            world:entity(prefab.root).standalone_scene_object = true
            for _, eid in ipairs(prefab.tag["*"]) do
                world:entity(eid).standalone_scene_object = true
            end
            on_prefab_ready(prefab, binding)

            local animation_prefab_file_name = prefab_file_name:gsub("^(.*)(%.prefab)$", "%1-animation.prefab")
            local _f = fs.path(prefab_path:format(animation_prefab_file_name))
            if fs.exists(_f) then
                iani.set_pose_to_prefab(prefab, pose)
                _create_animation(hitch_group_id, _f, pose, animation_name, process)
            end
        end
        prefab.on_message = function(prefab, ...)
            on_prefab_message(prefab, binding, ...)
        end

        local instance = world:create_object(prefab)
        if state == "translucent" then
            instance:send("set_material_property", "u_basecolor_factor", color)
        end

        cache[param] = {instance = instance, hitch_group_id = hitch_group_id, binding = binding}
        return hitch_group_id, binding
    end
end

local M = {}
function M.create(prefab_file_name, cull_group_id, state, color, srt, slot, pose)
    local children, prefab_binding = _get_hitch_children(prefab_file_name, state, color, nil, nil)
    local events = {}
    events["update"] = function(_, e, group)
        e.hitch.group = group
    end

    local _slot
    local policy
    if slot then
        _slot = {}
        for k, v in pairs(slot) do
            _slot[k] = v
        end
        _slot.pose = pose

        policy = {
            "ant.scene|hitch_object",
            "ant.general|name",
            "ant.animation|slot"
        }
    else
        policy = {
            "ant.scene|hitch_object",
            "ant.general|name",
        }
    end

    local hitch_entity_object = ientity_object.create(ecs.group(cull_group_id):create_entity{
        policy = policy,
        data = {
            name = prefab_file_name,
            scene = {
                s = srt.s,
                t = srt.t,
                r = srt.r,
            },
            hitch = {
                group = children,
            },
            slot = _slot,
        }
    }, events)

    local function remove(self)
        self.hitch_entity_object:remove()
    end
    local function update(self, prefab_file_name, state, color, animation_name, process)
        self.hitch_entity_object:send("update", _get_hitch_children(prefab_file_name, state, color, animation_name, process))
    end
    local function attach(self, slot_name, model)
        local s = prefab_binding.slots[slot_name]
        if not s then
            log.error(("game_object.attach: slot %s not found"):format(slot_name))
            return
        end
        self.slot_attach[slot_name] = M.create(model, cull_group_id, "opaque", COLOR_INVALID, s.scene, s.slot, prefab_binding.pose)
    end
    local function detach(self)
        for _, v in pairs(self.slot_attach) do
            v:remove()
        end
        self.slot_attach = {}
    end

    local outer = {hitch_entity_object = hitch_entity_object, slot_attach = {}}
    outer.remove = remove
    outer.update = update
    outer.attach = attach
    outer.detach = detach
    return outer
end
return M