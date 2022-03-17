local ecs = ...
local world = ecs.world
local w = world.w

local iani = ecs.import.interface "ant.animation|ianimation"
local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"
local game_object_remove_mb = world:sub {"game_object_system", "remove"}

function game_object_sys:update_world()
    for _, _, game_object_eid in game_object_remove_mb:unpack() do
        world:remove_entity(game_object_eid)
    end
end

local game_object_prefab = {}

local prefab_events = {}
prefab_events.on_ready = function(game_object, prefab)
    local prefab_slot_eid_cache = {}
    for _, eid in ipairs(prefab.tag["*"]) do
        local e = world:entity(eid)
        if not e then
            log.error(("can nof found game_object `%s`"):format(eid))
            goto continue
        end

        if game_object.pause_animation and e._animation then
            iani.pause(e, true)
        end

        if e.slot then
            prefab_slot_eid_cache[e.name] = eid
        end
        ::continue::
    end

    if next(prefab_slot_eid_cache) then
        game_object.prefab_slot_eid_cache = prefab_slot_eid_cache
    end
end
prefab_events.on_update = function(game_object, prefab)
end
prefab_events.on_message = function(game_object, prefab)
end
prefab_events.on_init = function(game_object, prefab)
end

local function create_prefab_object(prefab)
    local prefab_object = world:create_object(prefab)
    prefab_object.tag = prefab.tag
    return prefab_object
end

-- 调用此接口时, 允许 game_object 与 prefab 所对应的 entity 未创建好
function igame_object.bind(game_object_eid, prefab)
    local old_prefab_object = game_object_prefab[game_object_eid]
    if old_prefab_object then
        for _, eid in ipairs(old_prefab_object.tag["*"]) do
            ipickup_mapping.unmapping(eid, game_object_eid)
        end
        old_prefab_object:remove()
    end

    for fn, func in pairs(prefab_events) do
        local ofunc = prefab[fn]
        prefab[fn] = function(prefab_inner, ...)
            local game_object = world:entity(game_object_eid)
            if not game_object then
                log.error(("can nof found game_object `%s`"):format(game_object_eid))
                return
            end

            func(game_object, prefab_inner, ...)
            if ofunc then
                ofunc(game_object, prefab_inner, ...)
            end
        end
    end

    local prefab_object = create_prefab_object(prefab)
    for _, eid in ipairs(prefab.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid)
    end

    game_object_prefab[game_object_eid] = prefab_object
    return prefab_object
end

function igame_object.remove(game_object_eid)
    local prefab = game_object_prefab[game_object_eid]
    if prefab then
        game_object_prefab[game_object_eid] = nil
        prefab:remove()
    end
    -- remove game_object entity must ensure that after prefab is deleted, in `update_world` stage
    world:pub {"game_object_system", "remove", game_object_eid}
end

function igame_object.get_prefab_object(game_object_eid)
    local prefab_object = game_object_prefab[game_object_eid]
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
    end
    return prefab_object
end

-----------------------------------------------------------------------
local prefab_path = "/pkg/vaststars.resources/%s"
local cr = import_package "ant.compile_resource"
local serialize = import_package "ant.serialize"
local imaterial = ecs.import.interface "ant.asset|imaterial"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local irq = ecs.import.interface "ant.render|irenderqueue"
local iinput = ecs.import.interface "vaststars.gamerender|iinput"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local prototype = ecs.require "prototype"
local terrain = ecs.require "terrain"
local math3d = require "math3d"

local function replace_material(template)
    for _, v in ipairs(template) do
        for _, policy in ipairs(v.policy) do
            if policy == "ant.render|render" or policy == "ant.render|simplerender" then
                v.data.material = "/pkg/vaststars.resources/construct.material"
            end
        end
    end

    return template
end

local function update_basecolor(prefab, basecolor_factor)
    local e
    for _, eid in ipairs(prefab.tag["*"]) do
        e = world:entity(eid)
        if e.material then
            imaterial.set_property(e, "u_basecolor_factor", basecolor_factor)
        end
    end
end

local function on_prefab_ready(game_object)
    world:pub {"game_object_ready", game_object.id}
end

local on_prefab_message ; do
    local funcs = {}
    funcs["update_basecolor"] = function(game_object, prefab, basecolor_factor)
        update_basecolor(prefab, basecolor_factor)
    end

    function on_prefab_message(game_object, prefab, cmd, ...)
        local func = funcs[cmd]
        if func then
            func(game_object, prefab, ...)
        end
    end
end

function igame_object.create(prototype_name)
    local prefab_file = prototype.get_prefab_file(prototype_name)
    if not prefab_file then
        return
    end

    local f = prefab_path:format(prefab_file)
    local template = replace_material(serialize.parse(f, cr.read_file(f)))
    local prefab = ecs.create_instance(template)
    prefab.on_message = on_prefab_message
    prefab.on_ready = on_prefab_ready

    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    local viewdir = iom.get_direction(world:entity(irq.main_camera()))
    local origin = math3d.tovalue(iinput.ray_hit_plane({origin = mc.ZERO, dir = math3d.mul(math.maxinteger, viewdir)}, {dir = mc.YAXIS, pos = mc.ZERO_PT}))
    local coord, position = terrain.adjust_position(origin, area)
    iom.set_position(world:entity(prefab.root), position)

    local game_object_eid = ecs.create_entity {
        policy = {},
        data = {
            game_object_state = "",
            game_object_state_color = {},
            drapdrop = true,
            pause_animation = true,
            construct_pickup = true,
            gameplay_eid = 0,
            gameplay_entity = {
                prototype_name = prototype_name,
                fluid = {},
                dir = "N",
                x = coord[1],
                y = coord[2],
            }
        }
    }
    igame_object.bind(game_object_eid, prefab)
end

function igame_object.set_prototype_name(game_object, prototype_name)
    local prefab_file = prototype.get_prefab_file(prototype_name)
    if not prefab_file then
        return
    end

    local old_prefab_object = igame_object.get_prefab_object(game_object.id)
    if not old_prefab_object then
        return
    end
    local position = iom.get_position(world:entity(old_prefab_object.root))

    local template
    local f = prefab_path:format(prefab_file)
    if game_object.game_object_state == "translucent" then
        template = replace_material(serialize.parse(f, cr.read_file(f)))
    else
        template = f
    end

    local prefab = ecs.create_instance(template)
    prefab.on_message = on_prefab_message
    prefab.on_ready = on_prefab_ready

    iom.set_position(world:entity(prefab.root), position)

    local prefab_object = igame_object.bind(game_object.id, prefab)

    if game_object.game_object_state == "translucent" then
        prefab_object:send("update_basecolor", game_object.game_object_state_color)
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

function igame_object.set_state(game_object, state, color)
    local prefab_object
    if game_object.game_object_state ~= state then
        game_object.game_object_state = state

        local prefab_file = prototype.get_prefab_file(game_object.gameplay_entity.prototype_name)
        if not prefab_file then
            return
        end

        local old_prefab_object = igame_object.get_prefab_object(game_object.id)
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
        prefab.on_message = on_prefab_message
        prefab.on_ready = on_prefab_ready

        re = world:entity(prefab.root)
        iom.set_position(re, position)
        iom.set_rotation(re, rotation)

        prefab_object = igame_object.bind(game_object.id, prefab)
    else
        prefab_object = igame_object.get_prefab_object(game_object.id)
    end

    if state == "translucent" and not color_equal(game_object.game_object_state_color, color) then
        game_object.game_object_state_color = color
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
        local prefab_object = igame_object.get_prefab_object(game_object.id)
        if not prefab_object then
            return
        end
        iom.set_rotation(world:entity(prefab_object.root), rotators[dir])
    end
end

function igame_object.set_position(game_object, position)
    local prefab_object = igame_object.get_prefab_object(game_object.id)
    if not prefab_object then
        return
    end
    iom.set_position(world:entity(prefab_object.root), position)
end

function igame_object.get_coord(game_object)
    local prefab_object = igame_object.get_prefab_object(game_object.id)
    if not prefab_object then
        return
    end

    local position = math3d.tovalue(iom.get_position(world:entity(prefab_object.root)))
    local coord = terrain.get_coord_by_position(position)
    return coord[1], coord[2]
end

function igame_object.drapdrop(game_object, prototype_name, mouse_x, mouse_y)
    local prefab_object = igame_object.get_prefab_object(game_object.id)
    if not prefab_object then
        return
    end

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
