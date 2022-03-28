local ecs = ...
local world = ecs.world

local ipickup_mapping = ecs.import.interface "vaststars.gamerender|ipickup_mapping"
local iprefab_object = ecs.import.interface "vaststars.gamerender|iprefab_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local prototype = ecs.require "prototype"
local math3d = require "math3d"

local igame_object = ecs.interface "igame_object"
local game_object_binding = {}

local function get_game_object_binding(game_object_eid)
    local binding = game_object_binding[game_object_eid]
    if not binding then
        log.error(("can not found game_object binding `%s`"):format(game_object_eid))
        return
    end
    return binding
end

local function pickup_mapping(prefab_object, game_object_eid)
    for _, eid in ipairs(prefab_object.tag["*"]) do
        ipickup_mapping.mapping(eid, game_object_eid)
    end
end

local function pickup_unmapping(prefab_object, game_object_eid)
    for _, eid in ipairs(prefab_object.tag["*"]) do
        ipickup_mapping.unmapping(eid, game_object_eid)
    end
end

local function set_srt(e, srt)
    if not srt then
        return
    end
    iom.set_scale(e, srt.s)
    iom.set_rotation(e, srt.r)
    iom.set_position(e, srt.t)
end

local function bind_prefab_object(game_object_eid, prefab_object)
    local binding = game_object_binding[game_object_eid]
    if not binding then
        return
    end

    if binding.prefab_object then
        pickup_unmapping(binding.prefab_object, game_object_eid)
        binding.prefab_object:remove()
    end

    pickup_mapping(prefab_object, game_object_eid)

    binding.prefab_object = prefab_object
    binding.animation = {}
    binding.attach_slot_name = ""
    binding.attach_prototype_name = ""
end

function igame_object.valid(game_object_eid)
    return (game_object_binding[game_object_eid] ~= nil)
end

function igame_object.remove(game_object_eid)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end

    local prefab_object = binding.prefab_object
    if prefab_object then
        prefab_object:remove()
    end

    game_object_binding[game_object_eid] = nil
    world:remove_entity(game_object_eid)
end

-- process = [0, 1]
function igame_object.animation_update(game_object_eid, animation_name, process)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end

    local prefab_object = assert(binding.prefab_object)
    if binding.animation.name ~= animation_name then
        binding.animation = {name = animation_name, process = process, loop = false, manual = true}
        prefab_object:send("animation_play", binding.animation)
    end

    if binding.animation.process ~= process then
        binding.animation.process = process
        prefab_object:send("animation_set_time", animation_name, process)
    end
end

function igame_object.set_position(game_object_eid, position)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end
    iom.set_position(world:entity(binding.prefab_object.root), position)
end

function igame_object.get_position(game_object_eid, position)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end
    return iom.get_position(world:entity(binding.prefab_object.root))
end

function igame_object.move_delta(game_object_eid, delta)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end
    local position = iom.get_position(world:entity(binding.prefab_object.root))
    position = math3d.add(position, delta)
    iom.set_position(world:entity(binding.prefab_object.root), position)
end

function igame_object.detach(game_object_eid)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end
    binding.prefab_object:send("detach_slot")
end

------------------------------------------------------------------------------------
function igame_object.attach(game_object_eid, slot_name, prototype_name)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end

    if binding.attach_slot_name == slot_name and binding.attach_prototype_name == prototype_name then
        return
    end

    local prefab_file_name = prototype.get_prefab_file(prototype_name)
    if not prefab_file_name then
        return
    end

    local prefab_object = assert(binding.prefab_object)
    prefab_object:send("attach_slot", slot_name, prefab_file_name)
end

-----------------------------------------------------------------------
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

function igame_object.create(prototype_name, x, y, dir, state, color, construct_pickup)
    local pt = prototype.query_by_name("entity", prototype_name)
    if not pt then
        return
    end

    local position = terrain.get_position_by_coord(x, y, pt.area)
    if not position then
        return
    end

    local prefab_object = iprefab_object.create(pt.model, state, color)
    iom.set_position(world:entity(prefab_object.root), position)

    local game_object_eid = ecs.create_entity {
        policy = {},
        data = {
            game_object = {x = x, y = y, state = state, color = color},
            construct_pickup = construct_pickup,
            construct_modify = true,
            gameplay_entity = {
                prototype_name = prototype_name,
                fluid = {},
                dir = dir,
                x = x,
                y = y,
            },
        }
    }
    game_object_binding[game_object_eid] = {state = state, color = color, prototype_name = prototype_name}

    bind_prefab_object(game_object_eid, prefab_object)

    igame_object.set_dir(game_object_eid, dir)
end

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

function igame_object.update(game_object_eid, v)
    local binding = get_game_object_binding(game_object_eid)
    if not binding then
        return
    end

    if v.prototype_name or v.state ~= binding.state then
        local srt
        local old_prefab_object = binding.prefab_object
        if old_prefab_object then
            srt = world:entity(old_prefab_object.root).scene.srt
            old_prefab_object:remove()
        end

        local prefab_file_name = prototype.get_prefab_file(v.prototype_name or binding.prototype_name)
        if not prefab_file_name then
            return
        end

        local prefab_object = iprefab_object.create(prefab_file_name, v.state or binding.state, v.color or binding.color)
        set_srt(world:entity(prefab_object.root), srt)
        binding.prefab_object = prefab_object
    else
        local prefab_object = binding.prefab_object
        if v.color and not color_equal(binding.color, v.color) then
            binding.color = v.color
            prefab_object:send("update_basecolor", v.color)
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

    function igame_object.set_dir(game_object_eid, dir)
        local binding = get_game_object_binding(game_object_eid)
        if not binding then
            return
        end
        iom.set_rotation(world:entity(binding.prefab_object.root), rotators[dir])
    end
end
