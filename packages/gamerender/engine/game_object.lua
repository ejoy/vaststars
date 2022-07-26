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

local function on_prefab_ready(prefab)
end

local function on_prefab_message(prefab, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, ...)
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

    local function _create_animation(prefab_file_name, pose, animation_name, process)
        local instance = ecs.create_instance(prefab_file_name:string())
        instance.on_ready = function(prefab)
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
        instance.on_message = function (_prefab, cmd, ...)
        end
        world:create_object(instance)
    end

    local function _cache_prefab_info(template)
        local slots = {}
        local scene = {}
        for _, v in ipairs(template) do
            if v.data.slot then
                slots[v.data.name] = v.data
            end
            if v.data.name == "Scene" and v.data.scene then -- TODO: special for hitch which attach to slot
                scene = v.data.scene
            end
        end
        return scene, slots
    end

    function _get_hitch_children(prefab_file_path, state, color, animation_name, process)
        local hash = _instance_hash(prefab_file_path, state, tostring(color), animation_name, process)
        if cache[hash] then
            return cache[hash]
        end

        local template

        if state == "translucent" then -- translucent or opaque
            template = _replace_material(serialize.parse(prefab_file_path, cr.read_file(prefab_file_path)))
        else
            template = serialize.parse(prefab_file_path, cr.read_file(prefab_file_path))
        end

        -- cache all slots & srt of the prefab
        local scene, slots = _cache_prefab_info(template)

        hitch_group_id = hitch_group_id + 1
        local g = ecs.group(hitch_group_id)
        g:enable "scene_update"

        log.info(("game_object.new_instance: %s"):format(table.concat({hitch_group_id, prefab_file_path, state, require("math3d").tostring(color), animation_name, process}, " "))) -- TODO: remove this line

        local pose = iani.create_pose()
        local prefab = g:create_instance(template)
        prefab.on_init = function(prefab)
            world:entity(prefab.root).standalone_scene_object = true -- TODO: standalone_scene_object should be generated by prefab editor
            for _, eid in ipairs(prefab.tag["*"]) do
                world:entity(eid).standalone_scene_object = true
            end
        end
        prefab.on_ready = function(prefab)
            on_prefab_ready(prefab)

            local animation_prefab_file_path = prefab_file_path:gsub("^(.*)(%.prefab)$", "%1-animation.prefab")
            local _f = fs.path(animation_prefab_file_path)
            if fs.exists(_f) then
                iani.set_pose_to_prefab(prefab, pose)
                _create_animation(_f, pose, animation_name, process)
            end
        end
        prefab.on_message = function(prefab, ...)
            on_prefab_message(prefab, ...)
        end
        local instance = world:create_object(prefab)
        if state == "translucent" then
            instance:send("set_material_property", "u_basecolor_factor", color)
        end

        cache[hash] = {prefab_file_name = prefab_file_path, instance = instance, hitch_group_id = hitch_group_id, scene = scene, slots = slots, pose = pose}
        return cache[hash]
    end
end

local igame_object = ecs.interface "igame_object"
function igame_object.create(prefab_file_name, cull_group_id, state, color, srt, parent, slot)
    local children = _get_hitch_children(prefab_path:format(prefab_file_name), state, color, nil, nil)
    local events = {}
    events["group"] = function(_, e, group)
        e.hitch.group = group
    end
    events["slot_pose"] = function(_, e, pose)
        e.slot.pose = pose
    end

    local policy = {
        "ant.general|name",
        "ant.scene|hitch_object",
    }
    if slot then
        policy[#policy+1] = "ant.animation|slot"
    end

    local hitch_entity_object = ientity_object.create(ecs.group(cull_group_id):create_entity{
        policy = policy,
        data = {
            name = prefab_file_name,
            scene = {
                s = srt.s,
                t = srt.t,
                r = srt.r,
                parent = parent,
            },
            hitch = {
                group = children.hitch_group_id,
            },
            slot = slot,
            scene_needchange = true,
        }
    }, events)

    local function remove(self)
        self.hitch_entity_object:remove()
    end
    local function update(self, prefab_file_name, state, color, animation_name, process)
        local children = _get_hitch_children(prefab_path:format(prefab_file_name), state, color, animation_name, process)
        self.hitch_entity_object:send("group", children.hitch_group_id)
        for _, slot_game_object in pairs(self.slot_attach) do
            slot_game_object.hitch_entity_object:send("slot_pose", children.pose)
        end
    end
    local function attach(self, slot_name, model)
        local s = children.slots[slot_name]
        if not s then
            log.error(("game_object.attach: slot %s not found"):format(slot_name))
            return
        end
        local _slot = {}
        for k, v in pairs(s.slot) do
            _slot[k] = v
        end
        _slot.pose = children.pose
        -- TODO: children.scene <-- offset of the parent, missing offset of the slot
        self.slot_attach[slot_name] = igame_object.create(model, cull_group_id, "opaque", COLOR_INVALID, children.scene, self.hitch_entity_object.id, _slot)
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
