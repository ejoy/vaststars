local ecs = ...
local world = ecs.world
local w = world.w

local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local prototype = ecs.require "prototype"

local igame_object = ecs.interface "igame_object"
local game_object_sys = ecs.system "game_object_system"
local game_object_remove_mb = world:sub {"game_object_system", "remove"}
local game_object_binding = {}

function game_object_sys:update_world()
    for _, _, game_object_eid in game_object_remove_mb:unpack() do
        world:remove_entity(game_object_eid)
    end
end

local function get_game_object_binding(game_object_eid)
    local binding = game_object_binding[game_object_eid]
    if not binding then
        log.error(("can not found game_object `%s`"):format(game_object_eid))
        return
    end
    return binding
end

local function get_prefab_object(game_object_eid)
    if not game_object_binding[game_object_eid] then
        return
    end
    return game_object_binding[game_object_eid].prefab_object
end

-- 调用此接口时, 允许 game_object 与 prefab 所对应的 entity 未创建好
function igame_object.bind(game_object_eid, prefab_object)
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

    for _, eid in ipairs(prefab_object.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid)
    end

    binding.prefab_object = prefab_object
    binding.cur_animation = nil
    binding.cur_attach_prefab_object = {}
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
    local game_object_binding = get_game_object_binding(game_object_eid)
    if not game_object_binding then
        return
    end

    if game_object_binding.cur_attach_prefab_object.slot_name == slot_name and game_object_binding.cur_attach_prefab_object.prototype_name == prototype_name then
        return
    end

    local prefab_file = prototype.get_prefab_file(prototype_name)
    if not prefab_file then
        return
    end

    local prefab_object = assert(game_object_binding.prefab_object)
    prefab_object:send("detach_slot")
    prefab_object:send("attach_slot", slot_name, prefab_file)
end

function igame_object.detach(game_object_eid)
    local prefab_object = get_prefab_object(game_object_eid)
    if not prefab_object then
        log.error(("can not found prefab_object `%s`"):format(game_object_eid))
        return
    end
    prefab_object:send("detach_slot")
end

-----------------------------------------------------------------------
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

function igame_object.create(prototype_name)
    local prefab_file_name = prototype.get_prefab_file(prototype_name)
    if not prefab_file_name then
        return
    end

    local area = prototype.get_area(prototype_name)
    if not area then
        return
    end

    local viewdir = iom.get_direction(world:entity(irq.main_camera()))
    local origin = math3d.tovalue(iinput.ray_hit_plane({origin = mc.ZERO, dir = math3d.mul(math.maxinteger, viewdir)}, {dir = mc.YAXIS, pos = mc.ZERO_PT}))
    local coord, position = terrain.adjust_position(origin, area)

    local CONSTRUCT_GREEN_BASIC_COLOR <const> = {0.0, 50.0, 0.0, 0.8}
    local prefab_object = iprefab_object.create(prefab_file_name, "translucent", CONSTRUCT_GREEN_BASIC_COLOR)
    iom.set_position(world:entity(prefab_object.root), position)

    local game_object_eid = ecs.create_entity {
        policy = {},
        data = {
            game_object = {x = coord[1], y = coord[2], state = "translucent", color = CONSTRUCT_GREEN_BASIC_COLOR},
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
    igame_object.bind(game_object_eid, prefab_object)
    return coord[1], coord[2]
end

function igame_object.set_prototype_name(game_object, prototype_name)
    local prefab_file_name = prototype.get_prefab_file(prototype_name)
    if not prefab_file_name then
        return
    end

    local old_prefab_object = get_prefab_object(game_object.id)
    if not old_prefab_object then
        return
    end
    local position = iom.get_position(world:entity(old_prefab_object.root))

    local prefab_object = iprefab_object.create(prefab_file_name, "translucent", game_object.game_object.color)
    iom.set_position(world:entity(prefab_object.root), position)

    igame_object.bind(game_object.id, prefab_object)
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

        local prefab_file_name = prototype.get_prefab_file(prototype_name)
        if not prefab_file_name then
            return
        end

        local old_prefab_object = get_prefab_object(game_object.id)
        if not old_prefab_object then
            return
        end
        local re = world:entity(old_prefab_object.root)
        local rotation = iom.get_rotation(re)
        local position = iom.get_position(re)

        prefab_object = iprefab_object.create(prefab_file_name, game_object.game_object.state, color)
        re = world:entity(prefab_object.root)
        iom.set_position(re, position)
        iom.set_rotation(re, rotation)

        igame_object.bind(game_object.id, prefab_object)
    else
        prefab_object = get_prefab_object(game_object.id)
        if color and not color_equal(game_object.game_object.color, color) then
            game_object.game_object.color = color
            prefab_object:send("update_basecolor", color)
        end
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

