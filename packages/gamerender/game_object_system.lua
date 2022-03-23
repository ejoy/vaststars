local ecs = ...
local world = ecs.world
local w = world.w

local iani = ecs.import.interface "ant.animation|ianimation"
local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local prototype = ecs.require "prototype"

local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"
local game_object_remove_mb = world:sub {"game_object_system", "remove"}
local game_object_remove_attach_mb = world:sub {"game_object_system", "remove_attach"}
local prefab_path = "/pkg/vaststars.resources/%s"
local game_object_binding = {}

local function create_prefab_object(prefab)
    local prefab_object = world:create_object(prefab)
    prefab_object.tag = prefab.tag
    return prefab_object
end

function game_object_sys:component_init()
    for _, _, prefab_object in game_object_remove_attach_mb:unpack() do
        ecs.method.set_parent(prefab_object.root, nil)
        prefab_object:remove()
    end
end

function game_object_sys:update_world()
    for _, _, game_object_eid in game_object_remove_mb:unpack() do
        world:remove_entity(game_object_eid)
    end
end

local prefab_events = {}
prefab_events.on_ready = function(game_object, binding, prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can nof found game_object `%s`"):format(eid))
            goto continue
        end

        if e._animation then
            if binding.pause_animation then
                iani.pause(eid, true)
            end
            binding.animation_eid_cache[#binding.animation_eid_cache + 1] = eid
        end

        if e.material then
            binding.material_eid_cache[#binding.material_eid_cache + 1] = eid
        end

        if e.slot then
            binding.slot_eid_cache[e.name] = eid
        end
        ::continue::
    end
end
prefab_events.on_update = function(game_object, binding, prefab)
end

local function get_game_object_binding(game_object_eid)
    local binding = game_object_binding[game_object_eid]
    if not binding then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end
    return binding
end

local function detach(game_object_eid)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end

    local prefab_object = assert(binding.cur_attach_prefab_object).prefab_object
    if not prefab_object then
        return
    end
    world:pub {"game_object_system", "remove_attach", prefab_object}
    binding.cur_attach_prefab_object = {}
end

do
    local funcs = {}
    funcs["animation_play"] = function(game_object, binding, prefab, animation)
        for _, eid in ipairs(binding.animation_eid_cache) do
            iani.play(eid, animation)
        end
    end

    funcs["animation_set_time"] = function(game_object, binding, prefab, animation_name, process)
        for _, eid in ipairs(binding.animation_eid_cache) do
            iani.set_time(eid, iani.get_duration(eid, animation_name) * process)
        end
    end

    funcs["update_basecolor"] = function(game_object, binding, prefab, basecolor_factor)
        for _, eid in ipairs(binding.material_eid_cache) do
            imaterial.set_property(world:entity(eid), "u_basecolor_factor", basecolor_factor)
        end
    end

    funcs["attach"] = function(game_object, binding, prefab, slot_name, prototype_name)
        local prefab_file = prototype.get_prefab_file(prototype_name)
        if not prefab_file then
            return
        end

        local game_object_binding = get_game_object_binding(game_object.id)
        if not game_object_binding then
            return
        end

        if game_object_binding.cur_attach_prefab_object.slot_name == slot_name and game_object_binding.cur_attach_prefab_object.prototype_name == prototype_name then
            return
        end
        detach(game_object.id)

        local prefab = ecs.create_instance(prefab_path:format(prefab_file))
        prefab.on_message = function() end
        local prefab_object = create_prefab_object(prefab)

        local eid = assert(binding.slot_eid_cache[slot_name])
        ecs.method.set_parent(prefab_object.root, eid)

        game_object_binding.cur_attach_prefab_object = {slot_name = slot_name, prototype_name = prototype_name, prefab_object = prefab_object}
    end

    funcs["detach"] = function(game_object, binding, prefab)
        detach(game_object.id)
    end

    function prefab_events.on_message(game_object, binding, prefab, cmd, ...)
        local func = funcs[cmd]
        if not func then
            return
        end
        func(game_object, binding, prefab, ...)
    end
end

prefab_events.on_init = function(game_object, binding, prefab)
end

local function get_prefab_object(game_object_eid)
    if not game_object_binding[game_object_eid] then
        return
    end
    return game_object_binding[game_object_eid].prefab_object
end

-- 调用此接口时, 允许 game_object 与 prefab 所对应的 entity 未创建好
function igame_object.bind(game_object_eid, prefab)
    local old_prefab_object = get_prefab_object(game_object_eid)
    if old_prefab_object then
        for _, eid in ipairs(old_prefab_object.tag["*"]) do
            ipickup_mapping.unmapping(eid, game_object_eid)
        end
        old_prefab_object:remove()
    end

    local binding = game_object_binding[game_object_eid]
    if not binding then
        binding = {}
        game_object_binding[game_object_eid] = binding
    end

    local prefab_binding = {}
    prefab_binding.pause_animation = true
    prefab_binding.slot_eid_cache = {}
    prefab_binding.animation_eid_cache = {}
    prefab_binding.material_eid_cache = {}

    for fn, func in pairs(prefab_events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(prefab_inner, ...)
            local game_object = world:entity(game_object_eid)
            func(game_object, prefab_binding, prefab_inner, ...)
            if ofunc then
                ofunc(game_object, prefab_binding, prefab_inner, ...)
            end
        end
    end

    local prefab_object = create_prefab_object(prefab)
    for _, eid in ipairs(prefab_object.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid)
    end

    binding.prefab_object = prefab_object
    binding.cur_animation = nil
    binding.cur_attach_prefab_object = {}
    return assert(prefab_object)
end

function igame_object.remove(game_object_eid)
    local prefab_object = get_prefab_object(game_object_eid)
    if prefab_object then
        game_object_binding[game_object_eid] = nil
        prefab_object:remove()
    end
    -- remove game_object entity must ensure that after prefab is deleted, in `update_world` stage
    world:pub {"game_object_system", "remove", game_object_eid}
end

-- process = [0, 1]
function igame_object.animation_update(game_object_eid, animation_name, process)
    local binding = game_object_binding[game_object_eid]
    if not binding then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end

    local prefab_object = assert(binding.prefab_object)
    if not binding.cur_animation or binding.cur_animation.name ~= animation_name then
        binding.cur_animation = {name = animation_name, loop = false, manual = true, process = 0.0}
        prefab_object:send("animation_play", binding.cur_animation)
    end

    if binding.cur_animation.process ~= process then
        prefab_object:send("animation_set_time", animation_name, process)
        binding.cur_animation.process = process
    end
end

function igame_object.set_position(game_object_eid, position)
    local prefab_object = get_prefab_object(game_object_eid)
    if not prefab_object then
        return
    end
    iom.set_position(world:entity(prefab_object.root), position)
end

function igame_object.attach(game_object_eid, slot_name, prototype_name)
    local prefab_object = get_prefab_object(game_object_eid)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
        return
    end
    prefab_object:send("attach", slot_name, prototype_name)
end

function igame_object.detach(game_object_eid)
    local prefab_object = get_prefab_object(game_object_eid)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
        return
    end
    prefab_object:send("detach")
end

-----------------------------------------------------------------------
local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local terrain = ecs.require "terrain"
local math3d = require "math3d"
local engine = ecs.require "engine"

function igame_object.get_game_object(x, y)
    -- 此处必须用 select, 不能用 game_object_binding 缓存, 因为 game_object 可能未创建好
    for _, game_object in engine.world_select "game_object" do
        local binding = game_object_binding[game_object.id]
        if not binding then
            goto continue
        end

        if game_object.game_object.x == x and game_object.game_object.y == y then
            return game_object
        end
        ::continue::
    end
end

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/translucent.material"
            end
        end
    end

    return template
end

function igame_object.create(prototype_name, events)
    local prefab_file = prototype.get_prefab_file(prototype_name)
    if not prefab_file then
        return
    end

    local f = prefab_path:format(prefab_file)
    local template = replace_material(serialize.parse(f, cr.read_file(f)))
    local prefab = ecs.create_instance(template)
    prefab.on_ready = events.on_ready

    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    local viewdir = iom.get_direction(world:entity(irq.main_camera()))
    local origin = math3d.tovalue(iinput.ray_hit_plane({origin = mc.ZERO, dir = math3d.mul(math.maxinteger, viewdir)}, {dir = mc.YAXIS, pos = mc.ZERO_PT}))
    local coord, position = terrain.adjust_position(origin, area)
    iom.set_position(world:entity(prefab.root), position)

    local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
    local game_object_eid = ecs.create_entity {
        policy = {},
        data = {
            game_object = {x = coord[1], y = coord[2], status = "translucent", color = CONSTRUCT_GREEN_BASIC_COLOR},
            drapdrop = true,
            construct_pickup = true,
            gameplay_entity = {
                prototype_name = prototype_name,
                fluid = {},
                dir = "N",
                x = coord[1],
                y = coord[2],
            },
        }
    }
    igame_object.bind(game_object_eid, prefab)
end

function igame_object.set_prototype_name(game_object, prototype_name)
    local prefab_file = prototype.get_prefab_file(prototype_name)
    if not prefab_file then
        return
    end

    local old_prefab_object = get_prefab_object(game_object.id)
    if not old_prefab_object then
        return
    end
    local position = iom.get_position(world:entity(old_prefab_object.root))

    local template
    local f = prefab_path:format(prefab_file)
    if game_object.game_object.state == "translucent" then
        template = replace_material(serialize.parse(f, cr.read_file(f)))
    else
        template = f
    end

    local prefab = ecs.create_instance(template)
    iom.set_position(world:entity(prefab.root), position)

    local prefab_object = igame_object.bind(game_object.id, prefab)

    if game_object.game_object.state == "translucent" then
        prefab_object:send("update_basecolor", game_object.game_object.color)
    end
end

-- state : translucent opaque
local function color_equal(c1, c2)
    if #c1 ~= #c2 then
        return false
    end

    for i = 1, #c1 do
        if c1[i] ~= c2[i] then
            return false
        end
    end
    return true
end

function igame_object.set_state(game_object, prototype_name, state, color)
    local prefab_object
    if game_object.game_object.state ~= state then
        game_object.game_object.state = state

        local prefab_file = prototype.get_prefab_file(prototype_name)
        if not prefab_file then
            return
        end

        local old_prefab_object = get_prefab_object(game_object.id)
        if not old_prefab_object then
            return
        end
        local re = world:entity(old_prefab_object.root)
        local rotation = iom.get_rotation(re)
        local position = iom.get_position(re)

        local template
        local f = prefab_path:format(prefab_file)
        if state == "translucent" then
            template = replace_material(serialize.parse(f, cr.read_file(f)))
        else
            template = f
        end

        local prefab = ecs.create_instance(template)
        re = world:entity(prefab.root)
        iom.set_position(re, position)
        iom.set_rotation(re, rotation)

        prefab_object = igame_object.bind(game_object.id, prefab)
    else
        prefab_object = get_prefab_object(game_object.id)
    end

    if state == "translucent" and not color_equal(game_object.game_object.color, color) then
        game_object.game_object.color = color
        prefab_object:send("update_basecolor", color)
    end
end

do
    local rotators <const> = {
        N = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
        E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
        S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
        W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
    }

    function igame_object.set_dir(game_object, dir)
        local prefab_object = get_prefab_object(game_object.id)
        if not prefab_object then
            return
        end
        iom.set_rotation(world:entity(prefab_object.root), rotators[dir])
    end
end

