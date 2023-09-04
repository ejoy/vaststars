local ecs = ...
local world = ecs.world
local w = world.w
local game_object_event = ecs.require "engine.game_object_event"
local ientity_object = ecs.require "engine.system.entity_object_system"
local iani = ecs.require "ant.animation|controller.state_machine"
local iom = ecs.require "ant.objcontroller|obj_motion"
local irl = ecs.require "ant.render|render_layer"
local imodifier = ecs.require "ant.modifier|modifier"
local iefk = ecs.require "ant.efk|efk"
local RENDER_LAYER <const> = ecs.require("engine.render_layer").RENDER_LAYER
local RESOURCES_BASE_PATH <const> = "/pkg/vaststars.resources/%s"
local ANIMATIONS_BASE_PATH <const> = "/pkg/vaststars.resources/animations/"

local function on_prefab_message(prefab, cmd, ...)
    local event = game_object_event[cmd]
    if event then
        event(prefab, ...)
    else
        log.error(("game_object unknown event `%s`"):format(cmd))
    end
end

local __calc_param_hash ; do
    local function get_hash_func(max_value)
        local n = 0
        local cache = {}
        return function(s)
            if cache[s] then
                return cache[s]
            else
                assert(n <= max_value)
                cache[s] = n
                n = n + 1
                return cache[s]
            end
        end
    end

    local prefab_hash = get_hash_func(0xff)
    local color_hash = get_hash_func(0xf)
    local workstatus_hash = get_hash_func(0xf)
    local emissive_color_hash = get_hash_func(0xf)
    local render_layer_hash = get_hash_func(0xf)

    function __calc_param_hash(prefab, color, workstatus, emissive_color, render_layer)
        local h1 = prefab_hash(prefab or 0) -- 8 bits
        local h2 = color_hash(color or 0) -- 4 bits
        local h3 = workstatus_hash(workstatus or 0) -- 1 bits
        local h4 = emissive_color_hash(emissive_color or 0) -- 4 bits
        local h5 = render_layer_hash(render_layer or 0) -- 4 bits
        return h1 | (h2 << 8) | (h3 << 12) | (h4 << 13) | (h5 << 17)
    end
end

local __get_hitch_children ; do
    local cache = {}
    local hitch_group_id = 10000 -- see also: terrain.lua -> TERRAIN_MAX_GROUP_ID

    local function playAnimation(prefab_inst, e, workstatus, group)
        w:extend(e, "animation:in")
        local start = workstatus .. "_start"

        if e.animation[workstatus] then
            iani.play(prefab_inst, {name = workstatus, loop = true, speed = 1.0, manual = false, group = group})
        elseif e.animation[start] then
            iani.play(prefab_inst, {name = start, loop = false, speed = 1.0, manual = true, forwards = true, group = group})
            iani.set_time(prefab_inst, iani.get_duration(prefab_inst, start))
        end
    end

    local function playEfk(e, workstatus)
        w:extend(e, "eid:in efk:in name:in")
        if e.efk.auto_play then
            return
        end
        if not e.name:match("^work.*$") and not e.name:match("^idle.*$") and not e.name:match("^low_power.*$") then
            print("unknown efk", e.name)
        end
        if (workstatus == "work" and e.name:match("^work.*$")) or
           (workstatus == "idle" and e.name:match("^idle.*$")) or
           (workstatus == "low_power" and e.name:match("^low_power.*$")) then
            iefk.play(e.eid)
        end
    end

    local function getEventFile(prefab)
        local PATTERN <const> = "^.*/(.*)%.glb|.*%.prefab$"
        local match = prefab:match(PATTERN)
        local eventFile = (match or assert(prefab:match("^.*/(.*)%.prefab$"))) .. ".event"
        return ANIMATIONS_BASE_PATH .. eventFile
    end

    function __get_hitch_children(prefab, color, workstatus, emissive_color, render_layer)
        render_layer = render_layer or RENDER_LAYER.BUILDING
        local hash = __calc_param_hash(prefab, tostring(color), workstatus, tostring(emissive_color), render_layer)
        if cache[hash] then
            return cache[hash]
        end

        hitch_group_id = hitch_group_id + 1

        local prefab_instance = world:create_instance {
            prefab = prefab,
            group = hitch_group_id,
            on_ready = function (self)
                for _, eid in ipairs(self.tag["*"]) do
                    local e <close> = world:entity(eid, "render_object?update animation?in efk?in anim_ctrl?in")
                    if render_layer and e.render_object then
                        irl.set_layer(e, render_layer)
                    end

                    if workstatus and e.animation then
                        playAnimation(self, e, workstatus, hitch_group_id)
                    end

                    if workstatus and e.efk then
                        playEfk(e, workstatus)
                    end

                    -- special handling for keyframe animations
                    if e.anim_ctrl then
                        iani.load_events(eid, getEventFile(prefab))
                    end
                end
            end,
            on_message = function (self, ...)
                on_prefab_message(self, ...)
            end
        }
        if color then
            world:instance_message(prefab_instance, "material", "set_property", "u_basecolor_factor", color)
        end
        if emissive_color then
            world:instance_message(prefab_instance, "material", "set_property", "u_emissive_factor", emissive_color)
        end

        cache[hash] = {prefab_file_name = prefab, instance = prefab_instance, hitch_group_id = hitch_group_id, pose = iani.create_pose()}
        return cache[hash]
    end
end

local hitch_events = {}
hitch_events["group"] = function(_, e, group)
    w:extend(e, "hitch:update hitch_bounding?out")
    e.hitch.group = group
    e.hitch_bounding = true
end
hitch_events["obj_motion"] = function(_, e, method, ...)
    iom[method](e, ...)
end

local igame_object = {}
--[[
init = {
    prefab, -- the relative path to the prefab file
    group_id, -- the group id of the hitch, used to cull the hitch
    color,
    srt,
    parent, -- the parent of the hitch
    emissive_color,
    render_layer,
}
--]]
function igame_object.create(init)
    local children = __get_hitch_children(RESOURCES_BASE_PATH:format(init.prefab), init.color, init.workstatus or "idle", init.emissive_color, init.render_layer)
    local srt = init.srt or {}
    local hitch_entity_object = ientity_object.create(world:create_entity {
        group = init.group_id,
        policy = {
            "ant.general|name",
            "ant.render|hitch_object",
        },
        data = {
            name = init.prefab, -- for debug
            scene = {
                s = srt.s,
                t = srt.t,
                r = srt.r,
                parent = init.parent,
            },
            hitch = {
                group = children.hitch_group_id,
                hitch_bounding = true,
            },
            visible_state = "main_view|cast_shadow|selectable",
            scene_needchange = true,
        }
    }, hitch_events)

    local function remove(self)
        self.hitch_entity_object:remove()
    end

    -- prefab_file_name, color, emissive_color
    local function update(self, t)
        for k, v in pairs(t) do
            self.__cache[k] = v
        end

        if self.__cache.color == "null" then
            self.__cache.color = nil
        end
        if self.__cache.emissive_color == "null" then
            self.__cache.emissive_color = nil
        end

        children = __get_hitch_children(
            RESOURCES_BASE_PATH:format(self.__cache.prefab),
            self.__cache.color,
            self.__cache.workstatus,
            self.__cache.emissive_color,
            self.__cache.render_layer
        )
        self.hitch_entity_object:send("group", children.hitch_group_id)
    end
    local function send(self, ...)
        self.hitch_entity_object:send(...)
    end
    local function modifier(self, opt, ...)
        imodifier[opt](self.srt_modifier, ...)
    end

    local outer = {
        __cache = init,
        group_id = init.group_id,
        hitch_entity_object = hitch_entity_object,
        srt_modifier = imodifier.create_bone_modifier(
            hitch_entity_object.id,
            init.group_id,
            "/pkg/vaststars.resources/glbs/animation/Interact_build.glb|mesh.prefab",
            "Bone"
        ),
    }
    outer.modifier = modifier
    outer.remove = remove
    outer.update = update
    outer.send   = send
    outer.on_work = function ()
    end
    outer.on_idle = function ()
    end
    return outer
end

return igame_object
